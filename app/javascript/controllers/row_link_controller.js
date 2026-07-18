import { Controller } from "@hotwired/stimulus"

// Makes a table row clickable without inline handlers (CSP-safe).
export default class extends Controller {
  static values = { url: String }

  visit(event) {
    if (event.target.closest("a, button")) return
    window.Turbo.visit(this.urlValue)
  }
}
