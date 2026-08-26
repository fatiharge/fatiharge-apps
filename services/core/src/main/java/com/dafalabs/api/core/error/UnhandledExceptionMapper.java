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

    LOG.errorf(throwable, "%s unhandled", traceId);
    ErrorPayload payload = ErrorPayloads.of(traceId);

    return Response.status(payload.status())
        .entity(payload.body())
        .type(MediaType.APPLICATION_JSON)
        .build();
  }
}
