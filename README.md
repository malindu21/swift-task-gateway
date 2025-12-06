# Tasks App — SwiftUI + Node/Express + Postgres

An end-to-end tasks experience: a SwiftUI client built with MVVM and async/await, talking to a lightweight Express API backed by Postgres. Clean layers, explicit networking, and ready-to-ship CI/CD.

## Tech Stack
- **iOS:** SwiftUI, MVVM, async/await networking, ISO8601 formatting, swipe actions, optimistic UI for status toggles/deletes.
- **Backend:** Node.js, Express, Postgres (`pg`), modular layers (config → db → services → controllers → routes → middleware), async handlers, Heroku-compatible SSL.
- **CI/CD:** GitHub Actions (Node 20) with Heroku deploy using the Backend subtree.

## Project Structure
```
Apps/iOS/TaskAppSwiftUI/
  TaskAppSwiftUI/                 # SwiftUI app target
    TaskAppSwiftUIApp.swift       # App entry
    ContentView.swift             # Screens, list UI, swipe-to-delete, toggle status
    Models/Task.swift             # TaskItem model + date formatting
    Networking/TaskService.swift  # async/await API client
    ViewModels/TaskListViewModel.swift # MVVM state, optimistic updates, error handling

Backend/
  src/
    config/env.js           # Env wiring (PORT, POSTGRES_URL, PG_SSL)
    db/pool.js              # pg pool with SSL toggle
    db/init.js              # schema bootstrap (tasks table)
    services/taskService.js # DB I/O for tasks (create/list/update status/delete)
    controllers/taskController.js # Validation + HTTP responses
    routes/taskRoutes.js    # /tasks endpoints (POST, GET, PATCH status, DELETE)
    middleware/errorHandler.js # 404 + error responses
    utils/asyncHandler.js   # Promise wrapper for route handlers
    app.js                  # Express app wiring
    index.js                # Bootstrap (ensure schema, start server)
  package.json              # Backend scripts/deps
  README.md                 # Backend-specific run instructions

.github/workflows/          # CI + Heroku deploy (Backend subtree)
```

## API (Backend)
- `POST /tasks` `{ task: string, status: boolean }`
- `GET /tasks` → `{ data: Task[] }`
- `PATCH /tasks/:id/status` `{ status: boolean }`
- `DELETE /tasks/:id`

Tasks fields: `id`, `task`, `status`, `createdAt`.

## Running the Backend (local)
```bash
cd Backend
POSTGRES_URL="postgres://user:pass@localhost:5432/tasks_db" npm install
PG_SSL=false npm start   # disable SSL locally; default expects SSL (Heroku)
```

## Running the iOS App
- Open `Apps/iOS/TaskAppSwiftUI/TaskAppSwiftUI.xcodeproj`.
- Build/run the `TaskAppSwiftUI` target (iOS Simulator).
- The app hits `https://swift-task-gateway-743d3a89ff77.herokuapp.com/tasks`. To point at local, swap the base URL in `TaskService.urlString`.

### iOS UX Highlights
- Pull-to-refresh, loading overlay, empty/error states.
- Swipe-to-delete with optimistic removal and rollback on failure.
- Tap status chip to toggle completion; shows in-flight spinner and rollback on failure.
- Safe state tracking for concurrent updates (`updatingTaskIds`, `deletingTaskIds`).

## CI/CD
- **CI:** `.github/workflows/ci.yml` installs/runs backend scripts in `Backend/`.
- **Deploy:** `.github/workflows/deploy-heroku.yml` builds in `Backend/` and force-pushes the Backend subtree to Heroku `main`.

## Environment
- `POSTGRES_URL` (or `DATABASE_URL`) required for the API.
- `PG_SSL=false` to run locally without SSL.
- Optional `PORT` (default 3000).

## Notes
- iOS client uses optimistic updates; backend errors will rollback UI state and surface an alert.
- Backend auto-creates `tasks` table on startup; safe for repeated launches.
