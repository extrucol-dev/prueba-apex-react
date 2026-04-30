// Normaliza claves UPPERCASE de Oracle a lowercase recursivamente.
export const toLower = (val) => {
  if (Array.isArray(val)) return val.map(toLower)
  if (val !== null && typeof val === 'object') {
    return Object.fromEntries(
      Object.entries(val).map(([k, v]) => [k.toLowerCase(), toLower(v)])
    )
  }
  return val
}

// Extrae el array del envelope de respuesta APEX independientemente de su forma.
// { data: [...] }  |  { items: [...] }  |  { rows: [...] }  |  [...]
export const unwrap = (payload) => {
  if (!payload) return []
  const p = toLower(payload)
  if (Array.isArray(p))       return p
  if (Array.isArray(p.data))  return p.data
  if (Array.isArray(p.items)) return p.items
  if (Array.isArray(p.rows))  return p.rows
  return [p]
}

// Variante para GET de un solo objeto — retorna el primer elemento o null.
export const unwrapOne = (payload) => {
  const arr = unwrap(payload)
  return arr[0] ?? null
}
