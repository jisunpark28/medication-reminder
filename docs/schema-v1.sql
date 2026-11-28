-- Medication Reminder v1.0 - Local SQLite Schema
-- Run PRAGMA foreign_keys = ON; immediately after opening the connection, before starting the migration transaction.

CREATE TABLE medications (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  form TEXT NOT NULL DEFAULT 'tablet'
    CHECK (form IN ('tablet','capsule','syrup','bundle','sachet','pen')),
  dosage TEXT, instructions TEXT, prescriber TEXT,
  schedule_type TEXT NOT NULL DEFAULT 'fixed'
    CHECK (schedule_type IN ('fixed','interval')),
  doses_per_day INTEGER,     -- interval only (2-12)
  interval_minutes INTEGER,  -- interval only (60-720)
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0,1)),
  created_at TEXT NOT NULL, updated_at TEXT NOT NULL, deleted_at TEXT,
  CHECK (
    (schedule_type = 'fixed' AND doses_per_day IS NULL AND interval_minutes IS NULL)
    OR (schedule_type = 'interval'
        AND doses_per_day IS NOT NULL AND doses_per_day BETWEEN 2 AND 12
        AND interval_minutes IS NOT NULL AND interval_minutes BETWEEN 60 AND 720)
  )
);

-- Fixed: one row per daily time. Interval: exactly one row (dose 1 anchor), enforced by the repository.
CREATE TABLE medication_schedules (
  id TEXT PRIMARY KEY,
  medication_id TEXT NOT NULL REFERENCES medications(id) ON DELETE RESTRICT,
  time_of_day TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0,1)),
  created_at TEXT NOT NULL, effective_from TEXT NOT NULL,
  updated_at TEXT NOT NULL, deleted_at TEXT
);
CREATE UNIQUE INDEX uq_sched_active
  ON medication_schedules (medication_id, time_of_day) WHERE deleted_at IS NULL;
CREATE INDEX idx_sched_med_active
  ON medication_schedules (medication_id, is_active) WHERE deleted_at IS NULL;

CREATE TABLE dose_logs (
  id TEXT PRIMARY KEY,
  medication_id TEXT NOT NULL REFERENCES medications(id) ON DELETE RESTRICT,
  schedule_id TEXT REFERENCES medication_schedules(id) ON DELETE SET NULL,
  medication_name_snapshot TEXT NOT NULL, dosage_snapshot TEXT,
  scheduled_date TEXT NOT NULL, scheduled_time TEXT NOT NULL, tz TEXT NOT NULL,
  dose_index INTEGER CHECK (dose_index IS NULL OR dose_index >= 1), -- NULL = fixed, 1..n = interval
  status TEXT NOT NULL CHECK (status IN ('taken','skipped','missed')),
  taken_at TEXT, note TEXT, created_at TEXT NOT NULL, updated_at TEXT NOT NULL,
  CHECK ((status = 'taken') = (taken_at IS NOT NULL))
);
-- One log per slot: fixed slots are keyed by time, interval doses by index.
CREATE UNIQUE INDEX uq_dose_fixed
  ON dose_logs (medication_id, scheduled_date, scheduled_time) WHERE dose_index IS NULL;
CREATE UNIQUE INDEX uq_dose_interval
  ON dose_logs (medication_id, scheduled_date, dose_index) WHERE dose_index IS NOT NULL;
CREATE INDEX idx_dose_logs_date ON dose_logs (scheduled_date);

CREATE TABLE app_settings (
  id TEXT PRIMARY KEY CHECK (id = 'local'),
  onboarding_accepted_at TEXT,
  reduce_motion_override INTEGER CHECK (reduce_motion_override IN (0,1)), -- NULL = follow OS
  show_med_name_on_lock_screen INTEGER NOT NULL DEFAULT 0
    CHECK (show_med_name_on_lock_screen IN (0,1)),
  notification_permission_asked_at TEXT,
  last_reconciled_date TEXT,
  updated_at TEXT NOT NULL
);
INSERT OR IGNORE INTO app_settings (id, updated_at)
VALUES ('local', strftime('%Y-%m-%dT%H:%M:%fZ','now'));

CREATE VIEW v_active_schedules AS
SELECT s.id AS schedule_id, s.medication_id, s.time_of_day,
       s.effective_from AS schedule_effective_from, m.name, m.dosage, m.form,
       m.schedule_type, m.doses_per_day, m.interval_minutes
FROM medication_schedules s
JOIN medications m ON m.id = s.medication_id
WHERE s.deleted_at IS NULL AND s.is_active = 1
  AND m.deleted_at IS NULL AND m.is_active = 1;
