const pool = require('../db/pool');

const mapRow = (row) => ({
  id: row.id,
  task: row.task,
  status: row.status,
  createdAt: row.created_at,
});

const createTask = async ({ task, status }) => {
  const result = await pool.query(
    'INSERT INTO tasks (task, status) VALUES ($1, $2) RETURNING id, task, status, created_at;',
    [task.trim(), status],
  );
  return mapRow(result.rows[0]);
};

const listTasks = async () => {
  const result = await pool.query('SELECT id, task, status, created_at FROM tasks ORDER BY id DESC;');
  return result.rows.map(mapRow);
};

module.exports = {
  createTask,
  listTasks,
};
