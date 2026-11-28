# Product Requirements Document (PRD)

**Project:** medication-reminder  
**Target Platform:** Android (Google Play)  
**Architecture Strategy:** Local-First MVP (v1.0) → Optional Cloud & Caregiver Sync (v1.1)  
**Status:** Completed (Phase 1 - Stage 1)

> **Disclaimer:** Not a medical device. Intended strictly as a personal medication reminder aid and does not provide medical advice, diagnosis, or treatment recommendations.

---

## 1. Problem Statement

- **Patients (Primary Users):** People taking daily medications often miss or delay doses due to busy routines, unreliable reminders, or friction-heavy apps that force account creation before first use.
- **Family Caregivers (Secondary Users - v1.1):** Remote family members lack a simple, consent-based way to check whether a loved one has logged their daily doses without intrusive phone calls.

---

## 2. Target Users & Personas

| Persona                     | Role                    | Primary Goal                                                                                 | Release             |
| :-------------------------- | :---------------------- | :------------------------------------------------------------------------------------------- | :------------------ |
| **Daily Medication User**   | Patient / Individual    | Receive reliable offline reminders and log doses in one tap with accessible, low-friction UX | **v1.0 (MVP)**      |
| **Remote Family Caregiver** | Trusted Family / Helper | View real-time read-only adherence status with explicit patient consent                      | **v1.1 (Post-MVP)** |

---

## 3. Scope Definition

### MVP Scope (v1.0 - Local-First)

- **First-Launch Disclaimer & Privacy Notice:** Non-medical use notice and local data consent before entering the app.
- **Medication & Schedule CRUD:** Add, edit, pause/resume, and delete medications (name, form, dosage, instructions, prescriber) and reminders stored locally via **Expo SQLite**, as either fixed daily times or interval-based dosing (doses per day + interval, entered as prescribed).
- **Reliable Local Android Notifications:** Grouped daily alarms plus one-shot alarms for interval doses, scheduled and resynced via **expo-notifications**, with exact-alarm/battery status checks and privacy-safe lock-screen copy by default.
- **One-Tap Check-In, Undo & Dose Logs:** Mark scheduled doses as `Taken` (with optional timestamp edit or note) or `Skipped`, undo recent check-ins, and automatically reconcile unlogged past doses as `Missed`.
- **Adherence History:** Review weekly and daily past dose records offline with preserved medication snapshots.

### Post-MVP Scope (v1.1 - Optional Cloud & Sharing)

- **Optional Sign-In & Cloud Sync:** Firebase Auth login to back up and sync local SQLite records (using `UUID`, `updated_at`, and `tz`) to Cloud Firestore.
- **Consent-Based Caregiver Sharing:** Generate/revoke single-use, time-limited invite codes (via Cloud Functions) granting read-only access to linked caregivers.
- **In-App Account Deletion:** Full removal of user account and cloud records compliant with Google Play policies (verify current in-app + web deletion-request requirements in Phase 4).

### Out of Scope (Non-Goals)

- Drug interaction checks, dosage or dosing-interval recommendations, or clinical alerts.
- Caregiver editing/writing of patient medication schedules or dose logs.
- iOS release, wearable companion app, or CSV export in v1.0.

---

## 4. User Stories & Acceptance Criteria

### US-01: Zero-Friction Onboarding (v1.0)

- **Story:** As a first-time user, I want to start setting up my medications immediately without creating an account.
- **Acceptance Criteria:**
  - App displays a clear non-medical disclaimer and local storage notice on first launch.
  - Tapping "Agree & Continue" opens the main `Today` dashboard with zero network calls or login prompts.

### US-02: Medication & Schedule Management (v1.0)

- **Story:** As a patient, I want to add, edit, pause, or remove medications and daily reminder times so my schedule stays accurate.
- **Acceptance Criteria:**
  - User can save a medication with name (required), form (`Tablet`, `Capsule`, `Syrup`, `Bundle`, `Sachet`, `Pen`), dosage, instructions, prescriber, and one or more daily reminder times.
  - User can choose "Fixed times" or "Every N hours". Interval medications store doses per day (2–12), interval (1–12 h), and a first-dose time; helper text says "Enter as prescribed" and the app never suggests values.
  - Users can pause/resume a medication (`is_active` toggle) without deleting it. Resuming a medication updates `effective_from` on all its active child schedules in the same transaction, so slots from before the resume are not treated as overdue or missed.
  - Each record is persisted in Expo SQLite with a `UUID` and `updated_at` timestamp.
  - Editing, pausing, resuming, or deleting a medication reconciles past unlogged days first, then resyncs local alarms via `ScheduleService.resyncAll()` while preserving past dose history.

