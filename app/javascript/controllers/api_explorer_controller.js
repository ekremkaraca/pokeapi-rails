import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "basePrefix",
    "emptyHistory",
    "headerLine",
    "history",
    "jsonOutput",
    "jsonTree",
    "openLink",
    "pathInput",
    "rawToggle",
    "resolvedUrl",
    "samples",
    "statusLine",
    "versionInput"
  ]

  static values = {
    v2Samples: String,
    v3Samples: String
  }

  connect() {
    this.recent = []
    this.renderSamples()
    this.syncUi()
    this.jsonTreeTarget.textContent = 'Press "Fetch JSON" to load data.'
    this.jsonOutputTarget.textContent = ""
  }

  versionChanged() {
    this.renderSamples()
    this.syncUi()
  }

  submit(event) {
    event.preventDefault()
    this.fetchJson()
  }

  async copyUrl() {
    const url = this.currentUrl()
    try {
      await navigator.clipboard.writeText(url)
      this.statusLineTarget.textContent = "Copied URL"
    } catch (_error) {
      this.statusLineTarget.textContent = "Clipboard unavailable"
    }
  }

  useSample(event) {
    const path = event.currentTarget.dataset.path || ""
    this.pathInputTarget.value = path
    this.syncUi()
  }

  async fetchJson() {
    const url = this.currentUrl()
    const startedAt = performance.now()

    this.statusLineTarget.textContent = "Loading..."
    this.resolvedUrlTarget.textContent = url

    try {
      const response = await fetch(url, {
        headers: { Accept: "application/json" }
      })
      const elapsedMs = (performance.now() - startedAt).toFixed(1)
      const bodyText = await response.text()
      const parsed = this.parseBody(bodyText)

      this.statusLineTarget.textContent = `${response.status} ${response.statusText} in ${elapsedMs}ms`
      this.headerLineTarget.textContent = this.compactHeaders(response)
      this.renderJson(parsed)
      this.pushHistory({
        url,
        status: response.status,
        elapsedMs,
        queryCount: response.headers.get("x-query-count"),
        responseTimeMs: response.headers.get("x-response-time-ms")
      })
    } catch (error) {
      this.statusLineTarget.textContent = "Network Error"
      this.headerLineTarget.textContent = "-"
      this.renderJson({ error: "Failed to fetch endpoint", details: error.message })
      this.pushHistory({ url, status: "ERR", elapsedMs: "-", queryCount: null, responseTimeMs: null })
    }
  }

  clearHistory() {
    this.recent = []
    this.renderHistory()
  }

  reuseHistory(event) {
    const path = event.currentTarget.dataset.path || ""
    const version = event.currentTarget.dataset.version || "v2"

    this.versionInputTargets.forEach((input) => {
      input.checked = input.value === version
    })
    this.pathInputTarget.value = path
    this.renderSamples()
    this.syncUi()
  }

  currentVersion() {
    const active = this.versionInputTargets.find((input) => input.checked)
    return active ? active.value : "v2"
  }

  currentPath() {
    return this.pathInputTarget.value.trim().replace(/^\/+/, "")
  }

  currentUrl() {
    return `/api/${this.currentVersion()}/${this.currentPath()}`
  }

  renderSamples() {
    const paths = this.samplePathsFor(this.currentVersion())
    this.samplesTarget.replaceChildren()

    paths.forEach((path) => {
      const button = document.createElement("button")
      button.type = "button"
      button.dataset.action = "api-explorer#useSample"
      button.dataset.path = path
      button.className = "rounded-full border border-cyan-300 bg-cyan-50 px-3 py-1 text-xs font-semibold text-cyan-900 hover:bg-cyan-100 dark:border-cyan-700 dark:bg-cyan-950/50 dark:text-cyan-200 dark:hover:bg-cyan-900/60"
      button.textContent = path
      this.samplesTarget.appendChild(button)
    })

    if (paths.length > 0 && !this.pathInputTarget.value.trim()) {
      this.pathInputTarget.value = paths[0]
    }
  }

  syncUi() {
    const base = `/api/${this.currentVersion()}/`
    const url = this.currentUrl()
    this.basePrefixTarget.textContent = base
    this.resolvedUrlTarget.textContent = url
    this.openLinkTarget.href = url
    this.openLinkTarget.textContent = `Open ${this.currentVersion().toUpperCase()}`
  }

  samplePathsFor(version) {
    const raw = version === "v3" ? this.v3SamplesValue : this.v2SamplesValue
    return raw.split("|").map((sample) => sample.trim()).filter(Boolean)
  }

  parseBody(text) {
    if (!text || text.trim().length === 0) {
      return {}
    }

    try {
      return JSON.parse(text)
    } catch (_error) {
      return { raw: text }
    }
  }

  compactHeaders(response) {
    const entries = [
      ["content-type", response.headers.get("content-type")],
      ["etag", response.headers.get("etag")],
      ["x-query-count", response.headers.get("x-query-count")],
      ["x-response-time-ms", response.headers.get("x-response-time-ms")]
    ].filter(([_key, value]) => value && value.length > 0)

    if (entries.length === 0) return "-"
    return entries.map(([key, value]) => `${key}: ${value}`).join("\n")
  }

  toggleRawJson() {
    const showRaw = this.rawToggleTarget.checked
    this.jsonTreeTarget.classList.toggle("hidden", showRaw)
    this.jsonOutputTarget.classList.toggle("hidden", !showRaw)
  }

  renderJson(value) {
    this.jsonOutputTarget.textContent = JSON.stringify(value, null, 2)
    this.jsonTreeTarget.replaceChildren(this.nodeFor(value, "root", 0, true))
    this.toggleRawJson()
  }

  nodeFor(value, key, depth, open = false) {
    const row = document.createElement("div")
    row.className = depth > 0 ? "ml-4" : ""

    if (value === null || typeof value !== "object") {
      row.appendChild(this.scalarLine(key, value))
      return row
    }

    const isArray = Array.isArray(value)
    const entries = isArray ? value.map((item, idx) => [String(idx), item]) : Object.entries(value)
    const details = document.createElement("details")
    details.open = open
    details.className = "my-1"

    const summary = document.createElement("summary")
    summary.className = "cursor-pointer select-none text-cyan-700 dark:text-cyan-300"
    const label = key === "root" ? (isArray ? "Array" : "Object") : key
    summary.textContent = `${label}: ${isArray ? `[${entries.length}]` : `{${entries.length}}`}`
    details.appendChild(summary)

    entries.forEach(([childKey, childValue]) => {
      details.appendChild(this.nodeFor(childValue, childKey, depth + 1))
    })

    row.appendChild(details)
    return row
  }

  scalarLine(key, value) {
    const line = document.createElement("p")
    const keySpan = document.createElement("span")
    keySpan.className = "text-emerald-700 dark:text-emerald-300"
    keySpan.textContent = `${key}: `

    const valueSpan = document.createElement("span")
    valueSpan.className = this.valueClass(value)
    valueSpan.textContent = this.valueText(value)

    line.appendChild(keySpan)
    line.appendChild(valueSpan)
    return line
  }

  valueClass(value) {
    if (typeof value === "string") return "text-amber-700 dark:text-amber-300"
    if (typeof value === "number") return "text-fuchsia-700 dark:text-fuchsia-300"
    if (typeof value === "boolean") return "text-sky-700 dark:text-sky-300"
    if (value === null) return "text-slate-500 dark:text-slate-400"
    return "text-slate-700 dark:text-slate-200"
  }

  valueText(value) {
    if (typeof value === "string") return `"${value}"`
    if (value === null) return "null"
    return String(value)
  }

  pushHistory(entry) {
    this.recent.unshift(entry)
    this.recent = this.recent.slice(0, 8)
    this.renderHistory()
  }

  renderHistory() {
    this.historyTarget.replaceChildren()
    this.emptyHistoryTarget.classList.toggle("hidden", this.recent.length > 0)

    this.recent.forEach((entry) => {
      const item = document.createElement("li")
      item.className = "rounded-xl border border-slate-200 bg-slate-50 p-3 dark:border-slate-700 dark:bg-slate-950"

      const meta = document.createElement("p")
      meta.className = "mb-1 text-xs text-slate-600 dark:text-slate-300"
      meta.textContent = `status=${entry.status} ui_ms=${entry.elapsedMs} api_ms=${entry.responseTimeMs || "-"} queries=${entry.queryCount || "-"}`

      const button = document.createElement("button")
      button.type = "button"
      button.dataset.action = "api-explorer#reuseHistory"
      button.dataset.version = this.versionFromUrl(entry.url)
      button.dataset.path = this.pathFromUrl(entry.url)
      button.className = "font-mono text-xs font-semibold text-cyan-800 hover:underline dark:text-cyan-300"
      button.textContent = entry.url

      item.appendChild(meta)
      item.appendChild(button)
      this.historyTarget.appendChild(item)
    })
  }

  versionFromUrl(url) {
    if (url.startsWith("/api/v3/")) return "v3"
    return "v2"
  }

  pathFromUrl(url) {
    return url.replace(/^\/api\/v[23]\//, "")
  }
}
