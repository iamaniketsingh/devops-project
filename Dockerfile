# build stage

FROM maven:3.9.6-eclipse-temurin-17 AS builder

# workdir inside container
WORKDIR /app

# copy pom.xml file first to the container
COPY pom.xml .

# download dependencies first for caching
RUN mvn dependency:go-offline -DskipTests

# copy src to the container
COPY src ./src

# build the jar file
RUN mvn package -DskipTests

# Runtime Stage

# use lightweight alpine based jre image without build tools (maven and jdk)
FROM eclipse-temurin:17-jre-alpine

# set workdir inside container
WORKDIR /app

# copy only the JAR from the build stage to the runtime stage
COPY --from=builder /app/target/*.jar app.jar

# expose the port that spring boot uses
EXPOSE 8080

# run the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
