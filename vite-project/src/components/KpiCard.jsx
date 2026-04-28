export default function KpiCard({ title, value, hint, icon, accent = 'blue', loading }) {
  return (
    <div className={`kpi-card kpi-${accent}`}>
      <div className="kpi-icon" aria-hidden="true">{icon}</div>
      <div className="kpi-body">
        <div className="kpi-title">{title}</div>
        {loading
          ? <div className="kpi-value skeleton skeleton-text" />
          : <div className="kpi-value">{value}</div>}
        {hint && <div className="kpi-hint">{hint}</div>}
      </div>
    </div>
  )
}
