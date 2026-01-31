import ballerina/http;
import ballerina/lang.runtime;
// import ballerina/observe; // Unused
import vectorhub/gateway.config;
import vectorhub/gateway.utils;

// Global configuration
config:AppConfig appConfig = checkpanic config:loadConfig("Config.toml");

// @observe:Observable // Removed as it caused compilation error on service
service http:Service / on new http:Listener(appConfig.gateway.port) {

    resource function get health() returns json {
        utils:info("Health check requested");
        return {
            "status": "up",
            "version": "0.1.0"
        };
    }

    resource function get v1/ping() returns string {
        utils:debug("Ping requested");
        return "pong";
    }
}

public function main() returns error? {
    utils:info("Starting VectorHub Gateway on port " + appConfig.gateway.port.toString());
    
    // Keep main running if needed, though service listeners keep it alive usually.
    runtime:sleep(0.1);
}

