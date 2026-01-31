import HealthCard from '@/components/HealthCard';

// Opt for dynamic rendering to get fresh status
export const dynamic = 'force-dynamic';

async function getHealth() {
  try {
    const res = await fetch('http://localhost:8080/health', { cache: 'no-store' });
    if (!res.ok) {
      throw new Error('Failed to fetch health');
    }
    return res.json();
  } catch (e) {
    console.error(e);
    return null;
  }
}

export default async function Home() {
  const healthData = await getHealth();
  const backendStatus = healthData?.backend_status || {};

  // Mapping status to "up" | "down" | "unknown"
  const getStatus = (s: string) => (s === 'UP' ? 'up' : 'down');

  // Hardcoded latencies for now as backend health check might not return latency yet or different format
  // Assuming backend returns { "qdrant": "UP", ... }

  return (
    <div className="space-y-8">
      <header>
        <h2 className="text-3xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
          System Overview
        </h2>
        <p className="text-gray-400 mt-2">Real-time status of vector database backends.</p>
      </header>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <HealthCard
          name="Qdrant"
          status={backendStatus.qdrant ? getStatus(backendStatus.qdrant) : 'unknown'}
          latency={backendStatus.qdrant === 'UP' ? 12 : undefined}
        />
        <HealthCard
          name="Milvus"
          status={backendStatus.milvus ? getStatus(backendStatus.milvus) : 'unknown'}
          latency={backendStatus.milvus === 'UP' ? 35 : undefined}
        />
        <HealthCard
          name="Weaviate"
          status={backendStatus.weaviate ? getStatus(backendStatus.weaviate) : 'unknown'}
          latency={backendStatus.weaviate === 'UP' ? 28 : undefined}
        />
      </div>

      <div className="bg-gray-900 rounded-xl p-6 border border-gray-800">
        <h3 className="text-xl font-semibold mb-4 text-white">Metrics</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="bg-gray-800 p-4 rounded-lg">
            <p className="text-sm text-gray-400">Total Requests</p>
            <p className="text-2xl font-bold text-white">1,234</p>
          </div>
          <div className="bg-gray-800 p-4 rounded-lg">
            <p className="text-sm text-gray-400">Cache Hit Rate</p>
            <p className="text-2xl font-bold text-green-400">85%</p>
          </div>
          <div className="bg-gray-800 p-4 rounded-lg">
            <p className="text-sm text-gray-400">Avg Latency</p>
            <p className="text-2xl font-bold text-blue-400">32ms</p>
          </div>
          <div className="bg-gray-800 p-4 rounded-lg">
            <p className="text-sm text-gray-400">System Status</p>
            <p className="text-2xl font-bold text-white">{healthData?.status === 'ok' ? 'HEALTHY' : 'DEGRADED'}</p>
          </div>
        </div>
      </div>
    </div>
  );
}
