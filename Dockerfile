# Use an existing Gradle image as the base image
FROM gradle:6.7.0-jdk14 AS build

# Set the working directory
WORKDIR /app

# Copy the build files
COPY build.gradle gradlew ./
COPY gradle gradle
COPY src src

# Run Gradle to build the project
RUN gradle build --no-daemon

# Use a lightweight Java runtime image as the final image
FROM openjdk:14-jdk-alpine

# Set the working directory
WORKDIR /app

# Copy the built jar file from the build stage
COPY --from=build /app/build/libs/*.jar /app/vulnerable-application.jar

# Run the application
ENTRYPOINT ["java", "-jar", "/app/vulnerable-application.jar"]
