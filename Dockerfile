# Start from a lightweight JDK image
FROM openjdk:17-jdk-slim

# Copy the packaged JAR file into the container
COPY target/*.jar app.jar

# Run the JAR file
ENTRYPOINT ["java","-jar","/app.jar"]
