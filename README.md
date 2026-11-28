# medication-reminder

An Android mobile medication adherence app for patients and family caregivers, featuring local reminders, one-tap dose logging, and optional consent-based real-time sharing.

> Not a medical device; intended as a medication reminder aid and does not provide medical advice.

**Status:** Phase 1 - Design & Architecture (Stage 3 text spec complete; notification design gated by Phase 2 spike) · **License:** [MIT](./LICENSE)

## Overview

Patients on daily medications often miss or delay doses, while remote family caregivers lack a clear, consent-based way to verify adherence. **medication-reminder** addresses this gap with a zero-friction, offline-first Android app that starts without sign-up and optionally scales to real-time caregiver sharing.

## Core Features

### MVP (v1.0 - Local-First)

- **Medication & Schedule Setup:** Register, pause, edit, or delete medications and daily reminder times offline.
- **One-Tap Check-In & History:** Log doses with one tap, undo recent check-ins, edit intake time/notes, and review past logs.
- **Local Reminders:** Recurring on-device Android notifications via Expo Notifications with privacy-safe lock-screen defaults.
- **Safety & Privacy Notice:** Non-medical disclaimer and local-only privacy consent on first launch.

### Post-MVP (v1.1 - Optional Cloud & Caregiver Sync)

- **Optional Sign-In & Backup:** Firebase Authentication for multi-device data sync.
- **Caregiver Sharing:** Invite-code linking/revoking with real-time read-only adherence view (Cloud Firestore).
- **Account Deletion:** In-app account and cloud data removal compliant with Google Play policies.

## Release Roadmap

| Phase            | Milestone                         | Key Deliverables                                                                                                                    | Status                                        |
| :--------------- | :-------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------- | :-------------------------------------------- |
| **Phase&nbsp;1** | **Design & Architecture**         | PRD, UX flows & wireframes, cloud-ready SQLite/Firestore ERD, and sequence diagrams                                                 | In&nbsp;Progress (Stage 3 text spec complete) |
| **Phase&nbsp;2** | **Local-First MVP Build**         | Offline medication CRUD (Expo SQLite), one-tap logging, history, and Android local notifications via EAS Development Build          | Planned                                       |
| **Phase&nbsp;3** | **Android MVP Launch (v1.0)**     | Notification/battery QA, Play Console compliance (Closed Testing, Health Apps Declaration, Privacy Policy), and Google Play release | Planned                                       |
| **Phase&nbsp;4** | **Cloud & Caregiver Sync (v1.1)** | Optional Firebase Auth, Firestore real-time sync, Security Rules, and caregiver invite flow                                         | Planned                                       |

## Tech Stack

- **Mobile App (v1.0):** React Native (Expo) / StyleSheet (JS) - Target: Android
- **Local Persistence & Notifications (v1.0):** Expo SQLite, expo-notifications
- **Build & Release (v1.0):** EAS Development Build, EAS Build (AAB), EAS Submit (Google Play Console)
- **Optional Authentication (v1.1):** Firebase Auth
- **Database & Real-Time Sync (v1.1):** Cloud Firestore
- **Access Control (v1.1):** Firestore Security Rules
- **Server Logic (v1.1):** Cloud Functions for Firebase

## Documentation

Structured following the standard product engineering pipeline from problem definition to iterative implementation:

| Stage                                                                     | Status                                                                 | Summary                                                                                                   |
| :------------------------------------------------------------------------ | :--------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------------- |
| **[1. PRD](./docs/01-prd.md)**                                            | Completed                                                              | Problem statement, user stories, acceptance criteria, MVP vs. optional scope, and NFRs                    |
| **[2. UX Flow & UI Wireframes](./docs/02-ux-ui-wireframes.md)**           | Text spec updated; Figma sync pending after Phase 2 notification spike | End-to-end user flows, Figma wireframes, UI design tokens, and visual assets                              |
| **[3. Architecture & ERD](./docs/03-architecture-erd.md)**                | Text spec complete; notification design gated by Phase 2 spike         | Local-first architecture, sync-compatible SQLite/Firestore ERD, and Security Rules design                 |
| **[4. API Spec & Sequence Diagrams](./docs/04-api-sequence-diagrams.md)** | Next                                                                   | Service/Cloud Functions specs and sequence diagrams for local scheduling, check-in, and caregiver sharing |

## Getting Started

```bash
git clone [https://github.com/jisunpark28/medication-reminder.git](https://github.com/jisunpark28/medication-reminder.git)
cd medication-reminder
npm install
cp .env.example .env      # required only for Phase 4 / v1.1 optional cloud sync
npx expo start --android
```
