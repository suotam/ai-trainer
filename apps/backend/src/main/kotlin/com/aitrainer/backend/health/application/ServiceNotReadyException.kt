package com.aitrainer.backend.health.application

/** Instance není připravená přijímat provoz; mapuje se na 503 `SERVICE_NOT_READY`. */
class ServiceNotReadyException : RuntimeException("Service is not ready to accept traffic.")
