FROM maven:3.8.4-openjdk-17-slim as builder

# Copy only pom.xml of your projects and download dependencies
COPY pom.xml .
RUN mvn -B dependency:resolve-plugins dependency:go-offline

# Copy all other project files and build project
COPY src ./src
RUN mvn -B package -o

# Copy .war artifact to a Tomcat image
FROM tomcat:9.0.58-jre8-openjdk-slim
RUN apt update && apt install -y less

COPY --from=builder target/clickCount.war /usr/local/tomcat/webapps

EXPOSE 8080