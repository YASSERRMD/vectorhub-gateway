import ballerina/http;
import vectorhub/gateway.utils;

public client class QdrantClient {
    http:Client httpClient;
    string baseUrl;

    public function init(string url) returns error? {
        self.baseUrl = url;
        self.httpClient = check new (url);
        utils:info("Qdrant client initialized for: " + url);
    }

    public function health() returns boolean {
        http:Response|error resp = self.httpClient->get("/healthz");
        if resp is http:Response {
             return resp.statusCode == 200;
        }
        utils:logError("Qdrant health check failed", resp);
        return false;
    }

    public function search(string collection, float[] vector, int topK) returns http:Response|error {
        json payload = {
            "vector": vector,
            "top": topK,
            "with_payload": true
        };
        return self.httpClient->post("/collections/" + collection + "/points/search", payload);
    }
}
