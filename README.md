# medication-reminder

A mobile medication adherence app for patients and family caregivers, featuring local reminders, dose history logging, and consent-based real-time sharing.

**Status:** In Progress (Mobile MVP) · **License:** [MIT](./LICENSE)

## Overview

Patients on recurring daily medications often miss doses or take them late, while remote family caregivers lack a clear, consent-based way to check adherence. This mobile app pairs simple on-device reminders and logging with live, permission-controlled caregiver visibility.

## Core Features

1. **Login:** Sign in via Firebase Authentication.
2. **Medication & Schedule Setup:** Register medications (name, dosage, instructions, prescribing doctor) and daily schedule times.
3. **One-Tap Check-In & History:** Log doses with one tap, edit actual intake time and notes, and review past intake history.
4. **Local Scheduled Reminders:** Schedule recurring on-device notifications for daily dose times.
5. **Consent-Based Caregiver Sync:** Link or revoke family caregivers by consent and sync a read-only adherence view in real time.

## Tech Stack

- **Mobile App:** React Native (Expo)
- **Authentication:** Firebase Authentication
- **Database & Real-Time Sync:** Cloud Firestore
- **Access Control:** Firestore Security Rules
- **Local Notifications:** On-device scheduling (`expo-notifications`)

## Architecture

```text
React Native App (UI & Local Notifications)
 ├── Firebase Auth ──────────► Role login & session state
 └── Cloud Firestore ────────► Real-time sync & Security Rules
```

## Getting Started

```bash
git clone https://github.com/jisunpark28/medication-reminder.git
cd medication-reminder
npm install
npx expo start
```

Configure Firebase credentials in your local environment before running the app.

## Documentation

| Document | Summary |
| :--- | :--- |
| [docs/01-requirements.md](./docs/01-requirements.md) | Positioning, target users, scope, and user stories |

## AI Usage

AI tools were used as a coding and documentation assistant. Architecture, data structure, access control decisions, and final implementation verification were handled directly.
