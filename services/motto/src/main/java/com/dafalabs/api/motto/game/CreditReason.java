package com.dafalabs.api.motto.game;

/** What earned a turn at the game, and what it is worth. */
public enum CreditReason {

  /// The day was marked. One turn: the chain moving is the smallest thing the
  /// app asks for, and it should be worth something on its own.
  MARKED_DAY(1),

  /// All three of the day's things were done. Three turns, because this is the
  /// part somebody has to actually go and do.
  TASKS_DONE(3);

  private final int turns;

  CreditReason(int turns) {
    this.turns = turns;
  }

  public int turns() {
    return turns;
  }
}
