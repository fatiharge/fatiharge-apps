package com.dafalabs.api.auth.delivery;

/** Where a written-down message is in its life. Nothing sets SENT yet. */
public enum DeliveryStatus {
  PENDING,
  SENT,
  FAILED
}
