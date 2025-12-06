## Task API (Express + Postgres)

- Endpoints: `POST /tasks`, `GET /tasks`.
- Uses Postgres (Heroku-compatible SSL). The server auto-creates a `tasks` table if it does not exist.

### Install
```bash
npm install
```

### Configure database
- Set `POSTGRES_URL` (or `DATABASE_URL`) with a full connection string, e.g. `postgres://user:pass@host:5432/dbname`.

### Run
```bash
# Run
POSTGRES_URL="postgres://user:pass@localhost:5432/tasks_db" node server.js

# Optional: set port
PORT=4000 POSTGRES_URL="..." node server.js
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
