import ballerina/io;
import ballerina/toml;
import ballerina/file;

# Gateway Configuration
public type GatewayConfig record {|
    int port;
    int workers;
    int maxConnections;
    int requestTimeoutMs;
    boolean enableCompression;
    RoutingConfig routing;
|};

# Routing Configuration
public type RoutingConfig record {|
    string strategy;
    boolean enableFallback;
    int maxConcurrentBackends;
|};

# Backend specific configuration
public type BackendConfig record {|
    string[] urls;
    int timeout;
    int poolSize;
    int weight;
    CircuitBreakerConfig circuitBreaker;
|};

# Circuit Breaker Configuration
public type CircuitBreakerConfig record {|
    decimal failureThreshold;
    int resetTimeMs;
    int timeWindowMs;
    int minRequestVolume;
|};

# Backend Collection
public type Backends record {|
    BackendConfig qdrant;
    BackendConfig milvus;
    BackendConfig weaviate;
|};

# Observability Configuration
public type ObservabilityConfig record {|
    boolean metricsEnabled;
    int metricsPort;
    boolean tracingEnabled;
    string tracingEndpoint;
    string logLevel;
    boolean structuredLogs;
|};

# Root Configuration
public type AppConfig record {|
    GatewayConfig gateway;
    Backends backends;
    ObservabilityConfig observability;
|};

# Load configuration from file
public function loadConfig(string configPath) returns AppConfig|error {
    io:println("Loading configuration from: " + configPath);
    
    boolean exists = check file:test(configPath, file:EXISTS);
    if !exists {
        return error("Config file not found: " + configPath);
    }

    // Read TOML as JSON first (generic map)
    map<json>|error tomlData = toml:readFile(configPath);
    if tomlData is error {
        return error("Failed to parse Config.toml: " + tomlData.message());
    }

    // Convert to AppConfig record
    AppConfig|error appConfig = tomlData.cloneWithType(AppConfig);
    if appConfig is error {
        return error("Invalid configuration structure: " + appConfig.message());
    }

    return appConfig;
}
