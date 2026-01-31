import { NextResponse } from 'next/server';

export async function GET() {
    try {
        // In Docker, gateway is accessible via service name 'gateway'
        // For local dev, use localhost:8080
        const gatewayHost = process.env.GATEWAY_HOST || 'localhost';
        const gatewayPort = process.env.GATEWAY_PORT || '8080';
        const apiUrl = `http://${gatewayHost}:${gatewayPort}/health`;

        const response = await fetch(apiUrl, {
            cache: 'no-store',
            headers: {
                'Accept': 'application/json',
            },
        });

        if (!response.ok) {
            return NextResponse.json(
                { error: 'Gateway unavailable', status: response.status },
                { status: 502 }
            );
        }

        const data = await response.json();
        return NextResponse.json(data);
    } catch (error) {
        console.error('Health proxy error:', error);
        return NextResponse.json(
            {
                error: 'Failed to connect to gateway',
                status: 'down',
                backend_status: {},
                metrics: {
                    total_requests: 0,
                    failed_requests: 0,
                    successful_requests: 0,
                    avg_latency_ms: 0,
                    current_rps: 0
                }
            },
            { status: 503 }
        );
    }
}
