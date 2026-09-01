package com.dafalabs.api.auth.delivery;

import com.dafalabs.api.auth.identity.IdentityType;
import java.util.Map;
import java.util.UUID;

/**
 * Hands a message to whatever carries it.
 *
 * <p>The tenant is the first parameter and not an afterthought. Whether a club's
 * mail leaves from its own domain or from ours is undecided, and the decision
 * can only stay open if every caller already says which club it is sending for —
 * otherwise choosing later means editing every call site.
 */
public interface MessageDelivery {

  void deliver(
      UUID tenantId,
      IdentityType channel,
      String recipient,
      String template,
      Map<String, String> variables);
}
