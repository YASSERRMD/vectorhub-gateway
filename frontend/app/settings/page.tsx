'use client';

import { useEffect, useState } from 'react';
import { Settings, Shield, Server, Activity } from 'lucide-react';

export default function SettingsPage() {
    const [config, setConfig] = useState<any>(null);

    useEffect(() => {
        // Fetch live config from backend
        const fetchConfig = async () => {
            const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080';
            try {
                const res = await fetch(`${apiUrl}/health`);
                const data = await res.json();
                if (data.config) {
                    setConfig(data.config);
                }
            } catch (e) { console.error("Config fetch error", e); }
        };
        fetchConfig();
    }, []);

    if (!config) return <div className="p-10 text-white">Loading Configuration...</div>;

    return (
        <div className="space-y-8 max-w-5xl mx-auto">
            <header>
                <h2 className="text-3xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
                    Gateway Configuration
                </h2>
                <p className="text-gray-400 mt-2">Live view of the running gateway configuration.</p>
            </header>

            {/* Gateway Settings */}
            <Section title="Core Settings" icon={<Settings className="text-blue-400" />}>
                <div className="grid grid-cols-2 gap-4">
                    <Field label="Port" value={config.gateway?.port} />
                    <Field label="Workers" value={config.gateway?.workers} />
                    <Field label="Max Connections" value={config.gateway?.maxConnections} />
                    <Field label="Timeout" value={`${config.gateway?.requestTimeoutMs}ms`} />
                </div>
            </Section>

            {/* Routing */}
            <Section title="Routing Strategy" icon={<Activity className="text-green-400" />}>
                <div className="grid grid-cols-2 gap-4">
                    <Field label="Strategy" value={config.gateway?.routing?.strategy} />
                    <Field label="Fallback Enabled" value={config.gateway?.routing?.enableFallback ? "Yes" : "No"} />
                </div>
            </Section>

            {/* Backends */}
            <Section title="Backend Pools" icon={<Server className="text-purple-400" />}>
                <div className="space-y-4">
                    <BackendCard name="Qdrant" text="Primary Vector Store" config={config.backends?.qdrant} />
                    <BackendCard name="Milvus" text="Secondary Store" config={config.backends?.milvus} />
                    <BackendCard name="Weaviate" text="Semantic Search" config={config.backends?.weaviate} />
                </div>
            </Section>

            {/* Circuit Breaker */}
            <Section title="Circuit Breaker Policies" icon={<Shield className="text-red-400" />}>
                <div className="grid grid-cols-3 gap-4">
                    <Field label="Failure Threshold" value={config.backends?.qdrant?.circuitBreaker?.failureThreshold} />
                    <Field label="Reset Time" value={`${config.backends?.qdrant?.circuitBreaker?.resetTimeMs}ms`} />
                    <Field label="Min Volume" value={config.backends?.qdrant?.circuitBreaker?.minRequestVolume} />
                </div>
            </Section>
        </div>
    );
}

function Section({ title, icon, children }: any) {
    return (
        <div className="bg-gray-900/50 border border-gray-800 rounded-xl p-6">
            <h3 className="text-lg font-semibold text-white mb-6 flex items-center gap-2">
                {icon} {title}
            </h3>
            {children}
        </div>
    );
}

function Field({ label, value }: any) {
    return (
        <div>
            <label className="block text-xs uppercase tracking-wider text-gray-500 mb-1">{label}</label>
            <div className="text-gray-200 font-mono bg-black/30 px-3 py-2 rounded border border-gray-800">
                {value?.toString() || "N/A"}
            </div>
        </div>
    );
}

function BackendCard({ name, config }: any) {
    return (
        <div className="bg-black/30 border border-gray-800 p-4 rounded-lg flex justify-between items-center">
            <div>
                <h4 className="text-white font-bold">{name}</h4>
                <div className="text-xs text-gray-500 mt-1">Pool Size: {config?.poolSize}</div>
            </div>
            <div className="text-right">
                <div className="text-xs text-gray-500">Endpoints</div>
                <div className="text-blue-400 font-mono text-sm">{config?.urls?.[0]}</div>
            </div>
        </div>
    )
}
