package com.dafalabs.api.motto.admin;

import com.dafalabs.api.motto.admin.dto.Wiped;
import io.quarkus.logging.Log;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.EntityManager;
import jakarta.transaction.Transactional;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.eclipse.microprofile.config.ConfigProvider;

/**
 * Puts the database back to nobody having used it.
 *
 * <p>Content stays; every trace of a device goes. It exists so the first-run
 * flow can be walked again on a real phone, which is the only way to see what a
 * new user sees.
 *
 * <p><b>Why the switch is a runtime property and not a build-time one.</b> An
 * image is promoted from stage to production by digest — the same artefact runs
 * in both — so anything baked at build time travels to production with it. The
 * only guard that cannot make that journey is one that lives in the
 * environment, and production simply never sets it.
 */
@ApplicationScoped
public class DeviceReset {

  /// Every table that holds something about a person, children first: the
  /// foreign keys decide this order, not taste.
  private static final List<String> DEVICE_TABLES =
      List.of(
          "score_rewards",
          "scores",
          "task_completions",
          "chain_days",
          "chains",
          "results",
          "entitlements",
          "events",
          "feedback");

  /// Spelled out in the request so that a curl someone half-remembers cannot
  /// empty a database by accident.
  static final String CONFIRMATION = "evet-hepsini-sil";

  private final EntityManager entities;

  DeviceReset(EntityManager entities) {
    this.entities = entities;
  }

  /** True only where a deployment has deliberately turned it on. */
  boolean allowed() {
    return ConfigProvider.getConfig()
        .getOptionalValue("motto.admin.reset-enabled", Boolean.class)
        .orElse(false);
  }

  /**
   * Qualified with the schema the deployment configured.
   *
   * <p>Hibernate qualifies entity queries and leaves native ones alone, so an
   * unqualified DELETE here finds nothing and fails. The value is configuration
   * rather than input, and the table names are a constant list in this file —
   * nothing user-supplied reaches the statement.
   */
  private String qualified(String table) {
    return ConfigProvider.getConfig()
            .getOptionalValue("quarkus.hibernate-orm.database.default-schema", String.class)
            .map(schema -> schema + ".")
            .orElse("")
        + table;
  }

  @Transactional
  public Wiped wipe() {
    Map<String, Integer> rows = new LinkedHashMap<>();
    for (String table : DEVICE_TABLES) {
      rows.put(
          table, entities.createNativeQuery("DELETE FROM " + qualified(table)).executeUpdate());
    }
    // Loud on purpose. Somebody reading these logs later should not have to
    // work out why every device disappeared at once.
    Log.warnf("admin reset: every device wiped, %s", rows);
    return new Wiped(rows);
  }
}
