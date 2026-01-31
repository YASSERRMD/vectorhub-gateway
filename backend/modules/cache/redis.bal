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

        self.redisClient = check new (
            connectionString = connectionUrl,
            config = {
                connectionPooling: true,
                isClusterConnection: false,
                ssl: false
            }
        );
        self.enabled = true;
        utils:info("Redis cache initialized: " + connectionUrl);
    }

    public function get(string key) returns string?|error {
        if !self.enabled {
            return ();
        }
        redis:Client? client = self.redisClient;
        if client is redis:Client {
             var result = client->get(key);
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
        redis:Client? client = self.redisClient;
        if client is redis:Client {
             _ = check client->set(key, value);
             _ = check client->expire(key, ttlSeconds);
        }
    }
    
    public function isEnabled() returns boolean {
        return self.enabled;
    }
}
