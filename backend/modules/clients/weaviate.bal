import ballerina/http;
import vectorhub/gateway.utils;

public client class WeaviateClient {
    http:Client httpClient;
    string baseUrl;

    public function init(string url) returns error? {
        self.baseUrl = url;
        self.httpClient = check new (url);
        utils:info("Weaviate client initialized for: " + url);
    }

    public function health() returns boolean {
        http:Response|error resp = self.httpClient->get("/v1/meta");
        if resp is http:Response {
             return resp.statusCode == 200;
        }
        utils:logError("Weaviate health check failed", resp);
        return false;
    }

    public function search(string collection, float[] vector, int topK) returns http:Response|error {
        json payload = {
            "nearVector": {
                "vector": vector
            },
            "limit": topK
        };
        // Weaviate GraphQL or REST. REST is /v1/objects usually but vector search often requires GraphQL in Weaviate. 
        // Using GraphQL endpoint for vector search.
        string query = string `
        {
            Get {
                ${collection} (
                    nearVector: {
                        vector: ${vector.toString()}
                    }
                    limit: ${topK}
                ) {
                    _additional {
                        id
                        certainty
                    }
                }
            }
        }`;
        
        return self.httpClient->post("/v1/graphql", { "query": query });
    }
}
