'use client';

import { useState } from 'react';

export default function SearchPage() {
    const [collection, setCollection] = useState('documents');
    const [vectorInput, setVectorInput] = useState('[0.1, 0.2, 0.3]');
    const [topK, setTopK] = useState(5);
    const [results, setResults] = useState<any>(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');

    const handleSearch = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError('');
        setResults(null);

        try {
            let vector: number[];
            try {
                vector = JSON.parse(vectorInput);
                if (!Array.isArray(vector)) throw new Error('Vector must be an array');
            } catch (err) {
                throw new Error('Invalid vector format. Must be a JSON array of numbers.');
            }

            const res = await fetch('http://localhost:8080/v1/search', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    collection,
                    vector,
                    topK,
                }),
            });

            if (!res.ok) {
                const err = await res.json();
                throw new Error(err.error || 'Search failed');
            }

            const data = await res.json();
            setResults(data);
        } catch (err: any) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="space-y-8 max-w-4xl mx-auto">
            <header>
                <h2 className="text-3xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
                    Vector Search Console
                </h2>
                <p className="text-gray-400 mt-2">Test vector search queries against all configured backends.</p>
            </header>

            <form onSubmit={handleSearch} className="bg-gray-900 rounded-xl p-6 border border-gray-800 space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label className="block text-sm font-medium text-gray-400 mb-1">Collection Name</label>
                        <input
                            type="text"
                            value={collection}
                            onChange={(e) => setCollection(e.target.value)}
                            className="w-full bg-gray-800 border-gray-700 rounded-lg px-4 py-2 text-white focus:ring-2 focus:ring-blue-500 outline-none"
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-400 mb-1">Top K</label>
                        <input
                            type="number"
                            value={topK}
                            onChange={(e) => setTopK(Number(e.target.value))}
                            className="w-full bg-gray-800 border-gray-700 rounded-lg px-4 py-2 text-white focus:ring-2 focus:ring-blue-500 outline-none"
                        />
                    </div>
                </div>

                <div>
                    <label className="block text-sm font-medium text-gray-400 mb-1">Query Vector (JSON Array)</label>
                    <textarea
                        value={vectorInput}
                        onChange={(e) => setVectorInput(e.target.value)}
                        rows={3}
                        className="w-full bg-gray-800 border-gray-700 rounded-lg px-4 py-2 text-white font-mono text-sm focus:ring-2 focus:ring-blue-500 outline-none"
                    />
                </div>

                <button
                    type="submit"
                    disabled={loading}
                    className="w-full bg-blue-600 hover:bg-blue-500 text-white font-semibold py-2 px-4 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                    {loading ? 'Searching...' : 'Run Search'}
                </button>

                {error && (
                    <div className="p-4 bg-red-900/50 border border-red-800 rounded-lg text-red-200">
                        {error}
                    </div>
                )}
            </form>

            {results && (
                <div className="bg-gray-900 rounded-xl p-6 border border-gray-800">
                    <h3 className="text-xl font-semibold mb-4 text-white">Results</h3>
                    <pre className="bg-black/50 p-4 rounded-lg overflow-x-auto font-mono text-sm text-green-400">
                        {JSON.stringify(results, null, 2)}
                    </pre>
                </div>
            )}
        </div>
    );
}
