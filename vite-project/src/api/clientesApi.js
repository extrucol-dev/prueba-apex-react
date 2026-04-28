import { apexClientesApi } from './apexClient'
import { clientesMocks } from '../mocks/clientesMocks'

const USE_MOCKS = String(import.meta.env.VITE_USE_MOCKS) === 'true'
const APEX_MODE = String(import.meta.env.VITE_APEX_MODE) === 'true'

const toLower = (val) => {
  if (Array.isArray(val)) return val.map(toLower)
  if (val !== null && typeof val === 'object') {
    return Object.fromEntries(
      Object.entries(val).map(([k, v]) => [k.toLowerCase(), toLower(v)])
    )
  }
  return val
}

const fromApex = (raw) => {
  const p = toLower(raw)
  return Array.isArray(p?.data) ? p.data : p
}

// En dev (APEX_MODE=false) siempre usa mocks — no hay ORDS para CRUD.
// En prod (APEX_MODE=true) llama los On-Demand Processes.
const useApex = APEX_MODE && !USE_MOCKS

export const clientesApi = {
  list: () =>
    useApex
      ? apexClientesApi.list().then(fromApex)
      : clientesMocks.list(),

  create: (data) =>
    useApex
      ? apexClientesApi.create(data).then(toLower)
      : clientesMocks.create(data),

  update: (data) =>
    useApex
      ? apexClientesApi.update(data).then(toLower)
      : clientesMocks.update(data),

  delete: (id) =>
    useApex
      ? apexClientesApi.delete(id).then(toLower)
      : clientesMocks.delete(id),
}
