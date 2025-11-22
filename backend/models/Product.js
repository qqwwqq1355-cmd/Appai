const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  barcode: {
    type: String,
    index: true,
    sparse: true
  },
  imageUrl: String,
  category: String,
  brand: String,
  description: String,
  prices: [{
    store: {
      type: String,
      required: true
    },
    price: {
      type: Number,
      required: true
    },
    currency: {
      type: String,
      default: 'USD'
    },
    url: String,
    lastUpdated: {
      type: Date,
      default: Date.now
    }
  }],
  reviews: {
    average: {
      type: Number,
      min: 0,
      max: 5,
      default: 0
    },
    count: {
      type: Number,
      default: 0
    }
  },
  alternatives: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product'
  }],
  coupons: [{
    code: String,
    discount: String,
    description: String,
    expiryDate: Date
  }],
  lastScanned: {
    type: Date,
    default: Date.now
  },
  scanCount: {
    type: Number,
    default: 0
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Index for search
productSchema.index({ name: 'text', brand: 'text', category: 'text' });

module.exports = mongoose.model('Product', productSchema);