### US-03: Reliable Local Reminders (v1.0)

- **Story:** As a patient, I want my phone to notify me reliably at my scheduled time even when I am offline, without exposing medication names on my lock screen by default.
- **Acceptance Criteria:**
  - App creates the Android notification channel before requesting `POST_NOTIFICATIONS` permission with a clear rationale prompt.
  - Notifications are grouped per unique reminder time (`dose-HH:mm`); interval doses 2+ use one-shot notifications scheduled once the previous dose is logged. All show generic lock-screen text by default (with an opt-in setting to show medication names).
  - App checks notification permission, `SCHEDULE_EXACT_ALARM` availability, and battery optimization state on launch/resume, surfacing issues in `Settings` and the `Today` banner (including an `Exact alarm not allowed` banner when exact alarms are not granted; reminders continue as inexact and may arrive late).
  - Tapping a notification opens the app directly to `Today`.

### US-04: One-Tap Check-In, Missed Reconciliation & History Review (v1.0)

- **Story:** As a patient, I want to log a dose with a single tap and review accurate past records so I know whether I took, skipped, or missed my medication.
- **Acceptance Criteria:**
  - Today's schedule groups doses by time; tapping `Take` logs the current timestamp immediately and shows a 6–8s `UndoSnackbar`.
  - Users can edit the intake timestamp, add a brief note, or toggle `Taken` / `Skipped` via `DoseActionBottomSheet` (switching to `Skipped` clears `taken_at`). For today's logs only, `Clear record` deletes the log and returns the slot to Pending / Due Now / Overdue; the action is hidden for past dates. Past Missed records can be changed to Taken or Skipped, never back to Missed; later doses are not recomputed.
  - Interval doses chain within the day: the next due time is the previous dose's taken time + interval (or its due time + interval if skipped or missed). Until then the next dose shows "Pending - after dose N". Doses that would fall after 23:59 are dropped for that day, and undo, clear, or time edits recompute later doses and their alarms.
  - Unlogged active schedules whose slot instant (`scheduled_date` + `time_of_day` in the local timezone) is at or after the schedule's `effective_from` are reconciled as `Missed` without being retroactively altered by later schedule edits.
  - History view displays weekly and daily chronological logs persisted across app restarts with frozen medication name/dosage snapshots.

### US-05: Consent-Based Caregiver Linking (v1.1)

- **Story:** As a patient, I want to share my adherence status with a family member via an invite code and revoke access anytime.
- **Acceptance Criteria:**
  - Generate single-use, time-limited invite codes to link caregivers with read-only access; either side can end a link.
  - Linked caregivers have strictly read-only access enforced by Firestore Security Rules.
  - Patients can revoke caregiver access in one tap, immediately terminating read permissions. Caregivers can also end (stop viewing) a link; re-linking requires a new invite code.

---

## 5. Non-Functional Requirements (NFR)

- **Offline Reliability & Local-Only Privacy:** 100% of v1.0 features function offline with sub-200ms SQLite response. `android:allowBackup="false"` is set so local SQLite files are not silently uploaded to Google Backup.
- **Data Compatibility (v1.0 → v1.1):** Core tables use client-generated `UUID` primary keys and UTC `updated_at` timestamps in `YYYY-MM-DDTHH:mm:ss.SSSZ`; soft deletes (`deleted_at`) only on `medications` and `medication_schedules`; IANA `tz` on `dose_logs`; `PRAGMA user_version` migrations.
- **Android Notification & Device QA Matrix:** Before v1.0 release, notification delivery must be verified on real Android hardware via EAS Development Build across at least **Pixel, Samsung, and 1 aggressive battery-optimization OEM device** under three scenarios: app force-closed, device reboot, and Doze mode.
- **Accessibility:** Minimum `48dp × 48dp` touch targets, explicit text status badges, full `Reduce Motion` support, and clean layout scaling up to system `fontScale = 200%`.
- **Store Compliance (Google Play):** Must satisfy Health Apps Declaration, hosted Privacy Policy URL (ready before Closed Testing), Closed Testing (12 testers / 14 consecutive days), and v1.1 in-app account deletion.
