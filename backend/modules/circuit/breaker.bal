import ballerina/time;
import vectorhub/gateway.config;
import vectorhub/gateway.utils;

public enum CircuitState {
    CLOSED,
    OPEN,
    HALF_OPEN
}

public class CircuitBreaker {
    string name;
    config:CircuitBreakerConfig config;
    
    CircuitState state = CLOSED;
    int failureCount = 0;
    int successCount = 0;
    int totalRequests = 0;
    decimal lastFailureTime = 0;
    
    public function init(string name, config:CircuitBreakerConfig config) {
        self.name = name;
        self.config = config;
    }

    public function allowRequest() returns boolean {
        if (self.state == OPEN) {
            decimal currentTime = time:utcToDecimal(time:utcNow());
            if ((currentTime - self.lastFailureTime) * 1000d > <decimal>self.config.resetTimeMs) {
                self.state = HALF_OPEN;
                utils:info("Circuit breaker " + self.name + " switched to HALF_OPEN");
                return true;
            }
            return false;
        }
        return true;
    }

    public function recordSuccess() {
        if (self.state == HALF_OPEN) {
            self.successCount = self.successCount + 1;
            // Simplistic logic: if one success in half-open, close it? 
            // Or wait for a few? For now, close immediately on success to restore traffic.
            self.state = CLOSED;
            self.failureCount = 0;
            self.successCount = 0;
            self.totalRequests = 0;
            utils:info("Circuit breaker " + self.name + " switched to CLOSED");
        } else {
             self.totalRequests = self.totalRequests + 1;
        }
    }

    public function recordFailure() {
        self.lastFailureTime = time:utcToDecimal(time:utcNow());
        
        if (self.state == HALF_OPEN) {
            self.state = OPEN;
            utils:info("Circuit breaker " + self.name + " switched to OPEN (failure in HALF_OPEN)");
            return;
        }

        self.failureCount = self.failureCount + 1;
        self.totalRequests = self.totalRequests + 1;

        if (self.totalRequests >= self.config.minRequestVolume) {
            decimal failureRate = <decimal>self.failureCount / <decimal>self.totalRequests;
            if (failureRate >= self.config.failureThreshold) {
                self.state = OPEN;
                 utils:warn("Circuit breaker " + self.name + " switched to OPEN. Failure rate: " + failureRate.toString());
            }
        }
    }
    
    public function getState() returns CircuitState {
        return self.state;
    }
}
