import { useState } from 'react'
import Dashboard from './components/Dashboard'
import ClientesCrud from './components/ClientesCrud'
import './App.css'

const NAV = [
  { id: 'dashboard', label: 'Dashboard' },
  { id: 'clientes',  label: 'Clientes'  },
]

export default function App() {
  const [view, setView] = useState('dashboard')

  return (
    <div className="app-shell">
      <aside className="app-side">
        <div className="brand">
          <span className="brand-dot" />
          <span>APEX/React</span>
        </div>
        <nav className="nav">
          {NAV.map(n => (
            <a
              key={n.id}
              className={`nav-item ${view === n.id ? 'active' : ''}`}
              onClick={() => setView(n.id)}
            >
              {n.label}
            </a>
          ))}
        </nav>
        <div className="side-foot">
          <small>v0.1 demo</small>
        </div>
      </aside>

      <main className="app-main">
        {view === 'dashboard' && <Dashboard />}
        {view === 'clientes'  && <ClientesCrud />}
      </main>
    </div>
  )
}
