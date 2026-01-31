import ballerinax/redis;
import vectorhub/gateway.utils;

public class RedisCache {
    redis:Client? redisClient;
    boolean enabled;

    public function init(string connectionUrl) returns error? {
        if connectionUrl == "" {
            self.enabled = false;
            utils:info("Redis cache disabled (no URL provided)");
            self.redisClient = ();
            return;
        }

        self.redisClient = check new ({
            connection: connectionUrl,
            connectionPooling: true,
            isClusterConnection: false
        });
        self.enabled = true;
        utils:info("Redis cache initialized: " + connectionUrl);
    }

    public function get(string key) returns string?|error {
        if !self.enabled {
            return ();
        }
        redis:Client? rClient = self.redisClient;
        if rClient is redis:Client {
             var result = rClient->get(key);
             if result is string {
                 return result;
             } else if result is () {
                 return ();
             } else {
                 return result; // return error
             }
        }
        return ();
    }

    public function set(string key, string value, int ttlSeconds) returns error? {
        if !self.enabled {
            return;
        }
        redis:Client? rClient = self.redisClient;
        if rClient is redis:Client {
             _ = check rClient->set(key, value);
             _ = check rClient->expire(key, ttlSeconds);
        }
    }

    public function increment(string key, int ttlSeconds) returns int|error {
        if !self.enabled {
            return 0; // Allow if cache disabled
        }
        redis:Client? rClient = self.redisClient;
        if rClient is redis:Client {
             int val = check rClient->incr(key);
             if val == 1 {
                 _ = check rClient->expire(key, ttlSeconds);
             }
             return val;
        }
        return 0;
    }
    
    public function isEnabled() returns boolean {
        return self.enabled;
    }
}
