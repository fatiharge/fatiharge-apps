package com.dafalabs.api.motto.content.write;

/**
 * @param dimension2 the second axis this section crosses, or null while it
 *     reads one. Crossing two is what makes the section about this reader
 *     rather than about their archetype.
 */
public record SectionWrite(int section, String dimension, String dimension2) {}
