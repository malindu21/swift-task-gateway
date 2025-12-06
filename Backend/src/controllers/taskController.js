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

const updateStatus = async (req, res) => {
  const id = Number(req.params.id);
  const { status } = req.body || {};

  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ error: '`id` must be a positive integer' });
  }
  if (typeof status !== 'boolean') {
    return res.status(400).json({ error: '`status` must be a boolean' });
  }

  const updated = await taskService.updateTaskStatus({ id, status });
  if (!updated) {
    return res.status(404).json({ error: 'Task not found' });
  }

  return res.json({ data: updated });
};

const deleteTask = async (req, res) => {
  const id = Number(req.params.id);

  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ error: '`id` must be a positive integer' });
  }

  const removed = await taskService.deleteTask(id);
  if (!removed) {
    return res.status(404).json({ error: 'Task not found' });
  }

  return res.status(204).send();
};

module.exports = {
  createTask,
  listTasks,
  updateStatus,
  deleteTask,
};
