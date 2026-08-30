package com.dafalabs.api.motto.scoring;

import com.dafalabs.api.motto.content.ContentLocale;
import com.dafalabs.api.motto.scoring.dto.AnswerSubmission;
import com.dafalabs.api.motto.scoring.dto.ArchetypeResponse;
import com.dafalabs.api.motto.scoring.dto.QuestionResponse;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.HeaderParam;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import java.util.List;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;

/** The questions, and the glimpse of a result partway through. */
@Path("/v1/tests")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
@Authenticated
public class TestResource {

  /** Below this many answers the result is a tease rather than an answer. */
  private static final int CONFIDENT_FROM = 12;

  private final ItemPool items;
  private final Scoring scoring;
  private final ArchetypeRules rules;
  private final ArchetypeCatalog catalog;

  TestResource(ItemPool items, Scoring scoring, ArchetypeRules rules, ArchetypeCatalog catalog) {
    this.items = items;
    this.scoring = scoring;
    this.rules = rules;
    this.catalog = catalog;
  }

  @GET
  @Path("/questions")
  @Operation(operationId = "testQuestions", summary = "The questions to ask")
  public QuestionResponse questions(@Parameter(hidden = true) @HeaderParam("Accept-Language") String acceptLanguage) {
    // Weights and reverse flags stay here. The app has no use for them, and
    // sending them would publish how to answer for a chosen result.
    List<QuestionResponse.Question> questions =
        items.all(ContentLocale.from(acceptLanguage)).stream()
            .map(item -> new QuestionResponse.Question(item.id(), item.text()))
            .toList();
    return new QuestionResponse(items.likertPoints(), questions);
  }

  /**
   * The overlay shown partway through the test. It spends nothing: a glimpse
   * that cost a use would be a trick, and the point of it is to make finishing
   * feel worth it.
   */
  @POST
  @Path("/partial")
  @Operation(operationId = "partialResult", summary = "A first look, without spending anything")
  public ArchetypeResponse partial(
      AnswerSubmission submission, @Parameter(hidden = true) @HeaderParam("Accept-Language") String acceptLanguage) {
    ProfileVector profile = scoring.score(submission.answers());
    return describe(
        rules.match(profile),
        submission.answers().size() >= CONFIDENT_FROM,
        ContentLocale.from(acceptLanguage));
  }

  private ArchetypeResponse describe(String id, boolean confident, String locale) {
    Archetype archetype = catalog.byId(id, locale);
    return new ArchetypeResponse(
        archetype.id(), archetype.name(), archetype.summary(), archetype.motto(), confident);
  }
}
