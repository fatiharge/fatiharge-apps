package com.dafalabs.api.motto.effects;

import com.dafalabs.api.core.error.CustomRuntimeException;
import com.dafalabs.api.motto.effects.dto.CodeEffects;
import com.dafalabs.api.motto.effects.dto.EffectCatalogue;
import io.vertx.core.json.DecodeException;
import io.vertx.core.json.JsonArray;
import io.vertx.core.json.JsonObject;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;
import java.util.List;
import java.util.Set;

/** What refusals lead to, and the only place a definition is checked. */
@ApplicationScoped
public class Effects {

  /// The behaviours an app can be asked for. A definition names one of these;
  /// it never introduces one. Anything else is refused here rather than
  /// shipped to a phone that will quietly ignore it.
  private static final Set<String> KINDS =
      Set.of("snack", "sheet", "bottom_sheet", "navigate", "call", "method");

  private final ErrorEffectRepository effects;

  Effects(ErrorEffectRepository effects) {
    this.effects = effects;
  }

  @Transactional
  public EffectCatalogue catalogue(String locale) {
    List<CodeEffects> codes =
        effects.forLocale(locale).stream()
            .map(effect -> new CodeEffects(effect.code(), effect.definition()))
            .toList();
    return new EffectCatalogue(version(codes), codes);
  }

  /**
   * Writes one, having read it first.
   *
   * <p>Checked on the way in rather than on the way out: a definition the app
   * cannot use is invisible on a phone -- the code simply reads as unknown --
   * and whoever wrote it would never hear about it.
   */
  @Transactional
  public void write(String code, String locale, String definition) {
    verify(definition);

    ErrorEffect existing = effects.findById(new ErrorEffect.Key(code, locale));
    if (existing == null) {
      effects.persist(ErrorEffect.of(code, locale, definition));
    } else {
      existing.rewrite(definition);
    }
  }

  private void verify(String definition) {
    JsonArray parsed;
    try {
      parsed = new JsonArray(definition);
    } catch (DecodeException | ClassCastException unreadable) {
      throw new CustomRuntimeException(400, "definition_unreadable", "That is not a list.");
    }
    verifyAll(parsed, 0);
  }

  private void verifyAll(JsonArray effects, int depth) {
    // As deep as the app will run it: the list, and one nesting under a choice
    // somebody pressed. Deeper is a definition arguing with itself.
    if (depth > 1) {
      throw new CustomRuntimeException(400, "definition_too_deep", "That nests too far.");
    }

    for (Object raw : effects) {
      if (!(raw instanceof JsonObject effect)) {
        throw new CustomRuntimeException(400, "definition_unreadable", "That is not an effect.");
      }
      String kind = effect.getString("kind");
      if (kind == null || !KINDS.contains(kind)) {
        throw new CustomRuntimeException(
            400, "effect_unknown", "This app has no such effect: " + kind);
      }
      JsonArray choices = effect.getJsonArray("choices");
      if (choices == null) {
        continue;
      }
      for (Object choice : choices) {
        if (!(choice instanceof JsonObject picked)) {
          throw new CustomRuntimeException(400, "definition_unreadable", "That is not a choice.");
        }
        JsonArray then = picked.getJsonArray("then");
        if (then != null) {
          verifyAll(then, depth + 1);
        }
      }
    }
  }

  /// Over the definitions, so editing a sentence changes the version and a
  /// phone holding the old one is told to come back for it.
  private static String version(List<CodeEffects> codes) {
    StringBuilder everything = new StringBuilder();
    for (CodeEffects code : codes) {
      everything.append(code.code()).append(' ').append(code.definition()).append('\n');
    }
    try {
      byte[] digest =
          MessageDigest.getInstance("SHA-256")
              .digest(everything.toString().getBytes(StandardCharsets.UTF_8));
      return HexFormat.of().formatHex(digest, 0, 6);
    } catch (NoSuchAlgorithmException impossible) {
      throw new IllegalStateException(impossible);
    }
  }
}
