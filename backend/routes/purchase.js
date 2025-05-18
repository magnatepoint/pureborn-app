const express = require('express');
const router = express.Router();
const Purchase = require('../models/Purchase');

// Get all purchases
router.get('/', async (req, res) => {
    try {
        const purchases = await Purchase.find().populate('rawMaterial');
        res.json(purchases);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Create a new purchase
router.post('/', async (req, res) => {
    const purchase = new Purchase({
        date: req.body.date,
        purchaseCategory: req.body.purchaseCategory,
        rawMaterial: req.body.rawMaterial,
        pricePerKg: req.body.pricePerKg,
        quantity: req.body.quantity,
        total: req.body.pricePerKg * req.body.quantity,
        vendor: req.body.vendor,
        payment: req.body.payment,
        paymentMethod: req.body.paymentMethod,
        balanceDue: (req.body.pricePerKg * req.body.quantity) - req.body.payment
    });

    try {
        const newPurchase = await purchase.save();
        res.status(201).json(newPurchase);
    } catch (err) {
        console.error('Purchase creation error:', err);
        res.status(400).json({ message: err.message });
    }
});

// Get a specific purchase
router.get('/:id', async (req, res) => {
    try {
        const purchase = await Purchase.findById(req.params.id).populate('rawMaterial');
        if (purchase) {
            res.json(purchase);
        } else {
            res.status(404).json({ message: 'Purchase not found' });
        }
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Update a purchase
router.patch('/:id', async (req, res) => {
    try {
        const purchase = await Purchase.findById(req.params.id);
        if (purchase) {
            Object.keys(req.body).forEach(key => {
                purchase[key] = req.body[key];
            });
            // Recalculate total and balance due
            purchase.total = purchase.pricePerKg * purchase.quantity;
            purchase.balanceDue = purchase.total - purchase.payment;
            
            const updatedPurchase = await purchase.save();
            res.json(updatedPurchase);
        } else {
            res.status(404).json({ message: 'Purchase not found' });
        }
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// Delete a purchase
router.delete('/:id', async (req, res) => {
    try {
        const deleted = await Purchase.findByIdAndDelete(req.params.id);
        if (deleted) {
            res.json({ message: 'Purchase deleted' });
        } else {
            res.status(404).json({ message: 'Purchase not found' });
        }
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router; 