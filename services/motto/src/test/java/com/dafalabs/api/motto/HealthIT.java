package com.dafalabs.api.motto;

import io.quarkus.test.junit.QuarkusIntegrationTest;

/**
 * The same assertions, run against the compiled binary instead of the JVM.
 *
 * <p>Not optional once the target is native: reflection and resource loading
 * behave differently in a native image, and a {@code @QuarkusTest} runs on the
 * JVM where those failures cannot appear.
 */
@QuarkusIntegrationTest
class HealthIT extends HealthTest {}
