import Link from 'next/link';

export default function Sidebar() {
  return (
    <aside className="w-64 bg-gray-900 text-white min-h-screen p-4">
      <div className="mb-8">
        <h1 className="text-2xl font-bold bg-gradient-to-r from-blue-500 to-purple-500 bg-clip-text text-transparent">
          VectorHub
        </h1>
        <p className="text-xs text-gray-400">Gateway Dashboard</p>
      </div>
      
      <nav className="space-y-2">
        <Link href="/" className="block px-4 py-2 rounded hover:bg-gray-800 transition-colors">
          Dashboard
        </Link>
        <Link href="/search" className="block px-4 py-2 rounded hover:bg-gray-800 transition-colors">
          Search Console
        </Link>
        <Link href="/settings" className="block px-4 py-2 rounded hover:bg-gray-800 transition-colors">
          Settings
        </Link>
      </nav>
      
      <div className="absolute bottom-4 left-4 text-xs text-gray-500">
        v0.1.0-beta
      </div>
    </aside>
  );
}
