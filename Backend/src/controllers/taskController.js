const taskService = require('../services/taskService');

const createTask = async (req, res) => {
  const { task, status } = req.body || {};

  if (typeof task !== 'string' || task.trim() === '') {
    return res.status(400).json({ error: '`task` must be a non-empty string' });
  }

  if (typeof status !== 'boolean') {
    return res.status(400).json({ error: '`status` must be a boolean' });
  }

  const createdTask = await taskService.createTask({ task, status });
  return res.status(201).json({
    message: 'Task saved',
    data: createdTask,
  });
};

const listTasks = async (_req, res) => {
  const data = await taskService.listTasks();
  return res.json({ data });
};

module.exports = {
  createTask,
  listTasks,
};
