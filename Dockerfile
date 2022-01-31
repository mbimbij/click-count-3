# Copy .war artifact to a Tomcat image
FROM tomcat:9.0.58-jre8-openjdk-slim

COPY ./target/clickCount.war /usr/local/tomcat/webapps

EXPOSE 8080
