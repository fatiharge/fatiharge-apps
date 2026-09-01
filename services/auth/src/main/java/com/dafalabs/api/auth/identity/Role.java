package com.dafalabs.api.auth.identity;

/** What someone may do. Carried in the token, always read from the database. */
public enum Role {
  /** Uses a club's app. The overwhelming majority of rows. */
  FAN,
  /** Runs one club's panel: publishes content, sends notifications. */
  CLUB_ADMIN,
  /** Works for us. Reaches a club's panel only by choosing that club first. */
  STAFF
}
