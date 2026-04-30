const COP = new Intl.NumberFormat('es-CO', {
  style:                 'currency',
  currency:              'COP',
  minimumFractionDigits: 0,
  maximumFractionDigits: 0,
})

const DATE_LONG  = new Intl.DateTimeFormat('es-CO', { year: 'numeric', month: 'long',  day: 'numeric' })
const DATE_SHORT = new Intl.DateTimeFormat('es-CO', { year: '2-digit', month: '2-digit', day: '2-digit' })
const PCT_FMT    = new Intl.NumberFormat('es-CO', { style: 'percent', maximumFractionDigits: 1 })
const INT_FMT    = new Intl.NumberFormat('es-CO')

// $ 4.812.345
export const fmtCurrency = (n) => COP.format(Number(n) || 0)

// $ 4,8 M  /  $ 450 K  /  $ 980
export const fmtCompact = (n) => {
  const v = Number(n || 0)
  if (v >= 1_000_000) return `$ ${(v / 1_000_000).toFixed(1).replace('.', ',')} M`
  if (v >= 1_000)     return `$ ${Math.round(v / 1_000)} K`
  return fmtCurrency(v)
}

// Alias semántico
export const fmtCompactCurrency = fmtCompact

// 0.75 → "75,0 %"
export const fmtPercent = (n) => PCT_FMT.format(Number(n || 0))

// 1234 → "1.234"
export const fmtInt = (n) => INT_FMT.format(Math.round(Number(n || 0)))

// "2026-04-30" → "30 de abril de 2026"
export const fmtDate = (str) => {
  if (!str) return ''
  return DATE_LONG.format(new Date(str + 'T00:00:00'))
}

// "2026-04-30" → "30/04/26"
export const fmtDateShort = (str) => {
  if (!str) return ''
  return DATE_SHORT.format(new Date(str + 'T00:00:00'))
}
