import { fmtCurrency } from '../utils/format'

const badgeFor = (estado) => {
  switch (estado) {
    case 'PAGADA':    return 'badge badge-green'
    case 'PENDIENTE': return 'badge badge-amber'
    case 'CANCELADA': return 'badge badge-red'
    default:          return 'badge'
  }
}

export default function UltimasVentasTable({ data, loading }) {
  if (loading) {
    return (
      <div className="table-skeleton">
        {Array.from({ length: 6 }).map((_, i) => (
          <div key={i} className="skeleton skeleton-row" />
        ))}
      </div>
    )
  }
  return (
    <div className="table-wrap">
      <table className="ventas-table">
        <thead>
          <tr>
            <th>#</th>
            <th>Fecha</th>
            <th>Cliente</th>
            <th>Vendedor</th>
            <th>Region</th>
            <th className="num">Total</th>
            <th>Estado</th>
          </tr>
        </thead>
        <tbody>
          {data.map((v) => (
            <tr key={v.id}>
              <td className="muted">{v.id}</td>
              <td>{v.fecha}</td>
              <td>{v.cliente}</td>
              <td>{v.vendedor}</td>
              <td>{v.region}</td>
              <td className="num">{fmtCurrency(v.total)}</td>
              <td><span className={badgeFor(v.estado)}>{v.estado}</span></td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
