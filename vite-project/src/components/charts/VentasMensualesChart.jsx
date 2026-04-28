import {
  AreaChart, Area, XAxis, YAxis, Tooltip, CartesianGrid, ResponsiveContainer,
} from 'recharts'
import { fmtCompactCurrency, fmtCurrency } from '../../utils/format'

export default function VentasMensualesChart({ data }) {
  return (
    <ResponsiveContainer width="100%" height="100%">
      <AreaChart data={data} margin={{ top: 10, right: 16, left: 0, bottom: 0 }}>
        <defs>
          <linearGradient id="gradVentas" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%"  stopColor="#6366f1" stopOpacity={0.55} />
            <stop offset="100%" stopColor="#6366f1" stopOpacity={0} />
          </linearGradient>
        </defs>
        <CartesianGrid stroke="#1f2937" strokeDasharray="3 3" vertical={false} />
        <XAxis dataKey="etiqueta" stroke="#94a3b8" tickLine={false} axisLine={false} />
        <YAxis
          stroke="#94a3b8"
          tickLine={false}
          axisLine={false}
          tickFormatter={fmtCompactCurrency}
        />
        <Tooltip
          contentStyle={{
            background: '#0f172a',
            border: '1px solid #1f2937',
            borderRadius: 12,
            color: '#e2e8f0',
          }}
          formatter={(v, name) => name === 'total_ventas'
            ? [fmtCurrency(v), 'Ingresos']
            : [v, name]}
          labelStyle={{ color: '#94a3b8' }}
        />
        <Area
          type="monotone"
          dataKey="total_ventas"
          stroke="#6366f1"
          strokeWidth={2.5}
          fill="url(#gradVentas)"
        />
      </AreaChart>
    </ResponsiveContainer>
  )
}
