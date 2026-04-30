import { useEffect, useState, useCallback } from 'react'
import { USE_MOCKS } from '@/api/apexClient'
import { dashboardApi } from '@/features/dashboard/api'
import { fmtCompact, fmtInt } from '@/utils/format'
import { Bar } from 'react-chartjs-2'
import { Chart, BarElement, CategoryScale, LinearScale, Tooltip, Legend } from 'chart.js'

Chart.register(BarElement, CategoryScale, LinearScale, Tooltip, Legend)

export default function Dashboard() {
  const [kpis, setKpis]       = useState(null)
  const [funnel, setFunnel]   = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError]     = useState(null)

  const load = useCallback(async () => {
    setLoading(true); setError(null)
    try {
      const [kpisR, funnelR] = await Promise.all([
        dashboardApi.ejecutivoKpis(1),
        dashboardApi.directorFunnel(),
      ])
      setKpis(kpisR)
      setFunnel(funnelR)
    } catch (e) {
      console.error(e)
      setError('No se pudo cargar el dashboard')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => { load() }, [load])

  const funnelData = {
    labels:   funnel.map(f => f.estado),
    datasets: [{
      label:           'Pipeline ($)',
      data:            funnel.map(f => f.valor),
      backgroundColor: ['#3b82f6', '#f59e0b', '#8b5cf6', '#10b981'],
      borderRadius:    4,
    }],
  }

  return (
    <div className="p-8 max-w-6xl mx-auto">
      {/* Encabezado */}
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Dashboard CRM</h1>
          <p className="text-sm text-gray-500 mt-1">
            Modo: <span className={`font-medium ${USE_MOCKS ? 'text-amber-600' : 'text-green-600'}`}>
              {USE_MOCKS ? 'Mock (desarrollo)' : 'APEX live'}
            </span>
          </p>
        </div>
        <button
          type="button"
          onClick={load}
          disabled={loading}
          className="px-4 py-2 bg-primary text-white text-sm font-medium rounded-md hover:bg-blue-800 disabled:opacity-50 transition-colors"
        >
          {loading ? 'Cargando...' : 'Refrescar'}
        </button>
      </div>

      {error && (
        <div className="mb-4 p-3 bg-red-50 border border-red-200 text-red-700 rounded-md text-sm">{error}</div>
      )}

      {/* KPI Cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
        <KpiCard label="Leads activos"      value={fmtInt(kpis?.leads_activos)}   loading={loading} color="bg-blue-50 border-blue-200 text-blue-700" />
        <KpiCard label="Opp. activas"       value={fmtInt(kpis?.opp_activas)}     loading={loading} color="bg-purple-50 border-purple-200 text-purple-700" />
        <KpiCard label="Pipeline"           value={fmtCompact(kpis?.pipeline_valor)} loading={loading} color="bg-green-50 border-green-200 text-green-700" />
        <KpiCard label="Actividades hoy"    value={fmtInt(kpis?.actividades_hoy)} loading={loading} color="bg-amber-50 border-amber-200 text-amber-700" />
      </div>

      {/* Funnel Chart */}
      <div className="bg-white rounded-lg border border-gray-200 shadow-card p-6">
        <h2 className="text-base font-semibold text-gray-800 mb-4">Pipeline por etapa</h2>
        <div className="relative h-64">
          {loading
            ? <div className="animate-pulse bg-gray-100 rounded h-full" />
            : funnel.length > 0
              ? <Bar data={funnelData} options={{ responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } } }} />
              : <p className="text-center text-gray-400 pt-20">Sin datos</p>
          }
        </div>
      </div>
    </div>
  )
}

function KpiCard({ label, value, loading, color }) {
  return (
    <div className={`border rounded-lg p-4 ${color}`}>
      <p className="text-xs font-medium uppercase tracking-wide opacity-75">{label}</p>
      {loading
        ? <div className="mt-2 h-7 bg-current opacity-20 rounded animate-pulse" />
        : <p className="mt-1 text-2xl font-bold">{value ?? '—'}</p>
      }
    </div>
  )
}
