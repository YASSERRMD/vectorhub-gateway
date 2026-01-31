FROM ballerina/ballerina:latest

WORKDIR /opt/gateway

# Copy JAR
COPY target/bin/gateway.jar /opt/gateway/gateway.jar

# Copy empty Config.toml for Ballerina runtime
COPY Config.toml /opt/gateway/Config.toml

# Copy actual gateway configuration
COPY gateway-config.toml /opt/gateway/gateway-config.toml

EXPOSE 8080

CMD ["bal", "run", "gateway.jar"]
