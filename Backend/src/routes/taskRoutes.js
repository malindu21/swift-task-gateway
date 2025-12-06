const express = require('express');
const taskController = require('../controllers/taskController');
const asyncHandler = require('../utils/asyncHandler');

const router = express.Router();

router.post('/tasks', asyncHandler(taskController.createTask));
router.get('/tasks', asyncHandler(taskController.listTasks));

module.exports = router;
