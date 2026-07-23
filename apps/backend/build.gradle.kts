plugins {
	kotlin("jvm") version "2.3.21"
	kotlin("plugin.spring") version "2.3.21"
	id("org.springframework.boot") version "4.1.0"
	id("io.spring.dependency-management") version "1.1.7"
}

group = "com.aitrainer"
version = "0.0.1-SNAPSHOT"

java {
	toolchain {
		languageVersion = JavaLanguageVersion.of(25)
	}
}

repositories {
	mavenCentral()
}

dependencies {
	implementation("org.springframework.boot:spring-boot-starter-webmvc")
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("tools.jackson.module:jackson-module-kotlin")
	// R0-05: PostgreSQL + Flyway (ADR-006). Bez JPA/ORM — schema vzniká
	// výhradně migracemi.
	implementation("org.springframework.boot:spring-boot-starter-jdbc")
	// Boot 4 modularizace: Flyway autokonfiguraci poskytuje samostatný modul.
	implementation("org.springframework.boot:spring-boot-flyway")
	implementation("org.flywaydb:flyway-database-postgresql")
	runtimeOnly("org.postgresql:postgresql")
	testImplementation("org.springframework.boot:spring-boot-starter-webmvc-test")
	// TestRestTemplate autokonfigurace vyžaduje restclient modul (Boot 4 modularizace).
	testImplementation("org.springframework.boot:spring-boot-restclient")
	testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
	// Contract test: validace kanonického OpenAPI z packages/contracts (APR-001).
	testImplementation("io.swagger.parser.v3:swagger-parser:2.1.31")
	// R0-05: skutečný PostgreSQL v testech (ADR-010, QTR-004 — žádná
	// in-memory náhražka).
	testImplementation("org.springframework.boot:spring-boot-testcontainers")
	testImplementation(platform("org.testcontainers:testcontainers-bom:1.21.3"))
	testImplementation("org.testcontainers:postgresql")
	testImplementation("org.testcontainers:junit-jupiter")
	testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

// Kanonickým zdrojem serverových migrací je database/migrations
// (repository-strategy §7). Build je balí do classpath db/migration,
// odkud je čte Flyway — existuje jen jedna udržovaná kopie.
tasks.processResources {
	from(layout.projectDirectory.dir("../../database/migrations")) {
		into("db/migration")
	}
}

kotlin {
	compilerOptions {
		freeCompilerArgs.addAll("-Xjsr305=strict", "-Xannotation-default-target=param-property")
	}
}

tasks.withType<Test> {
	useJUnitPlatform()
}
