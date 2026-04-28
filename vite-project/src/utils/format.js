const currencyFmt = new Intl.NumberFormat('es-MX', {
  style: 'currency',
  currency: 'MXN',
  maximumFractionDigits: 0,
})
const compactFmt = new Intl.NumberFormat('es-MX', {
  notation: 'compact',
  maximumFractionDigits: 1,
})
const intFmt = new Intl.NumberFormat('es-MX')

export const fmtCurrency = (n) => currencyFmt.format(Number(n) || 0)
export const fmtCompact  = (n) => compactFmt.format(Number(n) || 0)
export const fmtInt      = (n) => intFmt.format(Number(n) || 0)
export const fmtCompactCurrency = (n) =>
  '$' + compactFmt.format(Number(n) || 0)
