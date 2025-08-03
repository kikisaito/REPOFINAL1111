// build.gradle.kts
plugins {
    id("java")
    id("application") // Para el task 'gradle run'
    id("com.github.johnrengelman.shadow") version "8.1.1" // Fat jar
}

group = "org.example"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    // Core Javalin bundle (incluye Jetty, Jackson, SLF4J)
    implementation("io.javalin:javalin-bundle:6.6.0")

    // Conector MySQL
    implementation("com.mysql:mysql-connector-j:9.3.0")
    // Pool de conexiones
    implementation("com.zaxxer:HikariCP:5.1.0")

    // Dotenv para cargar variables de entorno
    implementation("io.github.cdimascio:dotenv-java:3.0.0")

    // BCrypt para hashing de contraseñas
    implementation("org.mindrot:jbcrypt:0.4")
    // Java JWT para JSON Web Tokens
    implementation("com.auth0:java-jwt:4.4.0")

    implementation("org.slf4j:slf4j-simple:2.0.7")
}

tasks.test {
    useJUnitPlatform()
}

application {
    mainClass.set("org.example.Main")
}

// Configuración para shadow jar
tasks.named<com.github.jengelman.gradle.plugins.shadow.tasks.ShadowJar>("shadowJar") {
    archiveBaseName.set("app")
    archiveClassifier.set("")
    archiveVersion.set("")
}

tasks.build {
    dependsOn(tasks.shadowJar)
}

