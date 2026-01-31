import HealthCard from '@/components/HealthCard';

export default function Home() {
  return (
    <div className="space-y-8">
      <header>
        <h2 className="text-3xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
          System Overview
        </h2>
        <p className="text-gray-400 mt-2">Real-time status of vector database backends.</p>
      </header>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <HealthCard name="Qdrant" status="up" latency={24} />
        <HealthCard name="Milvus" status="up" latency={45} />
        <HealthCard name="Weaviate" status="unknown" />
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
            <p className="text-sm text-gray-400">Active Nodes</p>
            <p className="text-2xl font-bold text-purple-400">3/3</p>
          </div>
        </div>
      </div>
    </div>
  );
}
