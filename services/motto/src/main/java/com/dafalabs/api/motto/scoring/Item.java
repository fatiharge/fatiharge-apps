package com.dafalabs.api.motto.scoring;

/**
 * @param id stable; answers refer to it, so renaming one invalidates a stored
 *     answer set
 * @param dimension what agreeing with it counts towards
 * @param reverse agreement counts against the dimension instead
 * @param text what the person reads
 */
public record Item(String id, Dimension dimension, boolean reverse, String text) {}
