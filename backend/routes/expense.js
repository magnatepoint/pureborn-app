const express = require('express');
const router = express.Router();
const Expense = require('../models/Expense');
const auth = require('../middleware/auth');

// Middleware to log Authorization header
router.use((req, res, next) => {
  console.log('Authorization header:', req.headers.authorization);
  next();
});

// Create a new expense
router.post('/', auth.auth, async (req, res) => {
    try {
        console.log('Expense POST body:', req.body);
        const expense = new Expense({
            ...req.body,
            user: req.user._id
        });
        await expense.save();
        res.status(201).json(expense);
    } catch (error) {
        console.error('Expense creation error:', error.message);
        res.status(400).json({ error: error.message });
    }
});

// Get all expenses for a user
router.get('/', auth.auth, async (req, res) => {
    try {
        const expenses = await Expense.find({ user: req.user._id });
        res.json(expenses);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get a specific expense
router.get('/:id', auth.auth, async (req, res) => {
    try {
        const expense = await Expense.findOne({ _id: req.params.id, user: req.user._id });
        if (!expense) {
            return res.status(404).json({ error: 'Expense not found' });
        }
        res.json(expense);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Update an expense
router.patch('/:id', auth.auth, async (req, res) => {
    try {
        const expense = await Expense.findOneAndUpdate(
            { _id: req.params.id, user: req.user._id },
            req.body,
            { new: true, runValidators: true }
        );
        if (!expense) {
            return res.status(404).json({ error: 'Expense not found' });
        }
        res.json(expense);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// Delete an expense
router.delete('/:id', auth.auth, async (req, res) => {
    try {
        const expense = await Expense.findOneAndDelete({ _id: req.params.id, user: req.user._id });
        if (!expense) {
            return res.status(404).json({ error: 'Expense not found' });
        }
        res.json(expense);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router; 