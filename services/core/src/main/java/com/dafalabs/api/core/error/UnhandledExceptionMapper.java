package com.dafalabs.api.core.error;

import jakarta.ws.rs.WebApplicationException;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;
import org.jboss.logging.Logger;

/**
 * The last resort, so that one error contract really covers everything.
 *
 * <p>Without it an unforeseen exception leaves through the framework's own
 * error page, in a shape no client parses and with a stack trace nobody outside
 * should read. JAX-RS picks the most specific mapper, so anything already
 * handled elsewhere never reaches this one.
 */
@Provider
public class UnhandledExceptionMapper implements ExceptionMapper<Throwable> {

  private static final Logger LOG = Logger.getLogger(UnhandledExceptionMapper.class);

  @Override
  public Response toResponse(Throwable throwable) {
    String traceId = TraceId.current();

    // Something already built a full response — a redirect, or a failure a
    // resource shaped itself. Rewriting it would lose what it meant to say.
    if (throwable instanceof WebApplicationException web && web.getResponse().hasEntity()) {
      return web.getResponse();
    }

    ErrorPayload payload;
    if (throwable instanceof WebApplicationException web) {
      // The framework already decided the status: an unknown path, the wrong
      // method, a body it would not parse. Answering 500 to those turns a
      // caller's typo into an hour spent looking for a broken server — and
      // fills the log with stack traces for requests that were simply wrong.
      payload = ErrorPayloads.ofStatus(web.getResponse().getStatus(), traceId);
      if (payload.status() >= 500) {
        LOG.errorf(throwable, "%s unhandled", traceId);
      } else {
        LOG.debugf("%s %d %s", traceId, payload.status(), throwable.getMessage());
      }
    } else {
      LOG.errorf(throwable, "%s unhandled", traceId);
      payload = ErrorPayloads.of(traceId);
    }

    return Response.status(payload.status())
        .entity(payload.body())
        .type(MediaType.APPLICATION_JSON)
        .build();
  }
}
