import { Routes, Route, Navigate } from 'react-router-dom'
import { getSessionInfo } from '@/api/apexClient'

// Dashboard placeholder pages (se reemplazarán feature por feature)
import Dashboard from './components/Dashboard'
import ClientesCrud from './components/ClientesCrud'

// Determina la ruta inicial según el rol APEX
function DashboardRoot() {
  const { rol } = getSessionInfo()
  if (rol === 'DIRECTOR')    return <Navigate to="/director/dashboard" replace />
  if (rol === 'ADMIN')       return <Navigate to="/admin/dashboard" replace />
  if (rol === 'COORDINADOR') return <Navigate to="/coordinador/dashboard" replace />
  return <Navigate to="/ejecutivo/dashboard" replace />
}

export default function App() {
  return (
    <Routes>
      {/* Raíz — redirige según rol APEX */}
      <Route path="/"          element={<DashboardRoot />} />
      <Route path="/dashboard" element={<DashboardRoot />} />

      {/* ── Ejecutivo ── */}
      <Route path="/ejecutivo/dashboard"       element={<Dashboard />} />
      <Route path="/ejecutivo/clientes"        element={<ClientesCrud />} />
      <Route path="/ejecutivo/oportunidades"   element={<PlaceholderPage title="Kanban Oportunidades" />} />
      <Route path="/ejecutivo/leads"           element={<PlaceholderPage title="Kanban Leads" />} />
      <Route path="/ejecutivo/actividades"     element={<PlaceholderPage title="Mis Actividades" />} />
      <Route path="/ejecutivo/proyectos"       element={<PlaceholderPage title="Mis Proyectos" />} />
      <Route path="/ejecutivo/metas"           element={<PlaceholderPage title="Mis Metas" />} />

      {/* ── Director ── */}
      <Route path="/director/dashboard"        element={<PlaceholderPage title="Dashboard Director" />} />
      <Route path="/director/pipeline"         element={<PlaceholderPage title="Pipeline Global" />} />
      <Route path="/director/analisis/sectores"    element={<PlaceholderPage title="Análisis por Sectores" />} />
      <Route path="/director/analisis/forecasting" element={<PlaceholderPage title="Forecasting" />} />
      <Route path="/director/equipo"           element={<PlaceholderPage title="Equipo Comercial" />} />
      <Route path="/director/reportes"         element={<PlaceholderPage title="Reportes" />} />

      {/* ── Coordinador ── */}
      <Route path="/coordinador/dashboard"     element={<PlaceholderPage title="Dashboard Coordinador" />} />
      <Route path="/coordinador/estancados"    element={<PlaceholderPage title="Oportunidades Estancadas" />} />
      <Route path="/coordinador/monitoreo"     element={<PlaceholderPage title="Monitoreo" />} />
      <Route path="/coordinador/alertas"       element={<PlaceholderPage title="Alertas" />} />
      <Route path="/coordinador/cumplimiento"  element={<PlaceholderPage title="Cumplimiento" />} />
      <Route path="/coordinador/variables"     element={<PlaceholderPage title="Variables del Sistema" />} />

      {/* ── Admin ── */}
      <Route path="/admin/dashboard"           element={<PlaceholderPage title="Dashboard Admin" />} />
      <Route path="/admin/usuarios"            element={<PlaceholderPage title="Gestión de Usuarios" />} />
      <Route path="/admin/catalogos"           element={<PlaceholderPage title="Catálogos" />} />
      <Route path="/admin/auditoria"           element={<PlaceholderPage title="Auditoría" />} />

      {/* 404 */}
      <Route path="*" element={<Navigate to="/dashboard" replace />} />
    </Routes>
  )
}

function PlaceholderPage({ title }) {
  return (
    <div className="flex items-center justify-center h-64">
      <div className="text-center">
        <h2 className="text-xl font-semibold text-gray-700">{title}</h2>
        <p className="text-sm text-gray-400 mt-2">Página en construcción</p>
      </div>
    </div>
  )
}
