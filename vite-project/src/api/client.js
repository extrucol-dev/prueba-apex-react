import axios from 'axios'
import * as mocks from '../mocks/dashboardMocks'
import { apexDashboardApi } from './apexClient'

const USE_MOCKS = String(import.meta.env.VITE_USE_MOCKS) === 'true'
const APEX_MODE = String(import.meta.env.VITE_APEX_MODE) === 'true'

// DEV: Vite proxy reescribe /api -> ORDS (sin seguridad)
// PROD: APEX_MODE=true -> usa On-Demand Processes (sin tocar ORDS)
const API_BASE = import.meta.env.DEV
  ? '/api'
  : import.meta.env.VITE_ORDS_BASE

const http = axios.create({
  baseURL: API_BASE,
  timeout: 10000,
  headers: { Accept: 'application/json' },
})

// APEX_JSON devuelve columnas en MAYUSCULAS. Normalizamos a minusculas.
const toLower = (val) => {
  if (Array.isArray(val)) return val.map(toLower)
  if (val !== null && typeof val === 'object') {
    return Object.fromEntries(
      Object.entries(val).map(([k, v]) => [k.toLowerCase(), toLower(v)])
    )
  }
  return val
}

const unwrap = (payload) => {
  if (!payload) return null
  const p = toLower(payload)
  if (Array.isArray(p.data)) return p.data
  if (p.items) return p.items
  return p
}

// DEV: llama ORDS via proxy Vite
const ordsGet = async (path, mockFn, params) => {
  if (USE_MOCKS) {
    await new Promise((r) => setTimeout(r, 250))
    return mockFn()
  }
  try {
    const { data } = await http.get(`/dashboard${path}`, { params })
    return unwrap(data)
  } catch (err) {
    console.warn(`[api] Fallback a mocks por error en ${path}:`, err.message)
    return mockFn()
  }
}

// PROD: llama APEX On-Demand Process via wwv_flow.ajax
const apexGet = async (apexFn, mockFn) => {
  if (USE_MOCKS) {
    await new Promise((r) => setTimeout(r, 250))
    return mockFn()
  }
  try {
    const data = await apexFn()
    return unwrap(data)
  } catch (err) {
    console.warn('[api] Fallback a mocks por error en proceso APEX:', err.message)
    return mockFn()
  }
}

export const dashboardApi = APEX_MODE
  ? {
      kpis:            ()           => apexGet(apexDashboardApi.kpis,                          mocks.kpis),
      ventasMensuales: ()           => apexGet(apexDashboardApi.ventasMensuales,               mocks.ventasMensuales),
      topProductos:    (limit = 5)  => apexGet(() => apexDashboardApi.topProductos(limit),     mocks.topProductos),
      ventasCategoria: ()           => apexGet(apexDashboardApi.ventasCategoria,               mocks.ventasCategoria),
      ventasRegion:    ()           => apexGet(apexDashboardApi.ventasRegion,                  mocks.ventasRegion),
      ultimasVentas:   (limit = 10) => apexGet(() => apexDashboardApi.ultimasVentas(limit),    () => mocks.ultimasVentas(limit)),
    }
  : {
      kpis:            ()           => ordsGet('/kpis',             mocks.kpis),
      ventasMensuales: ()           => ordsGet('/ventas-mensuales', mocks.ventasMensuales),
      topProductos:    (limit = 5)  => ordsGet('/top-productos',    mocks.topProductos, { limit }),
      ventasCategoria: ()           => ordsGet('/ventas-categoria', mocks.ventasCategoria),
      ventasRegion:    ()           => ordsGet('/ventas-region',    mocks.ventasRegion),
      ultimasVentas:   (limit = 10) => ordsGet('/ultimas-ventas',   () => mocks.ultimasVentas(limit), { limit }),
    }

export { USE_MOCKS, APEX_MODE }
