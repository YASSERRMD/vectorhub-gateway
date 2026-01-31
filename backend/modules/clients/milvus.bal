import ballerina/http;
import vectorhub/gateway.utils;

public client class MilvusClient {
    http:Client httpClient;
    string baseUrl;

    public function init(string url) returns error? {
        self.baseUrl = url;
        if (url == "") {
             self.httpClient = check new ("http://localhost"); 
        } else {
             self.httpClient = check new (url);
             utils:info("Milvus client initialized for: " + url);
        }
    }

    public function health() returns boolean {
        http:Response|error resp = self.httpClient->get("/api/v1/health");
        if resp is http:Response {
             return resp.statusCode == 200;
        }
        utils:logError("Milvus health check failed", resp);
        return false;
    }

     public function search(string collection, float[] vector, int topK) returns http:Response|error {
        json payload = {
            "collectionName": collection,
            "vector": vector,
            "limit": topK
        };
        // Note: Milvus REST API path might differ based on proxy
        return self.httpClient->post("/api/v1/search", payload);
    }
}
