interface HealthCardProps {
    name: string;
    status: 'up' | 'down' | 'unknown';
    latency?: number;
}

export default function HealthCard({ name, status, latency }: HealthCardProps) {
    const statusColor = {
        up: 'bg-green-500',
        down: 'bg-red-500',
        unknown: 'bg-gray-500'
    }[status];

    return (
        <div className="bg-gray-800 rounded-lg p-6 border border-gray-700 shadow-lg">
            <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-semibold text-white capitalize">{name}</h3>
                <span className={`block w-3 h-3 rounded-full ${statusColor} shadow-[0_0_10px_rgba(0,0,0,0.5)]`} />
            </div>
            <div className="text-gray-400 text-sm">
                <p>Status: <span className="text-white font-medium">{status.toUpperCase()}</span></p>
                <p>Latency: <span className="text-white font-medium">{latency ? latency + 'ms' : 'N/A'}</span></p>
            </div>
        </div>
    );
}
