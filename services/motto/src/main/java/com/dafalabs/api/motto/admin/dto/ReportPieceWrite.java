package com.dafalabs.api.motto.admin.dto;

/**
 * One report piece, addressed by the slots that identify it. Which of
 * archetypeId, dimension, band and section are set depends on the kind; the
 * unset ones are null and null is part of the address.
 *
 * @param dimension2 the second axis a section crosses, and {@code band2} where
 *     this reader lands on it. Both null on a paragraph written for one axis,
 *     which is what a section reads until somebody writes it nine ways.
 */
public record ReportPieceWrite(
    String kind,
    String archetypeId,
    String dimension,
    String band,
    String dimension2,
    String band2,
    Integer section,
    String text,
    boolean placeholder) {}
