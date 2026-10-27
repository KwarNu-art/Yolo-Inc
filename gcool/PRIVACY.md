# 🛡️ GCOOL: Privacy Constitution

GCOOL was built with privacy and user ownership as core foundations.

---

## 🔒 100% Local-First Architecture

- **Zero Network Telemetry**: GCOOL contains no third-party tracking SDKs, advertising frameworks, or remote analytics endpoints.
- **Local Persistence Only**: All session duration logs, game catalog entries, and user notes are saved exclusively to your device's sandbox document directory (`FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)`).
- **No Data Collection**: GCOOL never transmits your hardware identifiers, battery levels, thermal states, or session notes to any server.

---

## 🗄️ Data Control & Export

- **Plain Text Export**: You can export all recorded session summaries to your system clipboard at any time from **Settings -> Export Session Summaries**.
- **Instant Deletion**: Tapping **Clear All Session History** immediately purges the `gcool_sessions.json` document file from your device.
- **Catalog Reset**: Tapping **Reset Game Catalog** resets your catalog to default titles without leaving residual data.
