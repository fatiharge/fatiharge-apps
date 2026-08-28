package com.dafalabs.api.motto.game.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

public record ScoreSubmission(@Schema(required = true) int points) {}
