# Product Requirements Document (PRD)

**Project:** medication-reminder  
**Target Platform:** Android (Google Play)  
**Architecture Strategy:** Local-First MVP (v1.0) → Optional Cloud & Caregiver Sync (v1.1)  
**Status:** Draft (Phase 1)

> **Disclaimer:** Not a medical device. Intended strictly as a personal medication reminder aid and does not provide medical advice, diagnosis, or treatment recommendations.

---

## 1. Problem Statement

- **Patients (Primary Users):** People taking daily medications often miss or delay doses due to busy routines, lack of clear daily tracking, or friction-heavy apps that force account creation before first use.
- **Family Caregivers (Secondary Users — v1.1):** Remote family members lack a simple, consent-based way to check whether a loved one has logged their daily doses without intrusive phone calls.

---

## 2. Target Users & Personas

| Persona                     | Role                    | Primary Goal                                                                         | Release             |
| :-------------------------- | :---------------------- | :----------------------------------------------------------------------------------- | :------------------ |
| **Daily Medication User**   | Patient / Individual    | Receive reliable offline reminders and log doses in one tap without sign-up friction | **v1.0 (MVP)**      |
| **Remote Family Caregiver** | Trusted Family / Helper | View real-time read-only adherence status with explicit patient consent              | **v1.1 (Post-MVP)** |

---

## 3. Scope Definition

### MVP Scope (v1.0 — Local-First)

- **First-Launch Disclaimer & Privacy Notice:** Non-medical use notice and local data consent before entering the app.
- **Medication & Schedule CRUD:** Add, edit, and delete medications (name, dosage, instructions) and daily reminder times stored locally via **Expo SQLite**.
- **Local Android Notifications:** Recurring on-device alarms scheduled and updated via **expo-notifications**.
- **One-Tap Check-In & Dose Logs:** Mark scheduled doses as `Taken` (with optional timestamp edit or note) or `Skipped`.
- **Adherence History:** Review daily and past dose records offline.

### Post-MVP Scope (v1.1 — Optional Cloud & Sharing)

- **Optional Sign-In & Cloud Sync:** Firebase Auth login to back up and sync local SQLite records (using `UUID` + `updatedAt`) to Cloud Firestore.
- **Consent-Based Caregiver Sharing:** Generate/revoke time-limited invite codes (via Cloud Functions) granting read-only access to linked caregivers.
- **In-App Account Deletion:** Full removal of user account and cloud records compliant with Google Play policies.

### Out of Scope (Non-Goals)

- Drug interaction checks, dosage recommendations, or clinical alerts.
- Caregiver editing/writing of patient medication schedules or dose logs.
- iOS release or wearable companion app in v1.0.

---

## 4. User Stories & Acceptance Criteria

### US-01: Zero-Friction Onboarding (v1.0)

- **Story:** As a first-time user, I want to start setting up my medications immediately without creating an account.
- **Acceptance Criteria:**
  - App displays a clear non-medical disclaimer and local storage notice on first launch.
  - Tapping "Agree & Continue" opens the main dashboard with zero network calls or login prompts.

### US-02: Medication & Schedule Management (v1.0)

- **Story:** As a patient, I want to add, edit, or remove medications and daily reminder times so my schedule stays accurate.
- **Acceptance Criteria:**
  - User can save a medication with name (required), dosage, instructions, and one or more daily reminder times.
  - Each record is persisted in Expo SQLite with a `UUID` and `updatedAt` timestamp.
  - Editing or deleting a schedule immediately cancels obsolete local alarms and reschedules active ones.

### US-03: Reliable Local Reminders (v1.0)

- **Story:** As a patient, I want my phone to notify me at my scheduled time even when I am offline.
- **Acceptance Criteria:**
  - App requests Android `POST_NOTIFICATIONS` permission with a clear rationale prompt.
  - Scheduled notifications fire reliably on-device without internet connectivity.
  - Tapping a notification opens the app directly to today's check-in view.

### US-04: One-Tap Check-In & History Review (v1.0)

- **Story:** As a patient, I want to log a dose with a single tap and review past records so I know whether I already took my medication.
- **Acceptance Criteria:**
  - Today's schedule displays pending doses clearly; tapping "Take" logs the current timestamp immediately.
  - Users can edit the intake timestamp, add a brief note, or mark a dose as skipped.
  - History view displays chronological logs grouped by date, persisted across app restarts.

### US-05: Consent-Based Caregiver Linking (v1.1)

- **Story:** As a patient, I want to share my adherence status with a family member via an invite code and revoke access anytime.
- **Acceptance Criteria:**
  - Signed-in patients can generate a single-use invite code via Cloud Functions.
  - Linked caregivers have strictly read-only access enforced by Firestore Security Rules.
  - Patients can revoke caregiver access in one tap, immediately terminating read permissions.

---

## 5. Non-Functional Requirements (NFR)

- **Offline Reliability:** 100% of v1.0 features must function offline with sub-200ms local SQLite read/write response.
- **Data Compatibility (v1.0 → v1.1):** All SQLite tables must use client-generated `UUID` primary keys and ISO-8601 `updatedAt` timestamps to enable conflict-safe cloud sync later.
- **Android Platform & Battery Resilience:** Notification scheduling must be verified on real Android hardware (via EAS Development Build), accounting for Android 13+ notification permissions and battery optimization behaviors.
- **Privacy & Security:** Local health logs stay on-device in v1.0; v1.1 cloud data must enforce owner-only write and consent-based caregiver read via Firestore Security Rules.
- **Store Compliance (Google Play):** Must satisfy Health Apps Declaration, hosted Privacy Policy URL, Closed Testing requirements, and v1.1 in-app account deletion.
