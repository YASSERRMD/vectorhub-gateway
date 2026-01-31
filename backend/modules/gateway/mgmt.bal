import vectorhub/gateway.config;
import vectorhub/gateway.pool;
import vectorhub/gateway.cache;

public class MgmtService {
    pool:ConnectionPool pool;
    cache:RedisCache? cache;
    MetricsService metrics;
    config:AppConfig appConfig;

    public function init(pool:ConnectionPool pool, cache:RedisCache? cache, MetricsService metrics, config:AppConfig appConfig) {
        self.pool = pool;
        self.cache = cache;
        self.metrics = metrics;
        self.appConfig = appConfig;
    }

    public function getHealth() returns json {
        return {
            "status": "up",
            "backend_status": self.pool.checkHealth(),
            "metrics": self.metrics.getMetrics(),
            "config": self.appConfig
        };
    }
}
