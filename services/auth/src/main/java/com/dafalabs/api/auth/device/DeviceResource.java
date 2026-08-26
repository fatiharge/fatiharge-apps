package com.dafalabs.api.auth.device;

import com.dafalabs.api.auth.device.dto.DeviceTokenResponse;
import com.dafalabs.api.auth.device.dto.RegisterDeviceRequest;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import org.eclipse.microprofile.openapi.annotations.Operation;

/** The only endpoint anyone calls on this service. */
@Path("/v1/devices")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class DeviceResource {

  private final DeviceRegistration registration;

  DeviceResource(DeviceRegistration registration) {
    this.registration = registration;
  }

  // The operationId is not decoration: without it the generated Dart method
  // name is derived from this method's name, and renaming the method here would
  // silently rename the client's API.
  @POST
  @Path("/register")
  @Operation(operationId = "registerDevice", summary = "Register a device and get a token")
  public DeviceTokenResponse register(RegisterDeviceRequest request) {
    IssuedToken issued = registration.register(request.deviceHash(), request.platform());
    return new DeviceTokenResponse(
        issued.deviceId().toString(), issued.token(), issued.expiresInSeconds());
  }
}
