# Alu-hub-group11
A student engagement platform for the African Leadership University community.
ALU Connect gathers campus opportunities into one trusted feed, built around a
simple idea: **anyone with an ALU email can join and post.**

## The core idea (our product spine)

At ALU, opportunities (internships, hackathons, workshops, club events) are
scattered across WhatsApp groups, emails, and noticeboards. ALU Connect brings
them into one place. Access is intentionally simple:

- Sign up requires an **ALU email** (`@alustudent.com`).
- Every signed-in member can discover, RSVP, register, chat — and post
  opportunities for the community.

The journey is the demo: *sign up with your ALU email → browse the feed →
post an opportunity → other members RSVP and chat.*

## Project structure

```
lib/
  models/        Data models (User, Opportunity, Message)
  state/         AppState (ChangeNotifier) — single source of truth
  data/          MockData — seed users, opportunities, messages
  theme/         AppTheme — centralised colors & component styling
  screens/       One file per screen
  widgets/       Reusable widgets (extract cards/badges here)
  main.dart      Entry point, Provider setup, auth gate
```

## State handling

A single `AppState` extends `ChangeNotifier`. Screens read it with
`context.watch<AppState>()` and call methods (`toggleRsvp`, `createOpportunity`,
`sendMessage`, ...). Each method mutates state and calls `notifyListeners()`,
so the UI rebuilds automatically.

**Persistence:** only the logged-in user is saved (via `shared_preferences`),
so the session survives an app restart. Everything else is in-memory mock data,
which is all the brief requires.

## Demo / test accounts

Any non-empty password works. Log in with any of these seed accounts:

| Name         | Email                  |
|--------------|------------------------|
| Amara Okeke  | amara@alustudent.com   |
| Kwame Mensah | kwame@alustudent.com   |
| Liana Uwase  | liana@alustudent.com   |

Or sign up fresh with any `@alustudent.com` email.

## Running it

```bash
flutter pub get
flutter run        # on an emulator or physical device (NOT browser)
```

> The brief is explicit: an app running only in a browser will not be graded.
> Run it on an Android emulator / iOS simulator or a real device.

## What's done vs. what your team builds

**Done (runnable foundation):** models, mock data, full AppState, theme,
navigation shell, login/sign-up with ALU-email validation, a functional feed
with filtering, working RSVP, and posting open to every signed-in member.

**TODO for the team (look for `// TODO(team)`):**
- `feed_screen.dart` — extract `_OpportunityCard` into `widgets/` and make it
  visually striking (reusability = rubric points).
- `opportunity_detail_screen.dart` — full detail layout + the per-event chat UI.
- `create_opportunity_screen.dart` — the post form with validation + date picker.
- `profile_screen.dart` — polish identity layout, show my-RSVP count.
- Empty states, input validation feedback, and a couple of animations
  (page transitions or a badge reveal) for the Technical Initiative points.

## AI usage disclosure (required by the brief)

Per the academic-integrity policy: state clearly in your report where AI was
used. This scaffold was produced with AI assistance for structure and
boilerplate; all design decisions, screen implementations, and the report must
be authored and fully understood by the team, and every member must be able to
explain and modify the code live.
