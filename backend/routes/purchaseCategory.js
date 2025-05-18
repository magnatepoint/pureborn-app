const express = require("express");
const PurchaseCategory = require("../models/PurchaseCategory");
const router = express.Router();

// Get all purchase categories
router.get("/", async (req, res) => {
  try {
    const categories = await PurchaseCategory.find();
    res.json(categories);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get a single purchase category by ID
router.get("/:id", async (req, res) => {
  try {
    const category = await PurchaseCategory.findById(req.params.id);
    if (!category) return res.status(404).json({ error: "Not found" });
    res.json(category);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create a new purchase category
router.post("/", async (req, res) => {
  try {
    const category = new PurchaseCategory(req.body);
    await category.save();
    res.status(201).json(category);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Update a purchase category
router.put("/:id", async (req, res) => {
  try {
    const category = await PurchaseCategory.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true },
    );
    if (!category) return res.status(404).json({ error: "Not found" });
    res.json(category);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Delete a purchase category
router.delete("/:id", async (req, res) => {
  try {
    const category = await PurchaseCategory.findByIdAndDelete(req.params.id);
    if (!category) return res.status(404).json({ error: "Not found" });
    res.json({ message: "Deleted" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
