import { useEffect, useState, useCallback } from 'react'
import { dashboardApi } from '../api/dashboardApi'
import { APEX_MODE } from '../api/utils'
import { fmtCurrency, fmtInt } from '../utils/format'
import KpiCard from './KpiCard'
import ChartCard from './ChartCard'
import VentasMensualesChart from './charts/VentasMensualesChart'
import TopProductosChart from './charts/TopProductosChart'
import CategoriasDonut from './charts/CategoriasDonut'
import RegionBarChart from './charts/RegionBarChart'
import UltimasVentasTable from './UltimasVentasTable'

const initial = {
  kpis: null,
  mensual: [],
  productos: [],
  categorias: [],
  regiones: [],
  ventas: [],
}

export default function Dashboard() {
  const [data, setData]       = useState(initial)
  const [loading, setLoading] = useState(true)
  const [error, setError]     = useState(null)
  const [updatedAt, setUpd]   = useState(null)

  const load = useCallback(async () => {
    setLoading(true); setError(null)
    try {
      const [kpisR, mensualR, productosR, categoriasR, regionesR, ventasR] = await Promise.all([
        dashboardApi.kpis(),
        dashboardApi.ventasMensuales(),
        dashboardApi.topProductos(5),
        dashboardApi.ventasCategoria(),
        dashboardApi.ventasRegion(),
        dashboardApi.ultimasVentas(10),
      ])
      setData({
        kpis:       Array.isArray(kpisR) ? kpisR[0] : kpisR,
        mensual:    mensualR    || [],
        productos:  productosR  || [],
        categorias: categoriasR || [],
        regiones:   regionesR   || [],
        ventas:     ventasR     || [],
      })
      setUpd(new Date())
    } catch (e) {
      console.error(e)
      setError('No se pudo cargar el dashboard')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => { load() }, [load])

  const k = data.kpis || {}

  return (
    <div className="dash">
      <header className="dash-header">
        <div>
          <h1>Dashboard de Ventas</h1>
          <p className="dash-sub">
            APEX -&gt; React (Vite) -&gt; ORDS -&gt; PL/SQL -&gt; Oracle
            <span className={`source-pill ${APEX_MODE ? 'apex' : 'live'}`}>
              {APEX_MODE ? 'APEX live' : 'ORDS live'}
            </span>
          </p>
        </div>
        <div className="dash-actions">
          {updatedAt && (
            <span className="muted">
              Actualizado {updatedAt.toLocaleTimeString('es-MX')}
            </span>
          )}
          <button type="button" className="btn" onClick={load} disabled={loading}>
            {loading ? 'Cargando...' : 'Refrescar'}
          </button>
        </div>
      </header>

      {error && <div className="alert">{error}</div>}

      {/* ----- KPIs ----- */}
      <section className="kpi-grid">
        <KpiCard
          title="Ingresos totales"
          value={fmtCurrency(k.ingresos_total)}
          hint="Solo ventas pagadas"
          icon="$"
          accent="indigo"
          loading={loading}
        />
        <KpiCard
          title="Ingresos del mes"
          value={fmtCurrency(k.ingresos_mes)}
          hint="Mes en curso"
          icon="^"
          accent="cyan"
          loading={loading}
        />
        <KpiCard
          title="Ventas totales"
          value={fmtInt(k.num_ventas)}
          hint={`Hoy: ${fmtInt(k.ventas_hoy)}`}
          icon="#"
          accent="emerald"
          loading={loading}
        />
        <KpiCard
          title="Ticket promedio"
          value={fmtCurrency(k.ticket_promedio)}
          hint={`${fmtInt(k.ventas_pendientes)} pendientes`}
          icon="~"
          accent="amber"
          loading={loading}
        />
        <KpiCard
          title="Clientes"
          value={fmtInt(k.num_clientes)}
          hint="Catalogo activo"
          icon="@"
          accent="violet"
          loading={loading}
        />
        <KpiCard
          title="Productos"
          value={fmtInt(k.num_productos)}
          hint="Activos"
          icon="*"
          accent="rose"
          loading={loading}
        />
      </section>

      {/* ----- CHARTS ROW 1 ----- */}
      <section className="grid-2">
        <ChartCard
          title="Ingresos mensuales"
          subtitle="Ultimos 12 meses (ventas pagadas)"
          height={320}
          loading={loading}
        >
          <VentasMensualesChart data={data.mensual} />
        </ChartCard>

        <ChartCard
          title="Por categoria"
          subtitle="Participacion de ingresos"
          height={320}
          loading={loading}
        >
          <CategoriasDonut data={data.categorias} />
        </ChartCard>
      </section>

      {/* ----- CHARTS ROW 2 ----- */}
      <section className="grid-2">
        <ChartCard
          title="Top 5 productos"
          subtitle="Por ingresos"
          height={300}
          loading={loading}
        >
          <TopProductosChart data={data.productos} />
        </ChartCard>

        <ChartCard
          title="Ventas por region"
          subtitle="Aportacion por equipo comercial"
          height={300}
          loading={loading}
        >
          <RegionBarChart data={data.regiones} />
        </ChartCard>
      </section>

      {/* ----- TABLA ----- */}
      <ChartCard
        title="Ultimas ventas"
        subtitle="10 movimientos mas recientes"
        height="auto"
        loading={false}
      >
        <UltimasVentasTable data={data.ventas} loading={loading} />
      </ChartCard>

      <footer className="dash-footer">
        <span>Demo APEX + React + ORDS</span>
      </footer>
    </div>
  )
}
