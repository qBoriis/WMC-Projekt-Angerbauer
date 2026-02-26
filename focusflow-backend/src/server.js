const express = require("express");
const cors = require("cors");
const db = require("./db");

const app = express();
app.use(cors());
app.use(express.json());

// Health
app.get("/health", (req, res) => res.json({ ok: true }));

// ---------- SESSIONS ----------

// POST /sessions
app.post("/sessions", (req, res) => {
  const { startedAt, endedAt, durationMin, note } = req.body;

  if (!startedAt || !endedAt || typeof durationMin !== "number") {
    return res.status(400).json({
      error: "startedAt, endedAt und durationMin (number) sind Pflicht.",
    });
  }
  if (durationMin <= 0) {
    return res.status(400).json({ error: "durationMin muss > 0 sein." });
  }

  try {
    const stmt = db.prepare(`
      INSERT INTO sessions (startedAt, endedAt, durationMin, note)
      VALUES (?, ?, ?, ?)
    `);
    const info = stmt.run(
      new Date(startedAt).toISOString(),
      new Date(endedAt).toISOString(),
      durationMin,
      note ?? null
    );

    const created = db
      .prepare(`SELECT * FROM sessions WHERE id = ?`)
      .get(info.lastInsertRowid);

    res.status(201).json(created);
  } catch (err) {
    res.status(500).json({ error: "Serverfehler", details: String(err) });
  }
});

// GET /sessions?limit=50
app.get("/sessions", (req, res) => {
  const limit = Math.min(parseInt(req.query.limit || "50", 10), 200);

  try {
    const rows = db
      .prepare(`SELECT * FROM sessions ORDER BY startedAt DESC LIMIT ?`)
      .all(limit);

    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: "Serverfehler", details: String(err) });
  }
});

// GET /sessions/:id
app.get("/sessions/:id", (req, res) => {
  const id = parseInt(req.params.id, 10);
  if (!Number.isFinite(id)) return res.status(400).json({ error: "Ungültige ID" });

  try {
    const row = db.prepare(`SELECT * FROM sessions WHERE id = ?`).get(id);
    if (!row) return res.status(404).json({ error: "Nicht gefunden" });
    res.json(row);
  } catch (err) {
    res.status(500).json({ error: "Serverfehler", details: String(err) });
  }
});

// DELETE /sessions/:id
app.delete("/sessions/:id", (req, res) => {
  const id = parseInt(req.params.id, 10);
  if (!Number.isFinite(id)) return res.status(400).json({ error: "Ungültige ID" });

  try {
    const info = db.prepare(`DELETE FROM sessions WHERE id = ?`).run(id);
    if (info.changes === 0) return res.status(404).json({ error: "Nicht gefunden" });
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: "Serverfehler", details: String(err) });
  }
});

// ---------- SETTINGS ----------

// GET /settings
app.get("/settings", (req, res) => {
  try {
    const rows = db.prepare(`SELECT key, value FROM settings ORDER BY key ASC`).all();
    const obj = {};
    for (const r of rows) obj[r.key] = r.value;
    res.json(obj);
  } catch (err) {
    res.status(500).json({ error: "Serverfehler", details: String(err) });
  }
});

// GET /settings/:key
app.get("/settings/:key", (req, res) => {
  const key = req.params.key;

  try {
    const row = db.prepare(`SELECT key, value FROM settings WHERE key = ?`).get(key);
    if (!row) return res.status(404).json({ error: "Nicht gefunden" });
    res.json(row);
  } catch (err) {
    res.status(500).json({ error: "Serverfehler", details: String(err) });
  }
});

// PUT /settings/:key  { value: "..." }
app.put("/settings/:key", (req, res) => {
  const key = req.params.key;
  const { value } = req.body;

  if (typeof value !== "string") {
    return res.status(400).json({ error: "value muss ein String sein." });
  }

  try {
    // upsert
    db.prepare(`
      INSERT INTO settings (key, value, updatedAt)
      VALUES (?, ?, datetime('now'))
      ON CONFLICT(key) DO UPDATE SET
        value = excluded.value,
        updatedAt = datetime('now')
    `).run(key, value);

    const row = db.prepare(`SELECT key, value FROM settings WHERE key = ?`).get(key);
    res.json(row);
  } catch (err) {
    res.status(500).json({ error: "Serverfehler", details: String(err) });
  }
});

// ---------- STATS / HEATMAP + STREAK ----------
// GET /stats/summary?from=YYYY-MM-DD&to=YYYY-MM-DD
app.get("/stats/summary", (req, res) => {
  try {
    const from = req.query.from ? req.query.from + "T00:00:00.000Z" : null;
    const to = req.query.to ? req.query.to + "T23:59:59.999Z" : null;

    let rows;
    if (from && to) {
      rows = db
        .prepare(`SELECT startedAt, durationMin FROM sessions WHERE startedAt BETWEEN ? AND ? ORDER BY startedAt ASC`)
        .all(from, to);
    } else if (from) {
      rows = db
        .prepare(`SELECT startedAt, durationMin FROM sessions WHERE startedAt >= ? ORDER BY startedAt ASC`)
        .all(from);
    } else if (to) {
      rows = db
        .prepare(`SELECT startedAt, durationMin FROM sessions WHERE startedAt <= ? ORDER BY startedAt ASC`)
        .all(to);
    } else {
      rows = db.prepare(`SELECT startedAt, durationMin FROM sessions ORDER BY startedAt ASC`).all();
    }

    // dayTotals aufbauen
    const dayMap = new Map(); // YYYY-MM-DD -> minutes
    let totalMinutes = 0;

    for (const r of rows) {
      const dayKey = new Date(r.startedAt).toISOString().slice(0, 10);
      dayMap.set(dayKey, (dayMap.get(dayKey) || 0) + r.durationMin);
      totalMinutes += r.durationMin;
    }

    const learnedDays = Array.from(dayMap.keys()).sort();
    const dayTotals = learnedDays.map((d) => ({ date: d, minutes: dayMap.get(d) }));

    // best streak
    let best = 0;
    let run = 0;
    for (let i = 0; i < learnedDays.length; i++) {
      if (i === 0) run = 1;
      else {
        const prev = new Date(learnedDays[i - 1] + "T00:00:00.000Z");
        const cur = new Date(learnedDays[i] + "T00:00:00.000Z");
        const diff = (cur - prev) / (1000 * 60 * 60 * 24);
        run = diff === 1 ? run + 1 : 1;
      }
      best = Math.max(best, run);
    }

    // current streak (endet heute oder gestern)
    const todayKey = new Date().toISOString().slice(0, 10);
    const yesterdayKey = new Date(Date.now() - 86400000).toISOString().slice(0, 10);
    const endsAt = dayMap.has(todayKey) ? todayKey : (dayMap.has(yesterdayKey) ? yesterdayKey : null);

    let current = 0;
    if (endsAt) {
      const set = new Set(learnedDays);
      let d = new Date(endsAt + "T00:00:00.000Z");
      while (set.has(d.toISOString().slice(0, 10))) {
        current++;
        d = new Date(d.getTime() - 86400000);
      }
    }

    res.json({ totalMinutes, dayTotals, streaks: { current, best } });
  } catch (err) {
    res.status(500).json({ error: "Serverfehler", details: String(err) });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`API läuft auf http://localhost:${PORT}`));