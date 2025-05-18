const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { auth, adminAuth } = require('../middleware/auth');

// Register new user
router.post('/register', async (req, res) => {
  try {
    const { email, password, name } = req.body;
    
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ error: 'Email already registered' });
    }

    const user = new User({ email, password, name });
    await user.save();

    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    res.status(201).json({ user, token });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Login user
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    const user = await User.findOne({ email });
    if (!user || !user.isActive) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    res.json({ user, token });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Get current user profile
router.get('/me', auth, async (req, res) => {
  res.json(req.user);
});

// Admin routes
router.get('/users', adminAuth, async (req, res) => {
  try {
    const users = await User.find({}, '-password');
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.patch('/users/:id', adminAuth, async (req, res) => {
  try {
    const updates = Object.keys(req.body);
    const allowedUpdates = ['name', 'email', 'role', 'isActive'];
    const isValidOperation = updates.every(update => allowedUpdates.includes(update));

    if (!isValidOperation) {
      return res.status(400).json({ error: 'Invalid updates' });
    }

    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    updates.forEach(update => user[update] = req.body[update]);
    await user.save();

    res.json(user);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

router.patch('/me', auth, async (req, res) => {
  try {
    const allowedUpdates = ['name', 'email'];
    const updates = Object.keys(req.body);
    const isValid = updates.every(update => allowedUpdates.includes(update));
    if (!isValid) return res.status(400).json({ error: 'Invalid updates' });

    updates.forEach(update => req.user[update] = req.body[update]);
    await req.user.save();
    res.json(req.user);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

router.post('/change-password', auth, async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;
    if (!oldPassword || !newPassword) {
      return res.status(400).json({ error: 'Both old and new password required' });
    }
    const isMatch = await req.user.comparePassword(oldPassword);
    if (!isMatch) {
      return res.status(400).json({ error: 'Old password is incorrect' });
    }
    req.user.password = newPassword;
    await req.user.save();
    res.json({ message: 'Password changed successfully' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

router.delete('/me', auth, async (req, res) => {
  try {
    await req.user.deleteOne();
    res.json({ message: 'Account deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router; 