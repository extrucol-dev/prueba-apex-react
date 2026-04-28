export default function ChartCard({ title, subtitle, action, children, height = 300, loading }) {
  return (
    <section className="chart-card">
      <header className="chart-head">
        <div>
          <h3>{title}</h3>
          {subtitle && <p className="chart-sub">{subtitle}</p>}
        </div>
        {action}
      </header>
      <div className="chart-body" style={{ height }}>
        {loading
          ? <div className="skeleton skeleton-chart" />
          : children}
      </div>
    </section>
  )
}
