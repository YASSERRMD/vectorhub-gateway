FROM ballerina/ballerina:latest

WORKDIR /home/ballerina/app
# Copy JAR from local build (ensure 'bal build' was run locally)
COPY target/bin/gateway.jar /home/ballerina/app/gateway.jar
COPY Config.toml /home/ballerina/app/Config.toml

EXPOSE 8080

CMD ["bal", "run", "gateway.jar"]
