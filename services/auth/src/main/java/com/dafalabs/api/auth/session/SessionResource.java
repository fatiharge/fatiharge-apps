package com.dafalabs.api.auth.session;

import com.dafalabs.api.auth.otp.IssuedChallenge;
import com.dafalabs.api.auth.session.dto.ChallengeResponse;
import com.dafalabs.api.auth.session.dto.CodeSignInRequest;
import com.dafalabs.api.auth.session.dto.PasswordSignInRequest;
import com.dafalabs.api.auth.session.dto.PasswordSignInResponse;
import com.dafalabs.api.auth.session.dto.RefreshRequest;
import com.dafalabs.api.auth.session.dto.RequestCodeRequest;
import com.dafalabs.api.auth.session.dto.SecondFactorRequest;
import com.dafalabs.api.auth.session.dto.SessionResponse;
import com.dafalabs.api.auth.otp.OtpChallenges;
import com.dafalabs.api.core.error.CustomRuntimeException;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.HeaderParam;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import java.util.UUID;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;
import org.eclipse.microprofile.openapi.annotations.tags.Tag;

/** Signing in, and staying signed in. */
// The name is the generated Dart class name, so it stays as the resource is
// called. The Turkish belongs in the description.
@Tag(
    name = "Session Resource",
    description =
        "Giriş ve oturumun sürdürülmesi. Sıradan bir kullanıcı tek kullanımlık "
            + "kodla girer; yönetici hesabı önce parolasını, sonra kodunu verir. Erişim "
            + "token'ı kısa ömürlüdür ve hiçbir istekte veritabanına sorulmaz, "
            + "yenileme token'ı uzundur ve kişinin satırındaki sayaç arttığında "
            + "topluca geçersiz olur.")
@Path("/v1/auth")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class SessionResource {

  /**
   * Which tenant the caller is acting for.
   *
   * <p>A header rather than a path, because a client knows its tenant from its
   * build or its hostname and should not have to put it in every URL. It says
   * which tenant is being asked for; the token says whether the caller may have
   * it.
   *
   * <p>More than one product authenticates here, so this is a tenant and not a
   * club, a workspace or a team. What a tenant means belongs to the product that
   * sells to it.
   */
  static final String TENANT_HEADER = "X-Tenant-Id";

  private final Sessions sessions;
  private final OtpChallenges otp;

  SessionResource(Sessions sessions, OtpChallenges otp) {
    this.sessions = sessions;
    this.otp = otp;
  }

  // The operationId is not decoration: without it the generated Dart method name
  // is derived from this method's name, and renaming the method here would
  // silently rename the client's API.
  @POST
  @Path("/codes")
  @Operation(
      operationId = "requestCode",
      summary = "Bir kimliğe tek kullanımlık kod gönderir",
      description =
          "Kodun kendisi cevapta dönmez — yalnızca kodun var olduğu ve ne kadar "
              + "yaşayacağı döner. Kod şu an bir mesaj kuyruğu tablosuna yazılır, "
              + "henüz onu taşıyan bir kanal yoktur. Aynı kimliğe saatlik ve "
              + "günlük istek sınırı uygulanır; sınır kiracı başına sayılır, yani "
              + "bir kiracının trafiği diğerinin kullanıcısını kilitleyemez. "
              + "Telefon şemada vardır ama SMS sağlayıcısı olmadığı için reddedilir.")
  public ChallengeResponse requestCode(
      @Parameter(required = true) @HeaderParam(TENANT_HEADER) String tenantId,
      RequestCodeRequest request) {
    IssuedChallenge issued =
        otp.issue(tenant(tenantId), request.identityType(), request.identity());
    return new ChallengeResponse(issued.challengeId().toString(), issued.expiresInSeconds());
  }

  @POST
  @Path("/sessions/by-code")
  @Operation(
      operationId = "signInWithCode",
      summary = "Tek kullanımlık kodu oturuma çevirir",
      description =
          "Hesap yoksa ilk girişte oluşturulur. Kiracı, isteğin gövdesinden değil "
              + "kodun ait olduğu doğrulamadan okunur: bir kiracı için alınan kod "
              + "başka bir kiracıya giriş yapamaz. Yönetici hesapları bu yolu "
              + "kullanamaz, parolayla girmek zorundadır.")
  public SessionResponse signInWithCode(CodeSignInRequest request) {
    return session(sessions.signInWithCode(challenge(request.challengeId()), request.code()));
  }

  @POST
  @Path("/sessions/by-password")
  @Operation(
      operationId = "signInWithPassword",
      summary = "Parolayla giriş yapar",
      description =
          "Sıradan kullanıcı için oturumu doğrudan açar. Yönetici hesabı için "
              + "ikinci adım gerekir: cevap `SECOND_FACTOR_REQUIRED` döner, bir "
              + "kod gönderilir ve parola adımının geçildiğini kanıtlayan geçici "
              + "bir token verilir. Parola yanlışsa hiçbir kod gönderilmez.")
  public PasswordSignInResponse signInWithPassword(
      @Parameter(required = true) @HeaderParam(TENANT_HEADER) String tenantId,
      PasswordSignInRequest request) {
    PasswordSignIn outcome =
        sessions.signInWithPassword(
            tenant(tenantId), request.identityType(), request.identity(), request.password());

    if (outcome.isComplete()) {
      return new PasswordSignInResponse("COMPLETE", session(outcome.tokens()), null, null, 0);
    }
    return new PasswordSignInResponse(
        "SECOND_FACTOR_REQUIRED",
        null,
        outcome.pendingToken(),
        outcome.challengeId().toString(),
        outcome.codeExpiresInSeconds());
  }

  @POST
  @Path("/sessions/second-factor")
  @Operation(
      operationId = "completeSecondFactor",
      summary = "Yönetici girişini kodla tamamlar",
      description =
          "Hangi doğrulamanın tamamlandığını geçici token söyler, çağıran değil. "
              + "Böylece bir hesap için gönderilen kod başka bir hesabın girişini "
              + "bitiremez.")
  public SessionResponse completeSecondFactor(SecondFactorRequest request) {
    return session(sessions.completeSecondFactor(request.pendingToken(), request.code()));
  }

  @POST
  @Path("/sessions/refresh")
  @Operation(
      operationId = "refreshSession",
      summary = "Yenileme token'ını yeni bir oturumla değiştirir",
      description =
          "Rol ve durum her seferinde veritabanından okunur, sunulan token'dan "
              + "taşınmaz — yetkisi alınan birinin elindeki token yetkiyi "
              + "sürdüremesin diye. Kişinin satırındaki sayaç arttıysa daha eski "
              + "her token reddedilir; \"tüm cihazlardan çık\" budur.")
  public SessionResponse refresh(RefreshRequest request) {
    return session(sessions.refresh(request.refreshToken()));
  }

  private static SessionResponse session(SessionTokens tokens) {
    return new SessionResponse(
        tokens.accessToken(), tokens.refreshToken(), tokens.expiresInSeconds());
  }

  private static UUID tenant(String tenantId) {
    return uuid(tenantId, "invalid_tenant", TENANT_HEADER + " must be a UUID.");
  }

  private static UUID challenge(String challengeId) {
    return uuid(challengeId, "invalid_challenge", "challengeId must be a UUID.");
  }

  private static UUID uuid(String value, String code, String message) {
    try {
      return UUID.fromString(value);
    } catch (IllegalArgumentException | NullPointerException e) {
      throw new CustomRuntimeException(400, code, message);
    }
  }
}
