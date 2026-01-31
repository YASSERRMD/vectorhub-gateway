import vectorhub/gateway.clients;
import vectorhub/gateway.config;
import vectorhub/gateway.utils;

public class ConnectionPool {
    clients:QdrantClient qdrantClient;
    clients:MilvusClient milvusClient;
    clients:WeaviateClient weaviateClient;
    
    config:AppConfig appConfig;

    public function init(config:AppConfig config) returns error? {
        self.appConfig = config;
        self.qdrantClient = check new;
        self.milvusClient = check new;
        self.weaviateClient = check new;
        
        // Initialize Clients using the first URL for now (Load Balancing is Phase 4)
        if (config.backends.qdrant.urls.length() > 0) {
             check self.qdrantClient.init(config.backends.qdrant.urls[0]);
        }
        
        if (config.backends.milvus.urls.length() > 0) {
             check self.milvusClient.init(config.backends.milvus.urls[0]);
        }
        
        if (config.backends.weaviate.urls.length() > 0) {
             check self.weaviateClient.init(config.backends.weaviate.urls[0]);
        }
        
        utils:info("Connection pool initialized");
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
