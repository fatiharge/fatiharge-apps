package com.dafalabs.api.motto.chain.dto;

import java.util.List;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * Every day this device ever marked, grouped by the run it belonged to.
 *
 * <p>Separate from {@link ChainState}, which answers "where am I now" and
 * deliberately forgets finished runs. This one answers "what did I do", and
 * that is the question the days screen is built on.
 */
public record ChainHistory(@Schema(required = true) List<ChainPeriod> periods) {}
