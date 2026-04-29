import { toLower } from './utils'
import { apexClientesApi } from './apexClient'

const fromApex = (raw) => {
  const p = toLower(raw)
  return Array.isArray(p?.data) ? p.data : p
}

export const clientesApi = {
  list:   ()     => apexClientesApi.list().then(fromApex),
  create: (data) => apexClientesApi.create(data).then(toLower),
  update: (data) => apexClientesApi.update(data).then(toLower),
  delete: (id)   => apexClientesApi.delete(id).then(toLower),
}
