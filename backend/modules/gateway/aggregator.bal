import ballerina/http;
import vectorhub/gateway.utils;

public class Aggregator {
    
    public function aggregate(map<http:Response|error> responses) returns json|error {
        json[] aggregatedResults = [];
        
        foreach var [backend, response] in responses.entries() {
            if response is http:Response {
                // Assuming standard JSON response from backends. 
                // In reality, we need to normalize schemas (Qdrant vs Milvus vs Weaviate).
                // For this phase, we assume the backend returns a list of results in "result" or "data" field.
                // We will wrap them in a structure identifying the source.
                
                json|error payload = response.getJsonPayload();
                if payload is json {
                    aggregatedResults.push({
                        "source": backend,
                        "data": payload
                    });
                } else {
                     utils:logError("Failed to get payload from " + backend, payload);
                }
            } else {
                 utils:logError("Error response from " + backend, response);
            }
        }
        
        return aggregatedResults;
    }
}
