import {
  BarChart, Bar, XAxis, YAxis, Tooltip, CartesianGrid, ResponsiveContainer, Cell,
} from 'recharts'
import { fmtCompactCurrency, fmtCurrency } from '../../utils/format'

const COLORS = ['#22d3ee', '#6366f1', '#a855f7', '#f59e0b', '#10b981', '#ef4444']

export default function TopProductosChart({ data }) {
  return (
    <ResponsiveContainer width="100%" height="100%">
      <BarChart data={data} layout="vertical" margin={{ top: 8, right: 16, left: 0, bottom: 0 }}>
        <CartesianGrid stroke="#1f2937" strokeDasharray="3 3" horizontal={false} />
        <XAxis
          type="number"
          stroke="#94a3b8"
          tickLine={false}
          axisLine={false}
          tickFormatter={fmtCompactCurrency}
        />
        <YAxis
          type="category"
          dataKey="nombre"
          stroke="#94a3b8"
          tickLine={false}
          axisLine={false}
          width={140}
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
        <Bar dataKey="ingresos" radius={[0, 8, 8, 0]}>
          {data.map((_, i) => (
            <Cell key={i} fill={COLORS[i % COLORS.length]} />
          ))}
        </Bar>
      </BarChart>
    </ResponsiveContainer>
  )
}
