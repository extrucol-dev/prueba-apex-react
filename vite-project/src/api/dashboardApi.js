import { unwrap } from './utils'
import { apexDashboardApi } from './apexClient'

const apexGet = async (apexFn) => {
  try {
    const data = await apexFn()
    return unwrap(data)
  } catch (err) {
    console.warn('[dashboardApi] Error en proceso APEX:', err.message)
    throw err
  }
}

export const dashboardApi = {
  kpis:            ()           => apexGet(apexDashboardApi.kpis),
  ventasMensuales: ()           => apexGet(apexDashboardApi.ventasMensuales),
  topProductos:    (limit = 5)  => apexGet(() => apexDashboardApi.topProductos(limit)),
  ventasCategoria: ()           => apexGet(apexDashboardApi.ventasCategoria),
  ventasRegion:    ()           => apexGet(apexDashboardApi.ventasRegion),
  ultimasVentas:   (limit = 10) => apexGet(() => apexDashboardApi.ultimasVentas(limit)),
}
