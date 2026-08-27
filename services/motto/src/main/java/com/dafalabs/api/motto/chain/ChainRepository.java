package com.dafalabs.api.motto.chain;

import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.UUID;

@ApplicationScoped
public class ChainRepository implements PanacheRepositoryBase<Chain, UUID> {}
