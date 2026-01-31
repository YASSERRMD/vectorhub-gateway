# VectorHub Gateway

VectorHub Gateway is a high-performance, unified API gateway for managing and querying multiple vector databases (Qdrant, Milvus, Weaviate). Built with [Ballerina](https://ballerina.io) for the backend and [Next.js](https://nextjs.org) for the dashboard, it provides intelligent routing, request deduplication, circuit breaking, and caching.

## 🚀 Features

- **Unified API**: Single endpoint (`/v1/search`) to query multiple vector DBs.
- **Intelligent Routing**: Route requests based on availability or strategy (Latency, Round-Robin).
- **Circuit Breaker**: Automatically detect and isolate failing backends.
- **Caching & Deduplication**: Redis-based caching to prevent redundant computations.
- **Rate Limiting**: Protect your resources with token-bucket rate limiting.
- **Response Aggregation**: Merge results from multiple sources (Scatter-Gather).
- **Observability**: Built-in support for Jaeger tracing and Prometheus metrics.

## 🏗 Architecture

- **Backend**: Ballerina (Cloud-native integration language)
- **Frontend**: Next.js 14, TailwindCSS, TypeScript
- **Caching**: Redis
- **Databases**: Qdrant, Milvus, Weaviate

## 🛠 Getting Started

### Prerequisites

- Docker & Docker Compose
- Ballerina 2201.x (Swan Lake) [Optional for dev]
- Node.js 18+ [Optional for dev]

### Quick Start (Docker Compose)

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/vectorhub-gateway.git
   cd vectorhub-gateway
   ```

2. Start the infrastructure:
   ```bash
   docker-compose -f deployments/docker-compose.yml up -d
   ```
   This will start Qdrant, Milvus (standalone), Weaviate, Redis, Jaeger, and Prometheus.

3. Run the Backend:
   ```bash
   cd backend
   bal run
   # Gateway runs on :8080
   ```

4. Run the Frontend:
   ```bash
   cd frontend
   npm install
   npm run dev
   # Dashboard runs on :3000
   ```

## 📖 API Reference

### Health Check
**GET** `/health`
```json
{
  "status": "ok",
  "backend_status": {
    "qdrant": "UP",
    "milvus": "UP",
    "weaviate": "UP"
  }
}
```

### Vector Search
**POST** `/v1/search`

Payload:
```json
{
  "collection": "documents",
  "vector": [0.1, 0.2, 0.3, ...],
  "topK": 5
}
```

Response:
```json
[
  {
    "source": "qdrant",
    "data": { ... }
  },
  {
    "source": "milvus",
    "data": { ... }
  }
]
```

## ☸️ Kubernetes Deployment

Manifests are available in `deployments/k8s/`.

```bash
kubectl apply -f deployments/k8s/
```

## 📄 License
MIT
