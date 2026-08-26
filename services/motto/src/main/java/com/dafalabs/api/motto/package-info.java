/**
 * The motto app's API.
 *
 * <p>Packages are by feature, not by layer: a feature owns its resource,
 * service, entity and repository, and grows layers only when it needs them. A
 * small feature is one file.
 *
 * <p>Nothing here talks to another service at runtime. The token that
 * identifies the caller was signed by {@code auth} and is verified locally
 * against the public key, so this service keeps working while auth is down.
 */
package com.dafalabs.api.motto;
