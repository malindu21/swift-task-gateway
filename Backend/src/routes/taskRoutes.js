const express = require('express');
const taskController = require('../controllers/taskController');
const asyncHandler = require('../utils/asyncHandler');

const router = express.Router();

router.post('/tasks', asyncHandler(taskController.createTask));
router.get('/tasks', asyncHandler(taskController.listTasks));
router.patch('/tasks/:id/status', asyncHandler(taskController.updateStatus));
router.delete('/tasks/:id', asyncHandler(taskController.deleteTask));

module.exports = router;
