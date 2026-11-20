## 1. Product Position Statement (PPS)

| Element | Details |
| :--- | :--- |
| **Product Name** | `medication-reminder` |
| **Target Audience** | Older adults and patients with chronic conditions on recurring medication, as well as nearby or remote family caregivers |
| **Problem Statement** | Medication doses are easily missed, and it is difficult to flexibly update actual intake times or let family members check whether doses were taken from afar. |
| **Category** | Medication adherence and caregiver-sharing web/mobile application |
| **Key Benefits** | • One-click dose check-in with actual intake time (`actual_taken_at`) and notes<br>• Automatic missed-dose detection and highlighting past scheduled times<br>• Read-only adherence sharing and missed-dose alerts via consent-based family links (`care_link`) |
| **Unique Selling Proposition (USP)** | Built on a relational data model that separates schedule rules (`medication_schedule`) from actual dose logs (`dose_log`) along with audit logs (`audit_log`), allowing the web MVP and future mobile app to reuse the same service layer. |
| **Competitive Landscape** | Existing simple reminder and tracker apps are often device-local and limited in family sharing, adjusting actual intake times, and tracking record history. |
| **Core Values** | Clarity, data integrity, access control, and traceability |
| **Brand Promise** | Keep daily medication logging simple for patients while helping caregivers check adherence status clearly and safely. |

**Positioning Statement:**
> For patients managing recurring medications and their family caregivers, `medication-reminder` is a medication adherence and shared tracking application that simplifies dose logging, highlights missed doses, and supports read-only family visibility because it separates schedules from actual dose logs, enforces role-based access with audit tracking, and reuses a shared service layer across web and future mobile clients.

---

## 2. Problem Statement

Patients who take multiple recurring medications often struggle to remember whether a scheduled dose has been taken and frequently take doses later than planned. When actual intake times cannot be adjusted or shared, both the patient and their family lose reliable visibility into daily adherence. Family caregivers living separately have no lightweight, privacy-aware way to check adherence status or notice missed doses without repeatedly calling the patient.

---

## 3. Target Users (Personas)

### User 1: Patient
- **Profile:** Older adult or adult managing chronic conditions (e.g., hypertension, diabetes) with 2 or more daily medications.
- **Goals:** Quickly check off today's medications, adjust the actual time when a dose is taken late, and keep simple notes (e.g., side effects, meal context).
- **Pain Points:** Small or cluttered interfaces, inability to edit actual intake time after a delay, and forgetting whether an earlier dose was taken.

### User 2: Family Caregiver
- **Profile:** Adult child or family member living nearby or remotely who monitors a parent's or relative's daily routine.
- **Goals:** Check the patient's daily adherence status without altering the patient's records, and receive notice when scheduled doses are missed.
- **Pain Points:** Lack of shared visibility in device-local apps and concern over intruding on the patient's privacy without explicit consent.

---

## 4. MVP Scope (Phase 1 – Web MVP)

### In Scope
1. Session-based authentication with `patient` and `family` roles, plus one-click demo accounts.
2. Medication registration (name, dosage, instructions, prescribing doctor name as plain text) and daily schedule rules.
3. One-click dose logging with editable actual intake time (`actual_taken_at` in `TIMESTAMPTZ`) and optional notes.
4. On-read missed-dose calculation (`scheduled time passed` with no matching `dose_log`), visual highlighting, and `audit_log` tracking.
5. Consent-based family sharing (`care_link`: request, accept, revoke), read-only caregiver dashboard, and missed-dose email notification.
6. One JSON API endpoint (`GET /api/doses/today`) sharing the same `services/` layer as the web routes.

### Out of Scope (Deferred to Phase 2+)
- Native mobile push notifications / local device alarms (Phase 3 – React Native Expo).
- Token-based authentication (JWT) and full REST API coverage (Phase 2).
- Real-time WebSocket live updates (MVP updates on page load/refresh).
- Physician or pharmacist accounts, prescription transmission, and pharmacy refill integration (Phase 4).
- Drug interaction checking or clinical decision support.
- Complex account recovery flows (password reset emails, OAuth).

---

## 5. User Stories & Acceptance Criteria

### Story 1: Role-Based Login & Access Control
**As a** patient or family caregiver,  
**I want to** log in with my role-specific account (or demo account),  
**so that** I can access only the views and actions permitted for my role.

