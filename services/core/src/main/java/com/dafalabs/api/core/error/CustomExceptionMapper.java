package com.dafalabs.api.core.error;

import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;
import org.jboss.logging.Logger;

/** Renders every {@link CustomRuntimeException} the same way. */
@Provider
public class CustomExceptionMapper implements ExceptionMapper<CustomRuntimeException> {

  private static final Logger LOG = Logger.getLogger(CustomExceptionMapper.class);

  @Override
  public Response toResponse(CustomRuntimeException exception) {
    String traceId = TraceId.current();
    ErrorPayload payload = ErrorPayloads.of(exception, traceId);

    if (exception.status() >= 500) {
      LOG.errorf(exception, "%s %s", traceId, exception.code());
    } else {
      LOG.debugf("%s %s: %s", traceId, exception.code(), exception.getMessage());
    }

    return Response.status(payload.status())
        .entity(payload.body())
        .type(MediaType.APPLICATION_JSON)
        .build();
  }
}
