// Mounts React components into any element rendered with the
// `react_component` view helper: <div data-react-component="Name" data-props="{...}">
import { createRoot } from "react-dom/client"
import RevenueChart from "./components/RevenueChart"
import DataTable from "./components/DataTable"

const REGISTRY = { RevenueChart, DataTable }
let roots = []

function mountAll() {
  document.querySelectorAll("[data-react-component]").forEach((el) => {
    if (el.dataset.reactMounted === "true") return
    const Component = REGISTRY[el.dataset.reactComponent]
    if (!Component) return
    el.dataset.reactMounted = "true"
    const props = el.dataset.props ? JSON.parse(el.dataset.props) : {}
    const root = createRoot(el)
    root.render(<Component {...props} />)
    roots.push({ el, root })
  })
}

// Unmount before Turbo snapshots the page so cached pages re-mount cleanly.
function unmountAll() {
  roots.forEach(({ el, root }) => {
    root.unmount()
    delete el.dataset.reactMounted
  })
  roots = []
}

document.addEventListener("turbo:load", mountAll)
document.addEventListener("turbo:before-cache", unmountAll)
