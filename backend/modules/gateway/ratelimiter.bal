import vectorhub/gateway.cache;
import vectorhub/gateway.utils;

public class RateLimiter {
    cache:RedisCache? cache;
    int requestLimits;
    int windowSeconds;

    public function init(cache:RedisCache? cache, int reqLimit = 100, int window = 60) {
        self.cache = cache;
        self.requestLimits = reqLimit;
        self.windowSeconds = window;
    }

    public function isAllowed(string clientIp) returns boolean {
        cache:RedisCache? rCache = self.cache;
        if rCache is cache:RedisCache && rCache.isEnabled() {
            string key = "ratelimit:" + clientIp;
            int|error count = rCache.increment(key, self.windowSeconds);
            
            if count is int {
                if count > self.requestLimits {
                    utils:warn("Rate limit exceeded for IP: " + clientIp);
                    return false;
                }
            } else {
                 utils:logError("Rate limiter cache error", count);
                 // Fail open? or Fail closed? Fail open for now to ensure availability.
                 return true; 
            }
        }
        return true;
    }
}
