import {
  BarChart, Bar, XAxis, YAxis, Tooltip, CartesianGrid, ResponsiveContainer,
} from 'recharts'
import { fmtCompactCurrency, fmtCurrency } from '../../utils/format'

export default function RegionBarChart({ data }) {
  return (
    <ResponsiveContainer width="100%" height="100%">
      <BarChart data={data} margin={{ top: 8, right: 16, left: 0, bottom: 0 }}>
        <CartesianGrid stroke="#1f2937" strokeDasharray="3 3" vertical={false} />
        <XAxis dataKey="region" stroke="#94a3b8" tickLine={false} axisLine={false} />
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
          formatter={(v) => [fmtCurrency(v), 'Ingresos']}
        />
        <Bar dataKey="ingresos" fill="#22d3ee" radius={[8, 8, 0, 0]} />
      </BarChart>
    </ResponsiveContainer>
  )
}
