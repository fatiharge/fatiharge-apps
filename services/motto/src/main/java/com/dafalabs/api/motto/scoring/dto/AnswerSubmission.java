package com.dafalabs.api.motto.scoring.dto;

import java.util.Map;

/**
 * @param answers item id to a point on the scale, 1 to likertPoints
 * @param spendSkip spend a cooldown skip if the cooldown is open. Explicit
 *     because burning something scarce on someone who only wanted to look is
 *     not a thing to do quietly.
 */
public record AnswerSubmission(Map<String, Integer> answers, boolean spendSkip) {}
