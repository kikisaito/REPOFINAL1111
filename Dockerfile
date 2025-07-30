# Stage 1: Build the application
# Usa openjdk con JDK para compilar tu código Java.
FROM openjdk:21-jdk-slim AS builder

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos del Gradle Wrapper y los scripts de compilación.
COPY gradlew .
COPY gradle/ gradle/
COPY build.gradle.kts .
COPY settings.gradle.kts .

# Dale permisos de ejecución al script del Gradle Wrapper.
RUN chmod +x gradlew

# Copia el código fuente de tu aplicación.
# ¡IMPORTANTE!: Si 'frontend/' es un proyecto de frontend separado (React, Angular, Vue, etc.)
# y NO es compilado o servido directamente por tu backend Java, ELIMINA LA SIGUIENTE LÍNEA.
COPY src/ src/
# COPY frontend/ frontend/ # <--- DESCOMENTA/MANTÉN SOLO SI TU BACKEND LO NECESITA PARA COMPILAR.

# Compila la aplicación utilizando Gradle.
# El flag '-x test' es opcional y omite la ejecución de los tests.
RUN ./gradlew build -x test

# Stage 2: Create the final lean image for running the application
# Usa openjdk con solo el JRE (Java Runtime Environment), que es mucho más ligero.
FROM openjdk:21-jre-slim

# Establece el directorio de trabajo para la aplicación final.
WORKDIR /app

# Copia el archivo JAR compilado desde la etapa 'builder'.
# ASEGÚRATE de que 'equiplink-1.0-SNAPSHOT.jar' es el nombre exacto de tu JAR en build/libs/.
COPY --from=builder /app/build/libs/equiplink-1.0-SNAPSHOT.jar ./app.jar

# --- CRÍTICO: Genera el archivo .env a partir de las variables de entorno de Render ---
# Render inyectará las variables de entorno que configures en su UI directamente en el entorno
# de construcción y ejecución de Docker. Usamos estas variables para crear el archivo .env
# que tu aplicación Javalin espera.
# Esto es seguro porque las credenciales no están hardcodeadas en el Dockerfile,
# sino que vienen de la configuración segura de Render.
RUN echo "DB_URL=${DB_URL}" > .env && \
    echo "DB_USER=${DB_USER}" >> .env && \
    echo "DB_PASSWORD=${DB_PASSWORD}" >> .env && \
    echo "APP_PORT=${APP_PORT}" >> .env && \
    echo "JWT_SECRET=${JWT_SECRET}" >> .env

# Expone el puerto por defecto de tu aplicación.
# Esta es una directiva informativa para Docker.
EXPOSE 7000
# Comando para ejecutar la aplicación cuando el contenedor se inicia.
CMD ["java", "-jar", "app.jar"]