**Acceptance Criteria:**
- [ ] Users can log in with email and password via `POST /login`, establishing a server-side session.
- [ ] Demo login buttons allow instant sign-in as a sample `patient` or `family` user without manual registration.
- [ ] Unauthenticated requests to protected routes (`/patient/*`, `/family/*`, `/api/*`) are rejected or redirected to `/login`.
- [ ] A `requireLogin` middleware populates `req.user = { id, role }`, and role checks prevent `family` users from modifying patient medications or dose logs.

---

### Story 2: Medication & Schedule Management
**As a** patient,  
**I want to** register my medications with dosage instructions, prescribing doctor name, and daily scheduled times,  
**so that** the system knows what I am expected to take each day.

**Acceptance Criteria:**
- [ ] A logged-in patient can add a new medication with name, dosage, instructions, and optional prescribing doctor name (text field).
- [ ] The patient can assign one or more daily schedule times (`medication_schedule`) to a medication.
- [ ] All active medications and their schedules are listed on the medication management page (`/patient/meds`).
- [ ] Patients can deactivate or delete a medication/schedule without corrupting historical `dose_log` records.

---

### Story 3: One-Click Dose Check-In, Actual Time & Notes
**As a** patient,  
**I want to** mark a scheduled dose as taken with one click and optionally adjust the actual intake time or add a short note,  
**so that** my adherence log reflects when and how I actually took my medication.

**Acceptance Criteria:**
- [ ] The Today dashboard (`/patient/today`) lists all scheduled doses for the current date in `America/Toronto` time.
- [ ] Clicking "Take Now" records a new `dose_log` entry with the current timestamp (`TIMESTAMPTZ`) and updates the dose status to `taken`.
- [ ] The patient can specify or edit `actual_taken_at` for delayed doses and save an optional text note (e.g., "taken after lunch").
- [ ] Submitting a duplicate check-in for the same schedule on the same date is prevented or updates the existing record cleanly.

---

### Story 4: Missed-Dose Detection & Audit Logging
**As a** patient or caregiver,  
**I want** doses that passed their scheduled time without a log to be clearly highlighted as missed, and key actions recorded in an audit trail,  
**so that** adherence gaps are immediately visible and data access remains traceable.

**Acceptance Criteria:**
- [ ] The service layer calculates each scheduled dose's status dynamically as `taken`, `missed` (scheduled time passed, no log), or `upcoming`.
- [ ] `missed` doses are visually highlighted on both the patient dashboard and the family view.
- [ ] Creating/updating a `dose_log`, changing a `care_link`, or viewing a patient's shared log writes an entry to `audit_log` (`actor_id`, `action`, `target_id`, `created_at`).
- [ ] `GET /api/doses/today` returns the exact same structured dose list (`medicationName`, `scheduledAt`, `status`, `actualTakenAt`, `note`) in JSON format using the same service function.

---

### Story 5: Consent-Based Family Sharing & Missed-Dose Notification
**As a** family caregiver,  
**I want to** connect to a patient's account only with their consent and view their daily adherence in read-only mode,  
**so that** I can check on their wellbeing without modifying their medical data.

**Acceptance Criteria:**
- [ ] A patient can generate/share a link code (or approve a caregiver request) to create an active `care_link` record, and can revoke access at any time.
- [ ] Service-layer authorization verifies an active `care_link` before returning patient data; unauthorized or revoked caregivers receive an access-denied error.
- [ ] Linked caregivers can view the patient's daily dose statuses (`taken`, `missed`, `upcoming`) and adherence summary in read-only mode on `/family/patient/:id`.
- [ ] When missed doses exist, the system supports triggering a missed-dose email notification to the linked caregiver (or logs the alert payload cleanly if email transport is disabled in dev).

---

## 6. Key Non-Functional Requirements

- **Timezone Accuracy:** All timestamps are persisted in PostgreSQL as `TIMESTAMPTZ` (UTC) and converted to `America/Toronto` only at the presentation/formatting boundary.
- **Maintainability (Layered Separation):** `services/` modules must not import Express `req`/`res` objects; all SQL queries reside strictly inside `repositories/`.
- **Security & Configuration:** Database credentials and session secrets are loaded exclusively via `.env` and excluded from Git via `.gitignore`.
- **Accessibility:** Patient-facing buttons and status badges use clear text labels in addition to color cues so status is distinguishable without relying solely on color.
