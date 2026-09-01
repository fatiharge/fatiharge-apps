package com.dafalabs.api.auth.identity;

/** What someone may do. Carried in the token, always read from the database. */
public enum Role {
  /** Uses a tenant's product. The overwhelming majority of rows. */
  USER,
  /** Administers one tenant: its content, its people, what it sends them. */
  TENANT_ADMIN,
  /** Works for us. Reaches a tenant only by choosing that tenant first. */
  STAFF
}
