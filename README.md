<div align="center">
  <img src="assets/logo.png" alt="VectorHub Gateway" width="200"/>
  
  # VectorHub Gateway
  
  **🚀 High-Performance Unified API Gateway for Vector Databases**
  
  [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
  [![Ballerina](https://img.shields.io/badge/Built%20with-Ballerina-1E88E5.svg)](https://ballerina.io)
  [![Next.js](https://img.shields.io/badge/Dashboard-Next.js%2016-000000.svg)](https://nextjs.org)
  [![Docker](https://img.shields.io/badge/Docker-Ready-2496ED.svg)](https://docker.com)
  
  [Features](#-features) • [Quick Start](#-quick-start) • [API Reference](#-api-reference) • [Architecture](#-architecture) • [Deployment](#-deployment)
</div>

---

## 🎯 Overview

VectorHub Gateway is a cloud-native API gateway that provides a **unified interface** to query and manage multiple vector databases. Built with [Ballerina](https://ballerina.io) for high-performance backend processing and [Next.js](https://nextjs.org) for a real-time monitoring dashboard.

**Supported Vector Databases:**
- 🔶 **Qdrant** - High-performance vector search
- 🔷 **Milvus** - Purpose-built for scalable similarity search  
- 🟢 **Weaviate** - AI-native vector database

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| **🔀 Unified API** | Single `/v1/search` endpoint to query all vector databases |
| **🧠 Intelligent Routing** | Automatic routing based on latency, availability, or round-robin |
| **⚡ Circuit Breaker** | Automatic detection and isolation of failing backends |
| **💾 Redis Caching** | High-speed caching with request deduplication |
| **🚦 Rate Limiting** | Token-bucket algorithm for resource protection |
| **🔄 Scatter-Gather** | Parallel queries with intelligent result aggregation |
| **📊 Real-time Dashboard** | Live metrics, health status, and traffic visualization |
| **🔍 Observability** | Jaeger tracing and Prometheus metrics built-in |
| **🔒 CORS Support** | Full CORS headers for cross-origin requests |

---

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- Ballerina 2201.x (Swan Lake) — *optional for development*
- Node.js 18+ — *optional for development*

### One-Command Deployment

```bash
# Clone the repository
git clone https://github.com/YASSERRMD/vectorhub-gateway.git
cd vectorhub-gateway

# Start all services (Gateway, Vector DBs, Redis, Jaeger)
docker-compose -f deployments/docker-compose.yml up -d
```

### Access Points

| Service | URL | Description |
|---------|-----|-------------|
| **Gateway API** | http://localhost:8080 | Main API endpoint |
| **Dashboard** | http://localhost:3000 | Real-time monitoring UI |
| **Jaeger UI** | http://localhost:16686 | Distributed tracing |
| **Qdrant** | http://localhost:6333 | Qdrant vector DB |
| **Milvus** | http://localhost:19530 | Milvus vector DB |

---

## 📖 API Reference

### Health Check
```http
GET /health
```

**Response:**
```json
{
  "status": "up",
  "backend_status": {
    "qdrant": true,
    "milvus": true,
    "weaviate": true
  },
  "metrics": {
    "total_requests": 1523,
    "avg_latency_ms": 12.5,
    "current_rps": 45.2
  }
}
```

### Vector Search
```http
POST /v1/search
Content-Type: application/json
```

**Request:**
```json
{
  "collection": "documents",
  "vector": [0.1, 0.2, 0.3, ...],
  "topK": 10
}
```

**Response:**
```json
{
  "results": [
    {
      "source": "qdrant",
      "data": { "id": "doc1", "score": 0.95, ... }
    },
    {
      "source": "milvus", 
      "data": { "id": "doc2", "score": 0.89, ... }
    }
  ],
  "latency_ms": 15
}
```

### Ping
```http
GET /v1/ping
```
Returns: `pong`

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     VectorHub Gateway                        │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │  Router  │──│  Circuit │──│  Cache   │──│  Rate    │    │
│  │          │  │  Breaker │  │  (Redis) │  │  Limiter │    │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘    │
├─────────────────────────────────────────────────────────────┤
│                    Connection Pool                           │
├──────────────┬──────────────┬───────────────────────────────┤
│    Qdrant    │    Milvus    │    Weaviate                   │
│   :6333      │    :19530    │    :8080                      │
└──────────────┴──────────────┴───────────────────────────────┘
```

**Tech Stack:**
- **Backend:** Ballerina (Cloud-native integration language)
- **Frontend:** Next.js 16, TypeScript, Recharts, Framer Motion
- **Caching:** Redis
- **Tracing:** Jaeger (OpenTelemetry)
- **Metrics:** Prometheus-compatible

---

## 🛠 Development

### Backend Development
```bash
cd backend
bal build
bal run
```

### Frontend Development
```bash
cd frontend
npm install
npm run dev
```

### Configuration

The gateway reads configuration from `gateway-config.toml`:

```toml
[gateway]
port = 8080
workers = 8
maxConnections = 1000

[backends.qdrant]
urls = ["http://qdrant:6333"]
timeout = 5000
weight = 2

[backends.milvus]
urls = ["http://milvus:19530"]
timeout = 5000
weight = 1
```

---

## ☸️ Deployment

### Docker Compose (Recommended)
```bash
docker-compose -f deployments/docker-compose.yml up -d
```

### Kubernetes
```bash
kubectl apply -f deployments/k8s/
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_HOST` | `localhost` | Redis server hostname |
| `GATEWAY_HOST` | `localhost` | Gateway host for frontend proxy |
| `GATEWAY_PORT` | `8080` | Gateway port |

---

## 📊 Monitoring

The dashboard provides real-time visualization of:
- **System Status** - Overall gateway health
- **Backend Health** - Individual vector DB status
- **Traffic Metrics** - RPS, latency, error rates
- **Historical Charts** - Request trends over time

Access the dashboard at: **http://localhost:3000**

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <sub>Built with ❤️ using Ballerina & Next.js</sub>
</div>
