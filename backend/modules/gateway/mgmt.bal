// import ballerina/http;
import vectorhub/gateway.pool;
import vectorhub/gateway.cache;

public class MgmtService {
    pool:ConnectionPool pool;
    cache:RedisCache? cache;

    public function init(pool:ConnectionPool pool, cache:RedisCache? cache) {
        self.pool = pool;
        self.cache = cache;
    }

    public function getHealth() returns json {
        return {
            "status": "up",
            "backend_status": self.pool.checkHealth()
        };
    }
}
