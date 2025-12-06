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

const updateTaskStatus = async ({ id, status }) => {
  const result = await pool.query(
    'UPDATE tasks SET status = $2 WHERE id = $1 RETURNING id, task, status, created_at;',
    [id, status],
  );
  return result.rowCount ? mapRow(result.rows[0]) : null;
};

const deleteTask = async (id) => {
  const result = await pool.query('DELETE FROM tasks WHERE id = $1 RETURNING id;', [id]);
  return result.rowCount > 0;
};

module.exports = {
  createTask,
  listTasks,
  updateTaskStatus,
  deleteTask,
};
