const express = require('express');
const router = express.Router();

// In a real application, this data would come from a database.
const products = [
  {
    id: 1,
    name: 'Wireless Headphones',
    prices: [
      { store: 'Amazon', price: 199.99 },
      { store: 'eBay', price: 189.99 },
    ],
    reviews: {
      average: 4.5,
      count: 1500,
    },
    alternatives: [
      { id: 2, name: 'Noise-Cancelling Earbuds' },
    ],
    coupons: [
      { code: 'SAVE10', discount: '10%' },
    ],
  },
  {
    id: 2,
    name: 'Noise-Cancelling Earbuds',
    prices: [
      { store: 'Amazon', price: 149.99 },
      { store: 'Best Buy', price: 159.99 },
    ],
    reviews: {
      average: 4.2,
      count: 800,
    },
    alternatives: [],
    coupons: [],
  },
];

// GET /products
// Returns a list of all products.
router.get('/', (req, res) => {
  res.json(products);
});

// GET /products/:id
// Returns a single product by ID.
router.get('/:id', (req, res) => {
  const product = products.find((p) => p.id === parseInt(req.params.id));
  if (!product) {
    return res.status(404).json({ message: 'Product not found' });
  }
  res.json(product);
});

module.exports = router;
