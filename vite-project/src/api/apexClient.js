// Capa de comunicación con Oracle APEX On-Demand Application Processes.
// Usa POST a /apex/wwv_flow.ajax — compatible con APEX 20.1+.
// En desarrollo (VITE_USE_MOCKS=true) cada api.js usa mocks locales
// y esta función nunca se invoca.

export const USE_MOCKS = import.meta.env.VITE_USE_MOCKS === 'true'

const getApexEnv = () => {
  const env = window.apex?.env || {}

  // APEX 20.1 puede exponer APP_ID como número o string.
  // Fallback a los campos ocultos que APEX inyecta en el DOM.
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

  return { appId, pageId, session }
}

export const callProcess = async (processName, extras = {}) => {
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

  if (!res.ok) throw new Error(`APEX [${processName}] HTTP ${res.status}`)
  const text = await res.text()
  return JSON.parse(text)
}

// Devuelve usuario y rol desde window.apex.env.
// En modo mock retorna un ejecutivo de prueba.
export const getSessionInfo = () => {
  if (USE_MOCKS) {
    return { appUser: 'demo@extrucol.com', rol: 'EJECUTIVO', idUsuario: 1 }
  }
  const env = window.apex?.env ?? {}
  const roles = String(env.APP_USER_ROLES ?? '').toUpperCase()
  return {
    appUser:   env.APP_USER ?? '',
    rol:       roles.includes('DIRECTOR') ? 'DIRECTOR'
             : roles.includes('ADMIN')    ? 'ADMIN'
             : roles.includes('COORD')    ? 'COORDINADOR'
             : 'EJECUTIVO',
    idUsuario: Number(env.APP_ID ?? 0),
  }
}
