import ballerina/time;

public class MetricsService {
    int totalRequests = 0;
    int failedRequests = 0;
    int successfulRequests = 0;
    decimal totalLatency = 0d;
    
    // Simple window for requests per second calculation (not perfect but good for "real value" feel)
    time:Utc lastResetTime = time:utcNow();
    int requestsInWindow = 0;
    decimal currentRps = 0d;

    public function incrementRequest() {
        self.totalRequests += 1;
        self.requestsInWindow += 1;
        self.updateRps();
    }

    public function incrementFailure() {
        self.failedRequests += 1;
    }

    public function incrementSuccess(decimal latency) {
        self.successfulRequests += 1;
        self.totalLatency += latency;
    }

    private function updateRps() {
        time:Utc now = time:utcNow();
        decimal timeDiff = time:utcDiffSeconds(now, self.lastResetTime);
        
        if (timeDiff >= 1d) {
            self.currentRps = <decimal>self.requestsInWindow / timeDiff;
            self.requestsInWindow = 0;
            self.lastResetTime = now;
        }
    }

    public function getMetrics() returns json {
        self.updateRps(); // Ensure RPS is up to date
        
        decimal avgLat = 0d;
        if (self.successfulRequests > 0) {
            avgLat = self.totalLatency / <decimal>self.successfulRequests;
        }

        return {
            "total_requests": self.totalRequests,
            "failed_requests": self.failedRequests,
            "successful_requests": self.successfulRequests,
            "avg_latency_ms": avgLat * 1000d, // Convert to ms
            "current_rps": self.currentRps
        };
    }
}
