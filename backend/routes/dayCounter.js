const express = require('express');
const router = express.Router();
const DayCounter = require('../models/DayCounter');

// Create a new day counter
router.post('/', async (req, res) => {
    try {
        const dayCounter = new DayCounter(req.body);
        await dayCounter.save();
        res.status(201).json(dayCounter);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

// Get all day counters
router.get('/', async (req, res) => {
    try {
        const dayCounters = await DayCounter.find().sort({ date: -1 });
        res.json(dayCounters);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Get a specific day counter
router.get('/:id', async (req, res) => {
    try {
        const dayCounter = await DayCounter.findById(req.params.id);
        if (!dayCounter) {
            return res.status(404).json({ message: 'Day counter not found' });
        }
        res.json(dayCounter);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Update a day counter
router.put('/:id', async (req, res) => {
    try {
        const dayCounter = await DayCounter.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true, runValidators: true }
        );
        if (!dayCounter) {
            return res.status(404).json({ message: 'Day counter not found' });
        }
        res.json(dayCounter);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

// Delete a day counter
router.delete('/:id', async (req, res) => {
    try {
        const dayCounter = await DayCounter.findByIdAndDelete(req.params.id);
        if (!dayCounter) {
            return res.status(404).json({ message: 'Day counter not found' });
        }
        res.json({ message: 'Day counter deleted' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router; 