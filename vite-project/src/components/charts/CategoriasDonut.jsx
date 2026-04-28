import {
  PieChart, Pie, Cell, ResponsiveContainer, Tooltip, Legend,
} from 'recharts'
import { fmtCurrency } from '../../utils/format'

const COLORS = ['#6366f1', '#22d3ee', '#a855f7', '#f59e0b', '#10b981', '#ef4444']

export default function CategoriasDonut({ data }) {
  return (
    <ResponsiveContainer width="100%" height="100%">
      <PieChart>
        <Pie
          data={data}
          dataKey="ingresos"
          nameKey="categoria"
          innerRadius={60}
          outerRadius={95}
          paddingAngle={2}
          stroke="#0f172a"
          strokeWidth={2}
        >
          {data.map((_, i) => (
            <Cell key={i} fill={COLORS[i % COLORS.length]} />
          ))}
        </Pie>
        <Tooltip
          contentStyle={{
            background: '#0f172a',
            border: '1px solid #1f2937',
            borderRadius: 12,
            color: '#e2e8f0',
          }}
          formatter={(v, n) => [fmtCurrency(v), n]}
        />
        <Legend
          verticalAlign="bottom"
          iconType="circle"
          wrapperStyle={{ color: '#cbd5e1', fontSize: 12 }}
        />
      </PieChart>
    </ResponsiveContainer>
  )
}
