const express = require("express");
const RawMaterial = require("../models/RawMaterial");
const router = express.Router();

// Get all raw materials
router.get("/", async (req, res) => {
  try {
    const materials = await RawMaterial.find();
    res.json(materials);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get a single raw material by ID
router.get("/:id", async (req, res) => {
  try {
    const material = await RawMaterial.findById(req.params.id);
    if (!material) return res.status(404).json({ error: "Not found" });
    res.json(material);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create a new raw material
router.post("/", async (req, res) => {
  try {
    const material = new RawMaterial(req.body);
    await material.save();
    res.status(201).json(material);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Update a raw material
router.put("/:id", async (req, res) => {
  try {
    const material = await RawMaterial.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true },
    );
    if (!material) return res.status(404).json({ error: "Not found" });
    res.json(material);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Delete a raw material
router.delete("/:id", async (req, res) => {
  try {
    const material = await RawMaterial.findByIdAndDelete(req.params.id);
    if (!material) return res.status(404).json({ error: "Not found" });
    res.json({ message: "Deleted" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
