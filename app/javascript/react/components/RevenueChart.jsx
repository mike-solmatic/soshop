import { useState } from "react"

// Dual-series area chart (revenue + order count) drawn as inline SVG.
// props: { data: [{ label, orders, revenue }], currency }
export default function RevenueChart({ data = [], currency = "$" }) {
  const [hover, setHover] = useState(null)

  const W = 720
  const H = 220
  const PAD = { top: 16, right: 16, bottom: 28, left: 48 }
  const innerW = W - PAD.left - PAD.right
  const innerH = H - PAD.top - PAD.bottom

  const maxRevenue = Math.max(...data.map((d) => d.revenue), 1)
  const x = (i) => PAD.left + (data.length > 1 ? (i / (data.length - 1)) * innerW : innerW / 2)
  const y = (v) => PAD.top + innerH - (v / maxRevenue) * innerH

  const linePath = data.map((d, i) => `${i === 0 ? "M" : "L"}${x(i).toFixed(1)},${y(d.revenue).toFixed(1)}`).join(" ")
  const areaPath = `${linePath} L${x(data.length - 1).toFixed(1)},${PAD.top + innerH} L${x(0).toFixed(1)},${PAD.top + innerH} Z`

  const gridLines = [0.25, 0.5, 0.75, 1].map((f) => ({
    y: y(maxRevenue * f),
    label: `${currency}${Math.round(maxRevenue * f).toLocaleString()}`
  }))

  return (
    <div className="chart-wrap">
      <svg
        viewBox={`0 0 ${W} ${H}`}
        role="img"
        aria-label="Revenue for the last 14 days"
        onMouseLeave={() => setHover(null)}
      >
        <defs>
          <linearGradient id="revFill" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor="#635bff" stopOpacity="0.28" />
            <stop offset="100%" stopColor="#635bff" stopOpacity="0.02" />
          </linearGradient>
        </defs>

        {gridLines.map((g, i) => (
          <g key={i}>
            <line x1={PAD.left} x2={W - PAD.right} y1={g.y} y2={g.y} stroke="#e6ebf1" strokeDasharray="3 4" />
            <text x={PAD.left - 8} y={g.y + 4} textAnchor="end" fontSize="10" fill="#8792a2">{g.label}</text>
          </g>
        ))}

        <path d={areaPath} fill="url(#revFill)" />
        <path d={linePath} fill="none" stroke="#635bff" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />

        {data.map((d, i) => (
          <g key={i}>
            {i % 2 === 0 && (
              <text x={x(i)} y={H - 8} textAnchor="middle" fontSize="10" fill="#8792a2">{d.label}</text>
            )}
            <circle
              cx={x(i)}
              cy={y(d.revenue)}
              r={hover === i ? 5 : 3}
              fill="#fff"
              stroke="#635bff"
              strokeWidth="2"
            />
            <rect
              x={x(i) - innerW / data.length / 2}
              y={PAD.top}
              width={innerW / data.length}
              height={innerH}
              fill="transparent"
              onMouseEnter={() => setHover(i)}
            />
          </g>
        ))}

        {hover !== null && data[hover] && (
          <g transform={`translate(${Math.min(Math.max(x(hover) - 60, 8), W - 128)}, ${Math.max(y(data[hover].revenue) - 64, 4)})`}>
            <rect width="120" height="52" rx="8" fill="#0a2540" opacity="0.95" />
            <text x="10" y="18" fontSize="10" fill="#a3bffa">{data[hover].label}</text>
            <text x="10" y="33" fontSize="12" fill="#fff" fontWeight="600">
              {currency}{data[hover].revenue.toLocaleString(undefined, { minimumFractionDigits: 2 })}
            </text>
            <text x="10" y="46" fontSize="10" fill="#8792a2">{data[hover].orders} order{data[hover].orders === 1 ? "" : "s"}</text>
          </g>
        )}
      </svg>
    </div>
  )
}
