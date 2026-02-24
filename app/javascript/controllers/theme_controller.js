import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "pokeapi-theme"

export default class extends Controller {
  static targets = ["label", "icon", "toggle"]

  connect() {
    this.applyInitialTheme()
  }

  toggle() {
    const next = this.currentTheme() === "dark" ? "light" : "dark"
    this.applyTheme(next)
  }

  applyInitialTheme() {
    const stored = this.readStoredTheme()
    if (stored) {
      this.applyTheme(stored)
      return
    }

    const prefersDark = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches
    this.applyTheme(prefersDark ? "dark" : "light")
  }

  applyTheme(theme) {
    const isDark = theme === "dark"
    document.documentElement.classList.toggle("dark", isDark)
    document.documentElement.dataset.theme = theme
    this.writeStoredTheme(theme)
    this.updateLabel(theme)
  }

  updateLabel(theme) {
    const nextLabel = theme === "dark" ? "Switch to Light" : "Switch to Dark"

    if (this.hasLabelTarget) {
      this.labelTarget.textContent = nextLabel
    }

    if (this.hasIconTarget) {
      this.iconTarget.textContent = theme === "dark" ? "☀︎" : "☾"
    }

    if (this.hasToggleTarget) {
      this.toggleTarget.setAttribute("aria-label", nextLabel)
      this.toggleTarget.setAttribute("title", nextLabel)
    }
  }

  currentTheme() {
    return document.documentElement.classList.contains("dark") ? "dark" : "light"
  }

  readStoredTheme() {
    try {
      const value = window.localStorage.getItem(STORAGE_KEY)
      return value === "dark" || value === "light" ? value : null
    } catch (_error) {
      return null
    }
  }

  writeStoredTheme(theme) {
    try {
      window.localStorage.setItem(STORAGE_KEY, theme)
    } catch (_error) {
      // Ignore storage errors (private mode / disabled storage).
    }
  }
}
