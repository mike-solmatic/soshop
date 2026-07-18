import { useMemo, useState } from "react"

// Searchable, sortable, paginated table.
// props: {
//   columns: [{ key, label, type: "text"|"money"|"badge"|"avatar"|"date", align }],
//   rows:    [{ ...values, href?, avatar_url?, badge_tones?: { key: tone } }],
//   searchPlaceholder, emptyMessage, perPage
// }
const BADGE_TONES = {
  green: { bg: "#d7f7c2", fg: "#05690d" },
  blue: { bg: "#cff5f6", fg: "#0055bc" },
  purple: { bg: "#e0e3ff", fg: "#4b3fd4" },
  orange: { bg: "#fcedb9", fg: "#a05a00" },
  red: { bg: "#ffe7f2", fg: "#b3063d" },
  gray: { bg: "#ebeef1", fg: "#545a69" }
}

function initials(name) {
  return (name || "?").split(/\s+/).slice(0, 2).map((w) => w[0]).join("").toUpperCase()
}

function Cell({ column, row }) {
  const value = row[column.key]
  switch (column.type) {
    case "money":
      return <span className="dt-money">{value}</span>
    case "badge": {
      const tone = BADGE_TONES[(row.badge_tones || {})[column.key]] || BADGE_TONES.gray
      return <span className="dt-badge" style={{ backgroundColor: tone.bg, color: tone.fg }}>{value}</span>
    }
    case "avatar":
      return (
        <span className="dt-avatar-cell">
          {row.avatar_url
            ? <img src={row.avatar_url} alt="" className="dt-avatar" referrerPolicy="no-referrer" />
            : <span className="dt-avatar dt-avatar-fallback">{initials(value)}</span>}
          <span className="dt-avatar-name">{value}</span>
        </span>
      )
    default:
      return <span>{value}</span>
  }
}

export default function DataTable({ columns = [], rows = [], searchPlaceholder = "Search…", emptyMessage = "Nothing here yet.", perPage = 10 }) {
  const [query, setQuery] = useState("")
  const [sort, setSort] = useState(null) // { key, dir }
  const [page, setPage] = useState(0)

  const filtered = useMemo(() => {
    let out = rows
    if (query.trim()) {
      const q = query.trim().toLowerCase()
      out = out.filter((r) => columns.some((c) => String(r[c.key] ?? "").toLowerCase().includes(q)))
    }
    if (sort) {
      out = [...out].sort((a, b) => {
        const av = a[`${sort.key}_sort`] ?? a[sort.key] ?? ""
        const bv = b[`${sort.key}_sort`] ?? b[sort.key] ?? ""
        const cmp = typeof av === "number" && typeof bv === "number" ? av - bv : String(av).localeCompare(String(bv))
        return sort.dir === "asc" ? cmp : -cmp
      })
    }
    return out
  }, [rows, columns, query, sort])

  const pages = Math.max(1, Math.ceil(filtered.length / perPage))
  const current = Math.min(page, pages - 1)
  const visible = filtered.slice(current * perPage, (current + 1) * perPage)

  const toggleSort = (key) => {
    setSort((s) => (s?.key === key ? (s.dir === "asc" ? { key, dir: "desc" } : null) : { key, dir: "asc" }))
  }

  return (
    <div className="dt">
      <div className="dt-toolbar">
        <div className="dt-search">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" aria-hidden="true">
            <circle cx="11" cy="11" r="7" stroke="currentColor" strokeWidth="2" />
            <path d="M20 20l-3.5-3.5" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
          </svg>
          <input
            type="search"
            value={query}
            placeholder={searchPlaceholder}
            onChange={(e) => { setQuery(e.target.value); setPage(0) }}
            aria-label={searchPlaceholder}
          />
        </div>
        <span className="dt-count">{filtered.length} result{filtered.length === 1 ? "" : "s"}</span>
      </div>

      <div className="dt-scroll">
        <table>
          <thead>
            <tr>
              {columns.map((c) => (
                <th key={c.key} style={{ textAlign: c.align || "left" }}>
                  <button type="button" className="dt-sort" onClick={() => toggleSort(c.key)}>
                    {c.label}
                    {sort?.key === c.key && <span aria-hidden="true">{sort.dir === "asc" ? " ▲" : " ▼"}</span>}
                  </button>
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {visible.length === 0 && (
              <tr><td colSpan={columns.length} className="dt-empty">{emptyMessage}</td></tr>
            )}
            {visible.map((row, i) => (
              <tr
                key={row.id ?? i}
                className={row.href ? "dt-row-link" : undefined}
                onClick={row.href ? () => { window.Turbo ? window.Turbo.visit(row.href) : (window.location = row.href) } : undefined}
              >
                {columns.map((c) => (
                  <td key={c.key} style={{ textAlign: c.align || "left" }}>
                    <Cell column={c} row={row} />
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {pages > 1 && (
        <div className="dt-pagination">
          <button type="button" disabled={current === 0} onClick={() => setPage(current - 1)}>← Prev</button>
          <span>Page {current + 1} of {pages}</span>
          <button type="button" disabled={current >= pages - 1} onClick={() => setPage(current + 1)}>Next →</button>
        </div>
      )}
    </div>
  )
}
