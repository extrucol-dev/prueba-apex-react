// Cliente para llamar a APEX On-Demand Application Processes.
// Usa POST a wwv_flow.ajax — compatible con APEX 20.1.

const getApexEnv = () => {
  const env = window.apex?.env || {}

  // APEX 20.1 puede exponer APP_ID como numero o string.
  // Fallback a los campos ocultos que APEX siempre inyecta en el DOM.
  const appId = String(env.APP_ID || '')
             || document.querySelector('[name="p_flow_id"]')?.value
             || document.querySelector('#pFlowId')?.value
             || ''

  const pageId = String(env.APP_PAGE_ID || '')
              || document.querySelector('[name="p_flow_step_id"]')?.value
              || document.querySelector('#pFlowStepId')?.value
              || '0'

  const session = String(env.APP_SESSION || '')
               || document.querySelector('[name="p_instance"]')?.value
               || document.querySelector('#pInstance')?.value
               || ''

  console.log('[apexEnv]', { appId, pageId, session, rawEnv: env })
  return { appId, pageId, session }
}

const callProcess = async (processName, extras = {}) => {
  const { appId, pageId, session } = getApexEnv()

  const body = new URLSearchParams({
    p_request:      `APPLICATION_PROCESS=${processName}`,
    p_flow_id:      appId,
    p_flow_step_id: pageId,
    p_instance:     session,
  })

  Object.entries(extras).forEach(([k, v]) => {
    if (v !== undefined && v !== null) body.append(k, String(v))
  })

  const res = await fetch('/apex/wwv_flow.ajax', {
    method:      'POST',
    body,
    credentials: 'include',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept':       'application/json',
    },
  })

  if (!res.ok) throw new Error(`APEX process ${processName} HTTP ${res.status}`)
  const text = await res.text()
  console.log(`[apexClient] ${processName} raw:`, text)
  return JSON.parse(text)
}

// ---- Dashboard (solo lectura) ----
export const apexDashboardApi = {
  kpis:            ()           => callProcess('DASH_KPIS'),
  ventasMensuales: ()           => callProcess('DASH_VENTAS_MENSUALES'),
  topProductos:    (limit = 5)  => callProcess('DASH_TOP_PRODUCTOS',  { x01: limit }),
  ventasCategoria: ()           => callProcess('DASH_VENTAS_CATEGORIA'),
  ventasRegion:    ()           => callProcess('DASH_VENTAS_REGION'),
  ultimasVentas:   (limit = 10) => callProcess('DASH_ULTIMAS_VENTAS', { x01: limit }),
}

// ---- Clientes (CRUD completo) ----
export const apexClientesApi = {
  list:   ()     => callProcess('CLIENTES_LIST'),
  create: (data) => callProcess('CLIENTES_CREATE', {
    x01: data.nombre,
    x02: data.email,
    x03: data.ciudad,
    x04: data.pais,
  }),
  update: (data) => callProcess('CLIENTES_UPDATE', {
    x01: data.id,
    x02: data.nombre,
    x03: data.email,
    x04: data.ciudad,
    x05: data.pais,
  }),
  delete: (id) => callProcess('CLIENTES_DELETE', { x01: id }),
}
