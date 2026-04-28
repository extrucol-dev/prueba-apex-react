import axios from 'axios'
import { APEX_MODE, unwrap } from './utils'
import { apexDashboardApi } from './apexClient'

const API_BASE = import.meta.env.DEV
  ? '/api'
  : import.meta.env.VITE_ORDS_BASE

const http = axios.create({
  baseURL: API_BASE,
  timeout: 10000,
  headers: { Accept: 'application/json' },
})

const ordsGet = async (path, params) => {
  try {
    const { data } = await http.get(`/dashboard${path}`, { params })
    return unwrap(data)
  } catch (err) {
    console.warn(`[dashboardApi] Error en ${path}:`, err.message)
    throw err
  }
}

const apexGet = async (apexFn) => {
  try {
    const data = await apexFn()
    return unwrap(data)
  } catch (err) {
    console.warn('[dashboardApi] Error en proceso APEX:', err.message)
    throw err
  }
}

export const dashboardApi = APEX_MODE
  ? {
      kpis:            ()           => apexGet(apexDashboardApi.kpis),
      ventasMensuales: ()           => apexGet(apexDashboardApi.ventasMensuales),
      topProductos:    (limit = 5)  => apexGet(() => apexDashboardApi.topProductos(limit)),
      ventasCategoria: ()           => apexGet(apexDashboardApi.ventasCategoria),
      ventasRegion:    ()           => apexGet(apexDashboardApi.ventasRegion),
      ultimasVentas:   (limit = 10) => apexGet(() => apexDashboardApi.ultimasVentas(limit)),
    }
  : {
      kpis:            ()           => ordsGet('/kpis'),
      ventasMensuales: ()           => ordsGet('/ventas-mensuales'),
      topProductos:    (limit = 5)  => ordsGet('/top-productos', { limit }),
      ventasCategoria: ()           => ordsGet('/ventas-categoria'),
      ventasRegion:    ()           => ordsGet('/ventas-region'),
      ultimasVentas:   (limit = 10) => ordsGet('/ultimas-ventas', { limit }),
    }
