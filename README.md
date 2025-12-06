## Task API (Express + Postgres/MySQL)

- Endpoints: `POST /tasks`, `GET /tasks`.
- Supports Postgres or MySQL. Choose via `DB_CLIENT=postgres` or `DB_CLIENT=mysql`.
- The server will auto-create a `tasks` table if it does not exist.

### Install
```bash
npm install
```

### Configure database
- Postgres: set `DB_CLIENT=postgres` and `POSTGRES_URL` (or `DATABASE_URL`) with a full connection string, e.g. `postgres://user:pass@host:5432/dbname`.
- MySQL: set `DB_CLIENT=mysql` and `MYSQL_URL`, e.g. `mysql://user:pass@host:3306/dbname`.

### Run
```bash
# Postgres example
DB_CLIENT=postgres POSTGRES_URL="postgres://user:pass@localhost:5432/tasks_db" node server.js

# MySQL example
DB_CLIENT=mysql MYSQL_URL="mysql://user:pass@localhost:3306/tasks_db" node server.js

# Optional: set port
PORT=4000 DB_CLIENT=postgres POSTGRES_URL="..." node server.js
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
