const mongoose = require('mongoose');

const expenseSchema = new mongoose.Schema({
    date: {
        type: Date,
        required: true,
        default: Date.now
    },
    name: {
        type: String,
        required: true
    },
    description: {
        type: String,
        required: true
    },
    category: {
        type: String,
        required: true
    },
    payment: {
        cash: {
            type: Number,
            default: 0
        },
        online: {
            type: Number,
            default: 0
        },
        credit: {
            type: Number,
            default: 0
        }
    },
    total: {
        type: Number,
        required: true
    },
    balanceDue: {
        type: Number,
        default: 0
    },
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('Expense', expenseSchema); 