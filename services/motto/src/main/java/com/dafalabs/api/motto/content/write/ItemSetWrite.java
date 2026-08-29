package com.dafalabs.api.motto.content.write;

import java.util.List;

/**
 * A whole inventory, as one version.
 *
 * <p>Never a single question: a result is a profile computed from a particular
 * set of questions, and editing one in place would quietly make yesterday's
 * results incomparable to today's. A change is a new version, and every result
 * records which version measured it.
 *
 * @param activate whether new answers should be measured with this set
 */
public record ItemSetWrite(int version, boolean activate, List<ItemWrite> items) {}
