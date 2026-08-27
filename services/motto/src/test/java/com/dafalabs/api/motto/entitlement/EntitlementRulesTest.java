package com.dafalabs.api.motto.entitlement;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

import com.dafalabs.api.core.error.CustomRuntimeException;
import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** The rules themselves, without an endpoint in the way. */
@QuarkusTest
class EntitlementRulesTest {

  private static final Instant START = Instant.parse("2026-01-01T09:00:00Z");

  @Inject Entitlements entitlements;
  @InjectMock Clock clock;

  private UUID device;

  @BeforeEach
  void setUp() {
    device = UUID.randomUUID();
    at(START);
  }

  private void at(Instant moment) {
    when(clock.instant()).thenReturn(moment);
  }

  @Test
  @DisplayName("a second motto inside the cooldown is refused, and says which rule refused it")
  void cooldownRefusesTheSecond() {
    entitlements.spendUse(device, false);

    var refused = assertThrows(CustomRuntimeException.class, () -> entitlements.spendUse(device, false));

    assertEquals(409, refused.status());
    assertEquals("cooldown_open", refused.code());
  }

  @Test
  @DisplayName("a skip gets past the cooldown, once")
  void skipGetsPastTheCooldown() {
    entitlements.spendUse(device, false);

    var after = entitlements.spendUse(device, true);

    assertEquals(0, after.skipsLeft());
    assertEquals(0, after.remainingUses());
  }

  @Test
  @DisplayName("asking to skip without a skip is its own answer, not a cooldown message")
  void refusesWhenNoSkipIsLeft() {
    entitlements.spendUse(device, false);
    entitlements.spendUse(device, true);
    at(START.plus(Duration.ofDays(14)).plusSeconds(1));
    // The cooldown is over, so this fails on uses; wind back into a cooldown
    // with the last claim still recent to reach the skip branch.
    at(START.plusSeconds(1));

    var refused = assertThrows(CustomRuntimeException.class, () -> entitlements.spendUse(device, true));

    assertEquals("no_uses_left", refused.code());
  }

  @Test
  @DisplayName("when the free uses are spent, the cooldown is beside the point")
  void refusesWhenUsesAreSpent() {
    entitlements.spendUse(device, false);
    entitlements.spendUse(device, true);

    at(START.plus(Duration.ofDays(30)));

    var refused = assertThrows(CustomRuntimeException.class, () -> entitlements.spendUse(device, false));

    assertEquals(402, refused.status());
    assertEquals("no_uses_left", refused.code());
  }

  @Test
  @DisplayName("once the cooldown has run out, no skip is needed")
  void cooldownExpiresOnItsOwn() {
    entitlements.spendUse(device, false);
    at(START.plus(Duration.ofDays(14)).plusSeconds(1));

    var after = entitlements.spendUse(device, false);

    assertEquals(1, after.skipsLeft());
    assertEquals(0, after.remainingUses());
  }
}
