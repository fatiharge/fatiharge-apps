package com.dafalabs.api.motto.entitlement.dto;

/**
 * @param deleted what was removed
 * @param kept what deliberately was not, so that the answer to "why are my free
 *     uses still gone" is in the response rather than only in a support reply
 */
public record DeletionResponse(java.util.List<String> deleted, java.util.List<String> kept) {}
