import vectorhub/gateway.clients;
import vectorhub/gateway.config;
import vectorhub/gateway.utils;
import vectorhub/gateway.circuit;

public class ConnectionPool {
    clients:QdrantClient qdrantClient;
    clients:MilvusClient milvusClient;
    clients:WeaviateClient weaviateClient;
    
    public circuit:CircuitBreaker qdrantCb;
    public circuit:CircuitBreaker milvusCb;
    public circuit:CircuitBreaker weaviateCb;
    
    config:AppConfig appConfig;

    public function init(config:AppConfig config) returns error? {
        self.appConfig = config;

        // Initialize with first URL if available, else empty (or handle error)
        // In real pool, we might manage list. For now, 1:1 mapping.
        
        string qdrantUrl = config.backends.qdrant.urls.length() > 0 ? config.backends.qdrant.urls[0] : "";
        string milvusUrl = config.backends.milvus.urls.length() > 0 ? config.backends.milvus.urls[0] : "";
        string weaviateUrl = config.backends.weaviate.urls.length() > 0 ? config.backends.weaviate.urls[0] : "";

        // Client init called at creation
        self.qdrantClient = check new clients:QdrantClient(qdrantUrl);
        self.milvusClient = check new clients:MilvusClient(milvusUrl);
        self.weaviateClient = check new clients:WeaviateClient(weaviateUrl);
        
        // Initialize Circuit Breakers
        self.qdrantCb = new("qdrant", config.backends.qdrant.circuitBreaker);
        self.milvusCb = new("milvus", config.backends.milvus.circuitBreaker);
        self.weaviateCb = new("weaviate", config.backends.weaviate.circuitBreaker);
        
        utils:info("Connection pool initialized with circuit breakers");
    }

    public function getQdrantClient() returns clients:QdrantClient {
        return self.qdrantClient;
    }

    public function getMilvusClient() returns clients:MilvusClient {
        return self.milvusClient;
    }

    public function getWeaviateClient() returns clients:WeaviateClient {
        return self.weaviateClient;
    }

    public function checkHealth() returns map<boolean> {
        return {
            "qdrant": self.qdrantClient.health(),
            "milvus": self.milvusClient.health(),
            "weaviate": self.weaviateClient.health()
        };
    }
}
