package com.dafalabs.api.motto.game;

import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;
import java.time.LocalDate;

@ApplicationScoped
public class ScoreRewardRepository
    implements PanacheRepositoryBase<ScoreReward, LocalDate> {}
