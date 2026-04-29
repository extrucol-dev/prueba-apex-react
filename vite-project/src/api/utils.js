export const toLower = (val) => {
  if (Array.isArray(val)) return val.map(toLower)
  if (val !== null && typeof val === 'object') {
    return Object.fromEntries(
      Object.entries(val).map(([k, v]) => [k.toLowerCase(), toLower(v)])
    )
  }
  return val
}

export const unwrap = (payload) => {
  if (!payload) return null
  const p = toLower(payload)
  if (Array.isArray(p))       return p
  if (Array.isArray(p.data))  return p.data
  if (Array.isArray(p.items)) return p.items
  if (Array.isArray(p.rows))  return p.rows
  return p
}
