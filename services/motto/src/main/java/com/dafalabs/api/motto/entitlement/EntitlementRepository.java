package com.dafalabs.api.motto.entitlement;

import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.UUID;

@ApplicationScoped
public class EntitlementRepository implements PanacheRepositoryBase<Entitlement, UUID> {}
