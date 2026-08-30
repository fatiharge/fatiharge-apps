package com.dafalabs.api.motto.content;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.dafalabs.api.motto.admin.ContentAdmin;
import com.dafalabs.api.motto.admin.GivenContent;
import com.dafalabs.api.motto.content.dto.ContentBundle;
import com.dafalabs.api.motto.content.write.ArchetypeWrite;
import com.dafalabs.api.motto.content.write.ConnectorWrite;
import com.dafalabs.api.motto.content.write.ContentWriter;
import com.dafalabs.api.motto.content.write.FragmentWrite;
import com.dafalabs.api.motto.content.write.ItemSetWrite;
import com.dafalabs.api.motto.content.write.ItemWrite;
import com.dafalabs.api.motto.content.write.MottoWrite;
import com.dafalabs.api.motto.content.write.SkeletonWrite;
import com.dafalabs.api.motto.content.write.SupportWrite;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.type.CollectionType;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.regex.Pattern;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/**
 * The English payload, pushed for real.
 *
 * <p>`content/en` is a submission rather than a source — the tables are the
 * source — and a submission that the write path refuses is one nobody finds
 * out about until they are holding an admin token in front of a live server.
 * This runs the same writer the admin endpoint runs, over the files as they
 * are committed.
 *
 * <p>It asserts on shape and on the 1.4.1 gate, never on a particular
 * sentence: a translator correcting a line should not have to come here.
 */
@QuarkusTest
class EnglishPayloadTest {

  /// Tests run from the module directory; the payload is at the repository
  /// root, where the push script reads it from.
  private static final Path PAYLOAD = Path.of("../../content/en");

  private static final String EN = "en";

  @Inject ContentWriter writer;
  @Inject ContentAdmin admin;
  @Inject ContentCatalog catalog;
  @Inject ObjectMapper json;
  @Inject GivenContent given;

  @Test
  @DisplayName("it goes in through the same door the admin endpoint uses")
  void thePayloadLoads() throws IOException {
    // The Turkish rows first: the archetype rules the English rows are named
    // against are written from the fallback and from nowhere else.
    given.everything();

    writer.archetypes(EN, read("archetypes", ArchetypeWrite.class));
    writer.items(EN, new ItemSetWrite(1, false, read("items", ItemWrite.class)));
    writer.mottos(EN, read("mottos", MottoWrite.class));
    writer.skeletons(EN, read("skeletons", SkeletonWrite.class));
    writer.fragments(EN, read("fragments", FragmentWrite.class));
    writer.connectors(EN, read("connectors", ConnectorWrite.class));
    writer.support(EN, read("support", SupportWrite.class));

    ContentBundle english = catalog.bundle(EN);

    // Every archetype the payload names has to have its fourteen fragments and
    // its four mottos, or a day somewhere in the cycle comes out empty.
    List<String> named = read("archetypes", ArchetypeWrite.class).stream()
        .map(ArchetypeWrite::id)
        .toList();
    for (String id : named) {
      assertEquals(
          14,
          english.fragments().stream().filter(f -> f.archetypeId().equals(id)).count(),
          id);
      assertEquals(
          4, english.mottos().stream().filter(m -> m.archetypeId().equals(id)).count(), id);
    }
    assertEquals(14, english.skeletons().size());
    assertTrue(english.connectors().size() >= 3);
  }

  @Test
  @DisplayName("and nothing in it is still Turkish")
  void nothingIsUntranslated() throws IOException {
    // The cheap version of a review. A letter that exists only in Turkish is a
    // line somebody pasted across and did not come back to.
    Pattern onlyTurkish = Pattern.compile("[çğıöşÇĞİÖŞ]");

    for (String part :
        List.of(
            "archetypes", "items", "mottos", "skeletons", "fragments", "connectors",
            "support")) {
      String text = Files.readString(PAYLOAD.resolve(part + ".json"));
      assertFalse(onlyTurkish.matcher(text).find(), part);
    }
  }

  @Test
  @DisplayName("and guideline 1.4.1 has nothing to say about it")
  void theWordGateIsClear() throws IOException {
    given.everything();
    thePayloadLoads();

    assertEquals(List.of(), admin.objections(EN));
  }

  private <T> List<T> read(String part, Class<T> type) throws IOException {
    CollectionType list = json.getTypeFactory().constructCollectionType(List.class, type);
    return json.readValue(Files.readString(PAYLOAD.resolve(part + ".json")), list);
  }
}
