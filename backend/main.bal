import ballerina/http;
import ballerina/time;
import vectorhub/gateway.config;
import vectorhub/gateway.utils;
import vectorhub/gateway.cache;
import vectorhub/gateway.pool;
import vectorhub/gateway.gateway;

// Global configuration
config:AppConfig appConfig = checkpanic config:loadConfig("Config.toml");

// Initialize modules using checkpanic for top-level error handling
// Ideally we would wrap this in a start-up function, but top-level vars work for this scale.

// 1. Config & Utils (already loaded)

// 2. Cache
// TODO: Load redis URL from config properly
cache:RedisCache redisCache = checkpanic new("redis://localhost:6379");

// 3. Connection Pool
pool:ConnectionPool connPool = checkpanic new(appConfig);

// 4. Gateway Components
gateway:Router router = new(connPool, appConfig);
gateway:Aggregator aggregator = new();
gateway:Deduplicator deduplicator = new(redisCache);
gateway:RateLimiter rateLimiter = new(redisCache, 100, 60); // Default limits
gateway:MetricsService metricsService = new();
gateway:MgmtService mgmtService = new(connPool, redisCache, metricsService, appConfig); 

service http:Service / on new http:Listener(appConfig.gateway.port) {

    resource function get health() returns json {
         return mgmtService.getHealth();
    }

    resource function get v1/ping() returns string {
         return "pong";
    }

    resource function post v1/search(http:Request req) returns http:Response|json|error {
        metricsService.incrementRequest();
        time:Utc startTime = time:utcNow();

        json|error payload = req.getJsonPayload();
        if payload is error {
            metricsService.incrementFailure();
            return { "error": "Invalid JSON payload" };
        }

        // 1. Rate Limiting
        // TODO: Extract real IP
        if !rateLimiter.isAllowed("default_ip") {
            http:Response resp = new;
            resp.statusCode = 429;
            resp.setPayload({ "error": "Rate limit exceeded" });
            metricsService.incrementFailure();
            return resp; // Return Response object directly
        }

        // Validate payload fields exists
        json|error collectionJson = payload.collection;
        if collectionJson is error {
             return { "error": "Missing 'collection' field" };
        }
        string collection = collectionJson.toString();

        json|error vectorJson = payload.vector;
        if vectorJson is error {
             return { "error": "Missing 'vector' field" };
        }
        
        // 2. Deduplication
        string dedupKey = deduplicator.generateKey(collection, payload);
        string? cached = deduplicator.getCachedResult(dedupKey);
        if cached is string {
             return cached.fromJsonString();
        }

        // 3. Routing
        string[] backends = router.selectBackends();
        if backends.length() == 0 {
             return { "error": "No available backends" };
        }

        // 4. Parallel Execution
        // Extract vector and topK
        float[] vector = check vectorJson.cloneWithType();
        
        json|error topKJson = payload.topK;
        int topK = 5;
        if topKJson is int {
            topK = topKJson;
        } else if topKJson is string { // Handle string numbers if necessary
            int|error t = int:fromString(topKJson);
            if t is int { topK = t; }
        }

        map<http:Response|error> responses = {};
        
        foreach string backend in backends {
            if backend == "qdrant" {
                responses["qdrant"] = connPool.getQdrantClient().search(collection, vector, topK);
            } else if backend == "milvus" {
                 responses["milvus"] = connPool.getMilvusClient().search(collection, vector, topK);
            } else if backend == "weaviate" {
                 responses["weaviate"] = connPool.getWeaviateClient().search(collection, vector, topK);
            }
        }

        // 5. Aggregation
        json|error aggregated = aggregator.aggregate(responses);
        
        if aggregated is json {
             // 6. Cache Result
             deduplicator.cacheResult(dedupKey, aggregated.toJsonString(), 60); 
             metricsService.incrementSuccess(time:utcDiffSeconds(time:utcNow(), startTime));
             return aggregated;
        } else {
             utils:logError("Aggregation failed", aggregated);
             return { "error": "Search failed" };
        }
    }
}
