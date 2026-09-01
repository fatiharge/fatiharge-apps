package com.dafalabs.api.auth.identity;

/**
 * One kind today. It is an enum rather than a boolean because the next kind —
 * a passkey, a second factor — should be a new row, not a new column.
 */
public enum CredentialType {
  PASSWORD
}
