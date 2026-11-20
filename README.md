# medication-reminder

A web-based medication adherence tracker for older adults and patients with chronic conditions, with consent-based read-only sharing for family caregivers.

<!-- Update links once deployed -->
**Status:** In Progress (Phase 1 – Web MVP) 
<!-- 🔗 [Live Demo](https://your-domain.com) · 🎬 [2-Min Demo Video](https://video-link) -->

---

## Preview

<!-- Add 1–2 screenshots or a short GIF once UI is implemented (Week 4–5)
![Patient Today Dashboard](./docs/05-ux/preview-patient-today.png)
![Family Read-Only View](./docs/05-ux/preview-family-view.png)
-->

---

## Problem

Patients managing recurring daily medications frequently miss scheduled doses or take them late, making accurate tracking difficult. Existing simple reminder apps are often device-local, offer limited flexibility when recording actual intake times, and provide no structured way for remote family members to verify adherence.

## Features (MVP)

- **Role-Based Authentication & Demo Access:** Session-based login for `patient` and `family` roles, with one-click demo login buttons for evaluation.
- **Medication & Schedule Management:** Register medications with dosage instructions, prescribing doctor name (text), and recurring daily schedule rules (`medication_schedule`).
- **One-Click Dose Check-In & Notes:** Record doses with a single click, adjust the actual intake time (`actual_taken_at`, stored as `TIMESTAMPTZ`) for late doses, and attach short notes.
- **Missed-Dose Detection & Audit Trail:** Automatically flag scheduled doses as `missed` once the scheduled time has passed without a log, and record key actions and access events in `audit_log`.
- **Consent-Based Family Sharing & Alerts:** Link family caregivers via patient consent (`care_link`) to a read-only adherence view, with missed-dose email alerts.
- **Shared Service Layer Proof (`GET /api/doses/today`):** Exposes one JSON endpoint reusing the same `services/` logic as the Handlebars web routes to prepare for future mobile clients.

---

## Tech Stack

| Layer | Technology |
| :--- | :--- |
| **Presentation (Web)** | Handlebars (express-handlebars), HTML5, CSS3, Vanilla JS |
| **Backend & Routing** | Node.js, Express.js, express-session |
| **Database** | PostgreSQL (Supabase), pg |
| **Testing** | Mocha, Node, assert |

---

## Architecture & Data Model

The application follows a layered architecture where web routes (`routes/web/`) and API routes (`routes/api/`) share the same business logic (`services/`) and SQL data access layer (`repositories/`).

```text
Client (Browser / Future Mobile)
        │
        ▼
Routes (routes/web -> res.render | routes/api -> res.json)
        │
        ▼
Middleware (requireLogin -> req.user)
        │
        ▼
Services (Business Rules, Access Control, Missed Calculation)
        │
        ▼
Repositories (Parameterized SQL via pg)
        │
        ▼
Database (PostgreSQL on Supabase)
```

- **Core Tables:** `users`, `medication`, `medication_schedule`, `dose_log`, `care_link`, `audit_log`
<!-- Uncomment as diagrams and docs are committed
- Architecture details: [docs/04-architecture.md](./docs/04-architecture.md)
- ERD & schema details: [docs/02-erd.md](./docs/02-erd.md)
-->

---

## Key Design Decisions

<!-- Link individual ADR files under docs/decisions/ once written -->
- **Separate Schedules from Dose Logs:** Storing recurring rules (`medication_schedule`) separately from actual events (`dose_log`) allows missed doses to be calculated accurately without pre-generating empty rows.
- **Relational DB (PostgreSQL / Supabase):** Enforces referential integrity across patients, caregivers, schedules, logs, and audit trails while keeping the same backend database ready for future mobile expansion.
- **Service-Layer Authorization:** Family viewing permissions are validated inside `services/` rather than UI routes so web and API endpoints enforce identical access rules.

---

## Getting Started

### Prerequisites
- Node.js (v18 or higher)
- PostgreSQL database (local or Supabase)

### Local Setup

```bash
# 1. Clone the repository
git clone [https://github.com/jisunpark28/medication-reminder.git](https://github.com/jisunpark28/medication-reminder.git)
cd medication-reminder

# 2. Install dependencies
npm install

# 3. Configure environment variables
cp .env.example .env
# Edit .env with your DATABASE_URL and SESSION_SECRET

# 4. Initialize database schema
# Run src/db/schema.sql in your PostgreSQL / Supabase SQL Editor

# 5. Start the server
npm start
```

The server listens on `http://localhost:3000` (or `process.env.PORT`).

### Environment Variables (`.env.example`)

```env
PORT=3000
DATABASE_URL=postgresql://user:password@host:port/database
SESSION_SECRET=your_session_secret
TZ=America/Toronto
```

### Running Tests

```bash
npm test
```

---

## Roadmap

| Phase | Platform | Tech Stack | Core Scope | Status |
| :--- | :--- | :--- | :--- | :--- |
| **1** | Web MVP | Node.js, Express, Handlebars, PostgreSQL | Dose logging, missed detection, consent-based family view, 1 shared JSON API | In Progress |
| **2** | REST API | Express, JSON API, Token Auth | Full API coverage reusing `services/` layer | Planned |
| **3** | Mobile App | React Native (Expo) | Native local notifications, mobile UX | Planned |

---

## Documentation

<!-- Add rows strictly as each document is completed and committed -->
| Document | Description |
| :--- | :--- |
| [docs/01-requirements.md](./docs/01-requirements.md) | Product positioning, target users, MVP scope, and user stories |

---

## AI Usage

AI tools were used as drafting assistant for documentation structure

## License

This project is licensed under the [MIT License](./LICENSE).
