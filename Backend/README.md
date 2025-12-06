## Task API (Express + Postgres)

- Clean layered structure: config → db → services → controllers → routes → app entry.
- Endpoints: `POST /tasks`, `GET /tasks`.
- Uses Postgres (Heroku-compatible SSL). The server auto-creates the `tasks` table.

### Structure
```
Backend/
  src/
    config/env.js
    db/{pool.js, init.js}
    services/taskService.js
    controllers/taskController.js
    routes/taskRoutes.js
    middleware/errorHandler.js
    utils/asyncHandler.js
    app.js
    index.js
```

### Install
```bash
cd Backend
npm install
```

### Configure database
- Set `POSTGRES_URL` (or `DATABASE_URL`) with a full connection string, e.g. `postgres://user:pass@host:5432/dbname`.
- Set `PG_SSL=false` to disable SSL locally (default uses SSL for Heroku).

### Run
```bash
cd Backend
POSTGRES_URL="postgres://user:pass@localhost:5432/tasks_db" npm start
# Optional: custom port
PORT=4000 POSTGRES_URL="..." npm start
```

### POST /tasks
- Body JSON: `task` (string), `status` (boolean).
```json
{
  "task": "Write documentation",
  "status": true
}
```

### GET /tasks
- Returns all saved tasks from the configured database.

### Sample curl
```bash
curl -X POST http://localhost:3000/tasks \
  -H "Content-Type: application/json" \
  -d '{"task":"Test via curl","status":false}'
```
