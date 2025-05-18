const mongoose = require('mongoose');

const vendorSchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true },
  contact: { type: String },
  address: { type: String },
}, { timestamps: true });

module.exports = mongoose.model('Vendor', vendorSchema); 