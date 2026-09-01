package com.dafalabs.api.auth.session;

import com.dafalabs.api.auth.identity.IdentityType;
import com.dafalabs.api.auth.identity.Passwords;
import com.dafalabs.api.auth.identity.Role;
import com.dafalabs.api.auth.identity.User;
import com.dafalabs.api.auth.identity.UserIdentity;
import com.dafalabs.api.auth.identity.UserIdentityRepository;
import com.dafalabs.api.auth.identity.UserRepository;
import com.dafalabs.api.auth.otp.IssuedChallenge;
import com.dafalabs.api.auth.otp.OtpChallenge;
import com.dafalabs.api.auth.otp.OtpChallenges;
import com.dafalabs.api.core.error.CustomRuntimeException;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.json.JsonNumber;
import jakarta.transaction.Transactional;
import java.time.Clock;
import java.util.Optional;
import java.util.UUID;
import org.eclipse.microprofile.jwt.JsonWebToken;

/** Turns a proven identity into a session, and keeps one alive. */
@ApplicationScoped
public class Sessions {

  private final UserRepository users;
  private final UserIdentityRepository identities;
  private final OtpChallenges otp;
  private final Passwords passwords;
  private final UserTokens tokens;
  private final Clock clock;

  Sessions(
      UserRepository users,
      UserIdentityRepository identities,
      OtpChallenges otp,
      Passwords passwords,
      UserTokens tokens,
      Clock clock) {
    this.users = users;
    this.identities = identities;
    this.otp = otp;
    this.passwords = passwords;
    this.tokens = tokens;
    this.clock = clock;
  }

  /**
   * Signs in, creating the account on first arrival.
   *
   * <p>The club comes from the challenge rather than from the request. A caller
   * who could name the club here would sign into one club with a code proving
   * only that they can read mail for another.
   */
  @Transactional
  public SessionTokens signInWithCode(UUID challengeId, String code) {
    if (!otp.answer(challengeId, code)) {
      throw wrongCredentials();
    }
    OtpChallenge challenge = otp.find(challengeId).orElseThrow(Sessions::wrongCredentials);

    UserIdentity identity =
        identities
            .find(challenge.tenantId(), challenge.identityType(), challenge.identityValue())
            .orElseGet(() -> register(challenge));

    User user = users.findByIdOptional(identity.userId()).orElseThrow(Sessions::wrongCredentials);

    // A code alone must not open a panel. Whoever holds one signs in with a
    // password and then answers a code; letting this path through would make the
    // password decorative and reduce two factors to one.
    if (user.role() != Role.FAN) {
      throw new CustomRuntimeException(
          409, "password_required", "This account signs in with a password.");
    }

    identity.verify(clock.instant());
    otp.consume(challengeId);
    return openSession(user);
  }

  @Transactional
  public PasswordSignIn signInWithPassword(
      UUID tenantId, IdentityType type, String identityValue, String password) {
    User user =
        identities
            .find(tenantId, type, identityValue)
            .flatMap(identity -> users.findByIdOptional(identity.userId()))
            .filter(candidate -> passwords.verify(candidate.id(), password))
            .orElseThrow(Sessions::wrongCredentials);

    if (!user.canSignIn()) {
      throw wrongCredentials();
    }

    if (user.role() == Role.FAN) {
      return PasswordSignIn.complete(openSession(user));
    }

    IssuedChallenge challenge = otp.issue(tenantId, type, identityValue);
    return PasswordSignIn.secondFactorRequired(
        tokens.issuePending(user, challenge.challengeId()),
        challenge.challengeId(),
        challenge.expiresInSeconds());
  }

  /**
   * Completes a panel sign-in. The challenge is named by the pending token, not
   * by the caller, so a code issued for one account cannot finish another's.
   */
  @Transactional
  public SessionTokens completeSecondFactor(String pendingToken, String code) {
    JsonWebToken pending = tokens.readPending(pendingToken);
    UUID challengeId = UUID.fromString(pending.getClaim(UserTokens.CHALLENGE));

    if (!otp.answer(challengeId, code)) {
      throw wrongCredentials();
    }
    User user = currentUser(pending);
    otp.consume(challengeId);
    return openSession(user);
  }

  /**
   * Role and status are read from the row, never carried over from the token
   * presented. Copying them forward is why a demoted administrator in the system
   * this replaces stayed an administrator for as long as they kept refreshing.
   */
  @Transactional
  public SessionTokens refresh(String refreshToken) {
    return openSession(currentUser(tokens.readRefresh(refreshToken)));
  }

  private User currentUser(JsonWebToken token) {
    User user =
        Optional.ofNullable(token.getSubject())
            .map(UUID::fromString)
            .flatMap(users::findByIdOptional)
            .orElseThrow(UserTokens::unauthorised);

    if (!user.canSignIn()) {
      throw UserTokens.unauthorised();
    }
    // The whole revocation mechanism: a token issued before the last sign-out is
    // behind, and nothing had to be stored per token to know it.
    if (!epochMatches(token, user)) {
      throw UserTokens.unauthorised();
    }
    return user;
  }

  /**
   * Unwraps before comparing.
   *
   * <p>A claim this service invented comes back as a JSON-P value rather than a
   * Java one: the number is a {@link JsonNumber}, which is not a {@link Number}
   * and is equal to no Integer. Comparing the boxed values instead reads as a
   * working revocation check and refuses every token ever issued.
   */
  private static boolean epochMatches(JsonWebToken token, User user) {
    Object claim = token.getClaim(UserTokens.EPOCH);
    if (claim instanceof JsonNumber json) {
      return json.intValue() == user.tokenEpoch();
    }
    return claim instanceof Number number && number.intValue() == user.tokenEpoch();
  }

  private UserIdentity register(OtpChallenge challenge) {
    User user = User.create(challenge.tenantId(), Role.FAN, clock.instant());
    users.persist(user);
    UserIdentity identity =
        UserIdentity.claim(
            user, challenge.identityType(), challenge.identityValue(), clock.instant());
    identities.persist(identity);
    return identity;
  }

  private SessionTokens openSession(User user) {
    return tokens.issue(user);
  }

  /** One answer for a wrong code, an unknown address and a wrong password. */
  private static CustomRuntimeException wrongCredentials() {
    return new CustomRuntimeException(401, "invalid_credentials", "Those credentials do not match.");
  }
}
