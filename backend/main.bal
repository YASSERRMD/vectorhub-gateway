import ballerina/http;
import vectorhub/gateway.config;
import vectorhub/gateway.utils;
import vectorhub/gateway.cache;
import vectorhub/gateway.pool;
import vectorhub/gateway.gateway;

// Global configuration
config:AppConfig appConfig = checkpanic config:loadConfig("Config.toml");

// Initialize Redis Cache
cache:RedisCache redisCache = new();
error? cacheInit = redisCache.init(appConfig.gateway.routing.strategy == "latency" ? "" : "redis://localhost:6379"); // TODO: Add redis config to toml properly
// For now assuming localhost:6379 or disabled if string is empty.
// Actually, let's use a hardcoded value or add to config later. 
// Using "redis://localhost:6379" for now.
error? rInit = redisCache.init("redis://localhost:6379");
if rInit is error {
    utils:logError("Failed to initialize Redis", rInit);
}

// Initialize Connection Pool
pool:ConnectionPool connPool = new();
checkpanic connPool.init(appConfig);

// Initialize Gateway Components
gateway:Router router = new();
router.init(connPool, appConfig);

gateway:Aggregator aggregator = new();

gateway:Deduplicator deduplicator = new();
deduplicator.init(redisCache);

gateway:RateLimiter rateLimiter = new();
rateLimiter.init(redisCache, 100, 60);

service http:Service / on new http:Listener(appConfig.gateway.port) {

    resource function get health() returns json {
        return {
            "status": "ok",
            "backend_status": connPool.checkHealth()
        };
    }

    resource function get v1/ping() returns string {
         return "pong";
    }
}

public function main() returns error? {
    utils:info("Starting VectorHub Gateway on port " + appConfig.gateway.port.toString());
    
    // Keep main running if needed, though service listeners keep it alive usually.
    runtime:sleep(0.1);
}

