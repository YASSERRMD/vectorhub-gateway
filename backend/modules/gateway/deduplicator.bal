import ballerina/crypto;
import vectorhub/gateway.cache;
import vectorhub/gateway.utils;

public class Deduplicator {
    cache:RedisCache? cache;

    public function init(cache:RedisCache? cache) {
        self.cache = cache;
    }

    public function generateKey(string collection, json payload) returns string {
        string rawKey = collection + ":" + payload.toString();
        byte[] hash = crypto:hashSha256(rawKey.toBytes());
        return hash.toBase16();
    }

    public function getCachedResult(string key) returns string? {
        if self.cache is cache:RedisCache {
            var result = self.cache.get(key);
            if result is string {
                utils:info("Cache hit for key: " + key);
                return result;
            }
        }
        return ();
    }

    public function cacheResult(string key, string value, int ttl) {
        if self.cache is cache:RedisCache {
            error? err = self.cache.set(key, value, ttl);
            if err is error {
                utils:logError("Failed to cache result", err);
            }
        }
    }
}
