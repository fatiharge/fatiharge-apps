package com.dafalabs.api.motto.admin.dto;

/**
 * One report piece, addressed by the slots that identify it. Which of
 * archetypeId, dimension, band and section are set depends on the kind; the
 * unset ones are null and null is part of the address.
 */
public record ReportPieceWrite(
    String kind,
    String archetypeId,
    String dimension,
    String band,
    Integer section,
    String text,
    boolean placeholder) {}
