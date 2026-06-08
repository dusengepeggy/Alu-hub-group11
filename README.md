# Alu-hub-group11
A **trust-first** student engagement platform for the African Leadership
University community. Unlike a generic campus social feed, ALU Connect is
built around one core idea: **opportunities should be trustworthy, and not
everyone should be able to post them.**

## The core idea (our product spine)

At ALU, opportunities (internships, hackathons, workshops, club events) are
scattered across WhatsApp groups, emails, and noticeboards. Students can't
easily tell what's official or who has the authority to post. ALU Connect
solves this with **role-based access and verification**:

- **Students** discover, RSVP, register, and chat — but cannot post.
- **Organizers** (club leaders, event organizers, academic teams, vetted
  entrepreneurs) can post opportunities, which carry a **Verified** badge.
- **Admins** approve organizer requests and moderate (flag) posts.

The journey is the demo: *sign up as a student → browse the trusted feed →
request organizer access → an admin approves → you can now post.*

## Project structure

```
lib/
  models/        Data models (User, Opportunity, OrganizerRequest, Message)
  state/         AppState (ChangeNotifier) — single source of truth
  data/          MockData — seed users, opportunities, messages, requests
  theme/         AppTheme — centralised colors & component styling
  screens/       One file per screen
  widgets/       Reusable widgets (extract cards/badges here)
  main.dart      Entry point, Provider setup, auth gate
```

## State handling

A single `AppState` extends `ChangeNotifier`. Screens read it with
`context.watch<AppState>()` and call methods (`toggleRsvp`, `createOpportunity`,
`submitOrganizerRequest`, `approveRequest`, `sendMessage`, ...). Each method
mutates state and calls `notifyListeners()`, so the UI rebuilds automatically.

**Persistence:** only the logged-in user is saved (via `shared_preferences`),
so the session survives an app restart. Everything else is in-memory mock data,
which is all the brief requires.

## Demo / test accounts

Any non-empty password works. Log in with these to show each role:

| Role      | Email          |
|-----------|----------------|
| Admin     | admin@alu.edu  |
| Organizer | kwame@alu.edu  |
| Student   | liana@alu.edu  |

Or sign up fresh — new accounts always start as **Student**.

## Running it

```bash
flutter pub get
flutter run        # on an emulator or physical device (NOT browser)
```

> The brief is explicit: an app running only in a browser will not be graded.
> Run it on an Android emulator / iOS simulator or a real device.

## What's done vs. what your team builds

**Done (runnable foundation):** models, mock data, full AppState, theme,
navigation shell (role-aware tabs), login/sign-up, a functional feed with
filtering + verified badges, working RSVP, admin request approval, and the
organizer-request flow.

**TODO for the team (look for `// TODO(team)`):**
- `feed_screen.dart` — extract `_OpportunityCard` into `widgets/` and make it
  visually striking (reusability = rubric points).
- `opportunity_detail_screen.dart` — full detail layout + the per-event chat UI.
- `create_opportunity_screen.dart` — the post form with validation + date picker.
- `admin_panel_screen.dart` — add the post-moderation (flag/unflag) section.
- `profile_screen.dart` — polish identity layout, show my-RSVP count.
- Empty states, input validation feedback, and a couple of animations
  (page transitions or a badge reveal) for the Technical Initiative points.

## AI usage disclosure (required by the brief)

Per the academic-integrity policy: state clearly in your report where AI was
used. This scaffold was produced with AI assistance for structure and
boilerplate; all design decisions, screen implementations, and the report must
be authored and fully understood by the team, and every member must be able to
explain and modify the code live.
