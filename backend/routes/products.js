const express = require('express');
const { body, validationResult } = require('express-validator');
const Product = require('../models/Product');
const SavedProduct = require('../models/SavedProduct');
const PriceAlert = require('../models/PriceAlert');
const authRouter = require('./auth');

const router = express.Router();

// GET /api/products - Get all products with optional filters
router.get('/', async (req, res) => {
  try {
    const { search, category, minPrice, maxPrice, limit = 20, page = 1 } = req.query;
    
    const query = {};
    
    // Search by name, brand, or category
    if (search) {
      query.$text = { $search: search };
    }
    
    if (category) {
      query.category = category;
    }
    
    // Price filtering
    if (minPrice || maxPrice) {
      query['prices.price'] = {};
      if (minPrice) query['prices.price'].$gte = parseFloat(minPrice);
      if (maxPrice) query['prices.price'].$lte = parseFloat(maxPrice);
    }
    
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    const products = await Product.find(query)
      .limit(parseInt(limit))
      .skip(skip)
      .sort({ lastScanned: -1 });
    
    const total = await Product.countDocuments(query);
    
    res.json({
      products,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });
  } catch (error) {
    console.error('Get products error:', error);
    res.status(500).json({ 
      message: 'Error fetching products',
      error: error.message 
    });
  }
});

// GET /api/products/:id - Get product by ID
router.get('/:id', async (req, res) => {
  try {
    const product = await Product.findById(req.params.id).populate('alternatives');
    
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }
    
    res.json(product);
  } catch (error) {
    console.error('Get product error:', error);
    res.status(500).json({ 
      message: 'Error fetching product',
      error: error.message 
    });
  }
});

// POST /api/products/search - Search for product by barcode or image
router.post('/search',
  body('barcode').optional().trim(),
  body('imageUrl').optional().isURL(),
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ 
          message: 'Validation failed', 
          errors: errors.array() 
        });
      }

      const { barcode, imageUrl, productName } = req.body;
      
      let product = null;
      
      // Search by barcode first
      if (barcode) {
        product = await Product.findOne({ barcode });
      }
      
      // If not found and we have an image URL, here we would use ML/AI
      // For now, we'll search by name if provided
      if (!product && productName) {
        product = await Product.findOne({ 
          name: new RegExp(productName, 'i') 
        });
      }
      
      if (product) {
        // Update scan count
        product.scanCount += 1;
        product.lastScanned = new Date();
        await product.save();
        
        res.json({ product });
      } else {
        // Product not found - could trigger API searches here
        res.status(404).json({ 
          message: 'Product not found',
          suggestion: 'Try scanning again or enter product name manually'
        });
      }
    } catch (error) {
      console.error('Search product error:', error);
      res.status(500).json({ 
        message: 'Error searching for product',
        error: error.message 
      });
    }
  }
);

// POST /api/products - Create a new product (admin/system use)
router.post('/',
  body('name').trim().notEmpty(),
  body('barcode').optional().trim(),
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ 
          message: 'Validation failed', 
          errors: errors.array() 
        });
      }

      const product = new Product(req.body);
      await product.save();
      
      res.status(201).json({
        message: 'Product created successfully',
        product
      });
    } catch (error) {
      console.error('Create product error:', error);
      res.status(500).json({ 
        message: 'Error creating product',
        error: error.message 
      });
    }
  }
);

// GET /api/products/:id/prices - Get current prices for a product
router.get('/:id/prices', async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }
    
    res.json({
      productId: product._id,
      productName: product.name,
      prices: product.prices.sort((a, b) => a.price - b.price)
    });
  } catch (error) {
    console.error('Get prices error:', error);
    res.status(500).json({ 
      message: 'Error fetching prices',
      error: error.message 
    });
  }
});

// POST /api/products/:id/save - Save product to favorites (requires auth)
router.post('/:id/save', authRouter.authenticateToken, async (req, res) => {
  try {
    const { notes } = req.body;
    
    const savedProduct = new SavedProduct({
      userId: req.userId,
      productId: req.params.id,
      notes
    });
    
    await savedProduct.save();
    
    res.status(201).json({
      message: 'Product saved to favorites',
      savedProduct
    });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(409).json({ 
        message: 'Product already saved to favorites' 
      });
    }
    console.error('Save product error:', error);
    res.status(500).json({ 
      message: 'Error saving product',
      error: error.message 
    });
  }
});

// GET /api/products/saved - Get user's saved products (requires auth)
router.get('/user/saved', authRouter.authenticateToken, async (req, res) => {
  try {
    const savedProducts = await SavedProduct.find({ userId: req.userId })
      .populate('productId')
      .sort({ savedAt: -1 });
    
    res.json({ savedProducts });
  } catch (error) {
    console.error('Get saved products error:', error);
    res.status(500).json({ 
      message: 'Error fetching saved products',
      error: error.message 
    });
  }
});

// POST /api/products/:id/alert - Create price alert (requires auth)
router.post('/:id/alert', 
  authRouter.authenticateToken,
  body('targetPrice').isFloat({ min: 0 }),
  body('store').optional().trim(),
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ 
          message: 'Validation failed', 
          errors: errors.array() 
        });
      }

      const { targetPrice, store } = req.body;
      
      const product = await Product.findById(req.params.id);
      if (!product) {
        return res.status(404).json({ message: 'Product not found' });
      }
      
      const alert = new PriceAlert({
        userId: req.userId,
        productId: req.params.id,
        targetPrice,
        store,
        currentPrice: product.prices[0]?.price
      });
      
      await alert.save();
      
      res.status(201).json({
        message: 'Price alert created successfully',
        alert
      });
    } catch (error) {
      console.error('Create alert error:', error);
      res.status(500).json({ 
        message: 'Error creating price alert',
        error: error.message 
      });
    }
  }
);

module.exports = router;
