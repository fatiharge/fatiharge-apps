package com.dafalabs.api.auth.identity;

/**
 * PHONE exists in the schema before it can be used: there is no SMS provider
 * yet, so the API refuses it. Carrying it from the start means adding one later
 * is a delivery channel and a setting, not a migration.
 */
public enum IdentityType {
  EMAIL,
  PHONE
}
