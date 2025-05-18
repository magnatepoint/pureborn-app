require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const authRoutes = require('./routes/auth');
const purchaseRoutes = require('./routes/purchase');
const expenseRoutes = require('./routes/expense');
const dayCounterRoutes = require('./routes/dayCounter');
const productRoutes = require('./routes/productRoutes');
const rawMaterialRoutes = require('./routes/rawMaterial');
const purchaseCategoryRoutes = require('./routes/purchaseCategory');
const vendorRoutes = require('./routes/vendor');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/purchases', purchaseRoutes);
app.use('/api/expenses', expenseRoutes);
app.use('/api/day-counters', dayCounterRoutes);
app.use('/api/products', productRoutes);
app.use('/api/raw-materials', rawMaterialRoutes);
app.use('/api/purchase-categories', purchaseCategoryRoutes);
app.use('/api/vendors', vendorRoutes);

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('MongoDB connection error:', err));

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
}); 