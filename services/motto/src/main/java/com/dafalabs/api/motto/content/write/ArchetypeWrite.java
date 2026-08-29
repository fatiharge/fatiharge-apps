package com.dafalabs.api.motto.content.write;

import java.util.List;
import java.util.Map;

/**
 * An archetype, words and position together.
 *
 * <p>One payload rather than two endpoints: a name with no rule is an
 * archetype nobody can land on, and a rule with no name is a result the app
 * cannot render. Splitting them makes both halves possible.
 *
 * @param defining the dimensions that make it what it is; the rest count at
 *     background weight
 * @param target where it sits, each dimension between 0 and 1
 */
public record ArchetypeWrite(
    String id,
    String name,
    String summary,
    String motto,
    int ordinal,
    List<String> defining,
    Map<String, Double> target) {}
