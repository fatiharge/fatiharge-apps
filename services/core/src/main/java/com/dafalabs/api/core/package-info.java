/**
 * Shared code compiled into every service.
 *
 * <p>Packages are by feature, not by layer: a feature owns its resource,
 * service, entity and repository, and grows layers only when it needs them.
 * The one exception is this library's cross-cutting {@code error} package,
 * which every service inherits so that one error contract covers all of them.
 */
package com.dafalabs.api.core;
