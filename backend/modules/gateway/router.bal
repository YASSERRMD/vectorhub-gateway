import vectorhub/gateway.config;
import vectorhub/gateway.pool;
// import vectorhub/gateway.circuit; // Unused, accessed via pool
import vectorhub/gateway.utils;

public class Router {
    pool:ConnectionPool connPool;
    config:AppConfig appConfig;
    int requestCounter = 0;

    public function init(pool:ConnectionPool pool, config:AppConfig config) {
        self.connPool = pool;
        self.appConfig = config;
    }

    public function selectBackends() returns string[] {
        string[] candidates = [];
        
        // Check Circuit Breakers
        if (self.connPool.qdrantCb.allowRequest()) {
            candidates.push("qdrant");
        }
        if (self.connPool.milvusCb.allowRequest()) {
            candidates.push("milvus");
        }
        if (self.connPool.weaviateCb.allowRequest()) {
            candidates.push("weaviate");
        }

        if (candidates.length() == 0) {
            utils:warn("All backends are unavailable due to circuit breakers");
            return [];
        }

        // Apply Routing Strategy
        string strategy = self.appConfig.gateway.routing.strategy;
        if (strategy == "all") {
            return candidates;
        } else if (strategy == "round-robin") {
            // Simple Round Robin
            int idx = self.requestCounter % candidates.length();
            self.requestCounter = self.requestCounter + 1;
            return [candidates[idx]];
        } else if (strategy == "weighted") {
            // Weighted logic (Simplified for now: priority order qdrant > milvus > weaviate)
            // Or just return all for fan-out search which is typical for "gateway" 
            // The user wanted "unified access to *multiple* vector database backends".
            // If it's shard-based, we'd route. If it's aggregation, we query all available.
            // Let's default to "all available" for search unless specified otherwise.
            return candidates;
        }

        return candidates;
    }
}
