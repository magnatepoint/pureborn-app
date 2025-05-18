const mongoose = require('mongoose');

const purchaseSchema = new mongoose.Schema({
    date: {
        type: Date,
        required: true,
        default: Date.now
    },
    purchaseCategory: {
        type: String,
        required: true
    },
    rawMaterial: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'RawMaterial',
        required: true
    },
    pricePerKg: {
        type: Number,
        required: true
    },
    quantity: {
        type: Number,
        required: true
    },
    total: {
        type: Number,
        required: true
    },
    vendor: {
        type: String,
        required: true
    },
    payment: {
        type: Number,
        required: true
    },
    paymentMethod: {
        type: String,
        enum: ['Cash', 'Upi', 'Card', 'Credit'],
        required: true
    },
    balanceDue: {
        type: Number,
        required: true
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('Purchase', purchaseSchema); 