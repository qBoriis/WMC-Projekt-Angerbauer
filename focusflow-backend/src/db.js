const Database = require("better-sqlite3");
const path = require("path");

const dbPath = path.join(__dirname, "..", "focusflow.db");
const db = new Database(dbPath);

// Performance + Stabilität
db.pragma("journal_mode = WAL");

// Tabellen erstellen (wenn nicht vorhanden)
db.exec(`
CREATE TABLE IF NOT EXISTS sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  startedAt TEXT NOT NULL,     -- ISO String (UTC)
  endedAt   TEXT NOT NULL,     -- ISO String (UTC)
  durationMin INTEGER NOT NULL CHECK(durationMin > 0),
  note TEXT,
  createdAt TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_sessions_startedAt ON sessions(startedAt);

CREATE TABLE IF NOT EXISTS settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updatedAt TEXT NOT NULL DEFAULT (datetime('now'))
);
`);

module.exports = db;