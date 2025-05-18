const mongoose = require("mongoose");

const rawMaterialSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, unique: true },
    description: { type: String },
    category: { type: String },
  },
  { timestamps: true },
);

module.exports = mongoose.model("RawMaterial", rawMaterialSchema);
