package com.dafalabs.api.auth.device;

import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.Optional;
import java.util.UUID;

@ApplicationScoped
public class DeviceRepository implements PanacheRepositoryBase<Device, UUID> {

  public Optional<Device> findByHash(String deviceHash) {
    return find("deviceHash", deviceHash).firstResultOptional();
  }
}
