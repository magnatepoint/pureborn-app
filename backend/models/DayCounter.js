const mongoose = require('mongoose');

const dayCounterSchema = new mongoose.Schema({
    date: {
        type: Date,
        required: true
    },
    openingBalance: {
        type: Number,
        required: true
    },
    payments: {
        cash: {
            type: Number,
            default: 0
        },
        upi: {
            type: Number,
            default: 0
        },
        card: {
            type: Number,
            default: 0
        },
        credit: {
            type: Number,
            default: 0
        }
    },
    expenses: {
        type: Number,
        default: 0
    },
    totalDayCounter: {
        type: Number,
        default: 0
    },
    cashHandOver: {
        type: Number,
        default: 0
    },
    actualClosingCounter: {
        type: Number,
        default: 0
    },
    closingBalance: {
        type: Number,
        default: 0
    },
    difference: {
        type: Number,
        default: 0
    },
    remarks: {
        type: String,
        default: ''
    }
}, {
    timestamps: true
});

// Calculate total day counter before saving
dayCounterSchema.pre('save', function(next) {
    this.totalDayCounter = this.payments.cash + this.payments.upi + 
                          this.payments.card + this.payments.credit;
    
    this.actualClosingCounter = (this.openingBalance + this.payments.cash) - this.expenses;
    
    this.difference = this.actualClosingCounter - (this.closingBalance + this.cashHandOver);
    
    next();
});

module.exports = mongoose.model('DayCounter', dayCounterSchema); 