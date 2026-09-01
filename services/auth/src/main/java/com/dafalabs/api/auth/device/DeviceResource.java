package com.dafalabs.api.auth.device;

import com.dafalabs.api.auth.device.dto.CurrentDeviceResponse;
import com.dafalabs.api.auth.device.dto.DeviceTokenResponse;
import com.dafalabs.api.auth.device.dto.RegisterDeviceRequest;
import com.dafalabs.api.core.auth.AuthenticatedDevice;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.tags.Tag;

/** The only endpoint anyone calls on this service. */
// The name is the generated Dart class name: a tag called "Cihaz" renames
// DeviceResourceApi to CihazApi and stops the app compiling. The name stays as
// the resource is called; the Turkish belongs in the description.
@Tag(
    name = "Device Resource",
    description =
        "Hesabı olmayan bir kişinin tek kimliği. Uygulama, cihaz kimliğinin ham "
            + "hâlini değil SHA-256 özetini gönderir; ham kimlik telefonda kalır.")
@Path("/v1/devices")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class DeviceResource {

  private final DeviceRegistration registration;
  private final AuthenticatedDevice current;

  DeviceResource(DeviceRegistration registration, AuthenticatedDevice current) {
    this.registration = registration;
    this.current = current;
  }

  // The operationId is not decoration: without it the generated Dart method
  // name is derived from this method's name, and renaming the method here would
  // silently rename the client's API.
  @POST
  @Path("/register")
  @Operation(
      operationId = "registerDevice",
      summary = "Cihazı kaydeder ve token verir",
      description =
          "İkinci kez kaydolmak hata değil olağan durumdur: uygulama token'ı "
              + "dolduğunda yeniden kaydolur ve silinip kurulan bir uygulama aynı "
              + "özetle gelir. İkisi de zaten sahip oldukları kimliği alır.")
  public DeviceTokenResponse register(RegisterDeviceRequest request) {
    IssuedToken issued = registration.register(request.deviceHash(), request.platform());
    return new DeviceTokenResponse(
        issued.deviceId().toString(), issued.token(), issued.expiresInSeconds());
  }

  // Lets a client find out whether the token it is holding is still good
  // without guessing from the next call's failure. Also the smallest possible
  // proof that verification works: it reads the subject out of a token this
  // service signed and another service would verify the same way.
  @GET
  @Path("/me")
  @Authenticated
  @Operation(
      operationId = "currentDevice",
      summary = "Token'ı taşıyanın kim olduğunu söyler",
      description =
          "İstemcinin, elindeki token'ın hâlâ geçerli olup olmadığını bir sonraki "
              + "çağrının hatasından tahmin etmek yerine doğrudan sorabilmesi için.")
  public CurrentDeviceResponse me() {
    return new CurrentDeviceResponse(current.id().toString());
  }
}
