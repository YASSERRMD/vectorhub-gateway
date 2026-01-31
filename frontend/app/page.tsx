'use client';

import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, AreaChart, Area } from 'recharts';
import { Activity, Server, Zap, Globe, Database, Cpu } from 'lucide-react';
import clsx from 'clsx';

// Dynamic rendering for server components if mixed
export const dynamic = 'force-dynamic';

interface HealthData {
  status: string;
  backend_status: Record<string, string>;
  metrics?: {
    total_requests: number;
    failed_requests: number;
    successful_requests: number;
    avg_latency_ms: number;
    current_rps: number;
  };
  config?: any;
}

export default function Dashboard() {
  const [data, setData] = useState<HealthData | null>(null);
  const [history, setHistory] = useState<any[]>([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        // Try the Next.js API proxy first (server-side, no CORS issues)
        let response = await fetch('/api/health-proxy');

        // If proxy fails, try direct call (works when CORS is enabled)
        if (!response.ok) {
          const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080';
          response = await fetch(`${apiUrl}/health`);
        }

        const json = await response.json();
        setData(json);

        setHistory(prev => {
          const newPoint = {
            time: new Date().toLocaleTimeString(),
            rps: json.metrics?.current_rps || 0,
            latency: json.metrics?.avg_latency_ms || 0
          };
          const newHistory = [...prev, newPoint];
          if (newHistory.length > 20) newHistory.shift();
          return newHistory;
        });

      } catch (e) {
        console.error("Fetch failed", e);
      }
    };

    fetchData(); // Initial fetch immediately
    const interval = setInterval(fetchData, 2000); // Reduced frequency
    return () => clearInterval(interval);
  }, []);

  if (!data) return <div className="flex h-screen items-center justify-center text-white">Loading Gateway...</div>;

  return (
    <div className="space-y-8 p-6">
      <header className="flex justify-between items-center">
        <div>
          <h2 className="text-4xl font-bold bg-gradient-to-r from-cyan-400 to-blue-600 bg-clip-text text-transparent">
            Gateway Overview
          </h2>
          <p className="text-gray-400 mt-2 flex items-center gap-2">
            <Activity size={16} /> Real-time System Telemetry
          </p>
        </div>
        <div className="flex gap-4">
          {/* Status Badge */}
          <div className={clsx("px-4 py-2 rounded-full font-bold border",
            data.status === 'up' ? "bg-green-500/10 border-green-500 text-green-500" : "bg-red-500/10 border-red-500 text-red-500"
          )}>
            SYSTEM {data.status.toUpperCase()}
          </div>
        </div>
      </header>

      {/* Metrics Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <MetricCard
          title="Avg Latency"
          value={`${data.metrics?.avg_latency_ms.toFixed(2) || 0}ms`}
          icon={<Zap size={20} className="text-yellow-400" />}
          trend="Real-time"
        />
        <MetricCard
          title="Current RPS"
          value={data.metrics?.current_rps.toFixed(1) || "0.0"}
          icon={<Globe size={20} className="text-blue-400" />}
          trend="Requests/sec"
        />
        <MetricCard
          title="Total Requests"
          value={data.metrics?.total_requests.toLocaleString() || "0"}
          icon={<Server size={20} className="text-purple-400" />}
        />
        <MetricCard
          title="Error Rate"
          value={`${((data.metrics?.failed_requests || 0) / (data.metrics?.total_requests || 1) * 100).toFixed(2)}%`}
          icon={<Activity size={20} className="text-red-400" />}
        />
      </div>

      {/* Backend Status & Charts Split */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">

        {/* Backend Status List */}
        <div className="lg:col-span-1 bg-gray-900/50 border border-gray-800 rounded-2xl p-6 backdrop-blur-sm">
          <h3 className="text-xl font-semibold mb-6 flex items-center gap-2 text-white">
            <Database size={20} /> Backend Services
          </h3>
          <div className="space-y-4">
            {Object.entries(data.backend_status).map(([name, status]) => (
              <div key={name} className="flex items-center justify-between p-4 bg-black/40 rounded-xl border border-gray-800">
                <div className="flex items-center gap-3">
                  <div className={clsx("w-3 h-3 rounded-full animate-pulse", status === 'UP' ? "bg-green-400 shadow-[0_0_10px_rgba(74,222,128,0.5)]" : "bg-red-500")} />
                  <span className="capitalize font-medium text-gray-200">{name}</span>
                </div>
                <span className={clsx("text-xs font-bold px-2 py-1 rounded", status === 'UP' ? "bg-green-900/30 text-green-400" : "bg-red-900/30 text-red-400")}>
                  {status}
                </span>
              </div>
            ))}
          </div>
        </div>

        {/* Real-time Chart */}
        <div className="lg:col-span-2 bg-gray-900/50 border border-gray-800 rounded-2xl p-6 backdrop-blur-sm min-h-[400px]">
          <h3 className="text-xl font-semibold mb-6 flex items-center gap-2 text-white">
            <Cpu size={20} /> Traffic & Latency
          </h3>
          <div className="h-[300px] w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={history}>
                <defs>
                  <linearGradient id="colorRps" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#8884d8" stopOpacity={0.8} />
                    <stop offset="95%" stopColor="#8884d8" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#333" />
                <XAxis dataKey="time" stroke="#666" fontSize={12} tick={{ fill: '#666' }} />
                <YAxis stroke="#666" fontSize={12} tick={{ fill: '#666' }} />
                <Tooltip
                  contentStyle={{ backgroundColor: '#111', border: '1px solid #333' }}
                  itemStyle={{ color: '#fff' }}
                />
                <Area type="monotone" dataKey="rps" stroke="#8884d8" fillOpacity={1} fill="url(#colorRps)" name="RPS" />
                <Line type="monotone" dataKey="latency" stroke="#82ca9d" strokeWidth={2} dot={false} name="Latency (ms)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    </div>
  );
}

function MetricCard({ title, value, icon, trend }: any) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-gray-900/50 border border-gray-800 p-6 rounded-2xl backdrop-blur-sm hover:border-gray-700 transition-colors"
    >
      <div className="flex justify-between items-start mb-4">
        <div className="p-3 bg-gray-800/50 rounded-xl">
          {icon}
        </div>
        {trend && <span className="text-xs text-gray-500 font-mono">{trend}</span>}
      </div>
      <div>
        <h4 className="text-gray-400 text-sm font-medium mb-1">{title}</h4>
        <div className="text-3xl font-bold text-white tracking-tight">{value}</div>
      </div>
    </motion.div>
  );
}
