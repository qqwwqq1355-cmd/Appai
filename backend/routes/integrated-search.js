const express = require('express');
const router = express.Router();
const multer = require('multer');
const admitadService = require('../services/admitadService');
const visionService = require('../services/visionService');
const Product = require('../models/Product');

// Configure multer for file uploads
const upload = multer({
  dest: 'uploads/temp/',
  limits: { fileSize: 10 * 1024 * 1024 },
});

/**
 * Integrated Search Routes
 * 
 * Combines barcode scanning, Vision API, and Admitad API
 * for comprehensive product search
 */

// POST /api/search/by-image - Search products by image
router.post('/by-image', upload.single('image'), async (req, res) => {
  try {
    // 1. Use Vision API to identify product
    let productSuggestions = [];
    if (visionService.isConfigured() && req.file) {
      try {
        productSuggestions = await visionService.getProductSuggestions(req.file.path);
      } catch (error) {
        console.log('Vision API unavailable, continuing without it');
      }
    }

    // 2. Search in our database first
    let localProducts = [];
    if (productSuggestions.length > 0) {
      const searchQuery = productSuggestions[0];
      localProducts = await Product.find({
        $text: { $search: searchQuery }
      }).limit(5);
    }

    // 3. Search in Admitad if configured
    let admitadProducts = [];
    if (admitadService.isConfigured() && productSuggestions.length > 0) {
      try {
        admitadProducts = await admitadService.searchProducts({
          query: productSuggestions[0],
          limit: 10
        });
      } catch (error) {
        console.log('Admitad API unavailable');
      }
    }

    res.json({
      success: true,
      suggestions: productSuggestions,
      results: {
        local: localProducts,
        online: admitadProducts,
        total: localProducts.length + admitadProducts.length
      }
    });
  } catch (error) {
    console.error('Image search error:', error);
    res.status(500).json({
      message: 'Failed to search by image',
      error: error.message
    });
  }
});

// POST /api/search/by-barcode - Search by barcode with fallback
router.post('/by-barcode', async (req, res) => {
  try {
    const { barcode } = req.body;

    if (!barcode) {
      return res.status(400).json({
        message: 'Barcode required'
      });
    }

    // 1. Search in local database
    let product = await Product.findOne({ barcode });

    // 2. If not found locally and Admitad is configured, try searching by barcode
    // Note: Admitad doesn't support barcode search directly
    // You would need to maintain a barcode-to-product-name mapping
    
    if (!product && admitadService.isConfigured()) {
      // For now, return a message that we need the product name
      return res.json({
        success: false,
        barcode,
        message: 'Product not found in database. Please use image search or enter product name.',
        suggestion: 'Use /api/search/by-image or /api/search/by-name'
      });
    }

    res.json({
      success: !!product,
      product: product,
      source: product ? 'database' : null
    });
  } catch (error) {
    console.error('Barcode search error:', error);
    res.status(500).json({
      message: 'Failed to search by barcode',
      error: error.message
    });
  }
});

// GET /api/search/by-name - Search by product name
router.get('/by-name', async (req, res) => {
  try {
    const { name, limit = 20 } = req.query;

    if (!name) {
      return res.status(400).json({
        message: 'Product name required'
      });
    }

    const results = {
      local: [],
      online: []
    };

    // 1. Search local database
    results.local = await Product.find({
      $text: { $search: name }
    }).limit(5);

    // 2. Search Admitad
    if (admitadService.isConfigured()) {
      try {
        results.online = await admitadService.searchProducts({
          query: name,
          limit: parseInt(limit)
        });
      } catch (error) {
        console.log('Admitad search failed, using local results only');
      }
    }

    res.json({
      success: true,
      query: name,
      results: results,
      total: results.local.length + results.online.length
    });
  } catch (error) {
    console.error('Name search error:', error);
    res.status(500).json({
      message: 'Failed to search by name',
      error: error.message
    });
  }
});

// GET /api/search/smart - Smart search with all methods
router.get('/smart', async (req, res) => {
  try {
    const { query, limit = 20 } = req.query;

    if (!query) {
      return res.status(400).json({
        message: 'Search query required'
      });
    }

    const allResults = [];

    // 1. Search local database
    const localProducts = await Product.find({
      $or: [
        { name: new RegExp(query, 'i') },
        { barcode: query },
        { brand: new RegExp(query, 'i') }
      ]
    }).limit(5);

    allResults.push(...localProducts.map(p => ({
      ...p.toObject(),
      source: 'local',
      priority: 1
    })));

    // 2. Search Admitad if configured
    if (admitadService.isConfigured()) {
      try {
        const admitadProducts = await admitadService.searchProducts({
          query,
          limit: parseInt(limit)
        });
        
        allResults.push(...admitadProducts.map(p => ({
          ...p,
          source: 'admitad',
          priority: 2
        })));
      } catch (error) {
        console.log('Admitad unavailable');
      }
    }

    // Sort by priority (local first) and limit results
    allResults.sort((a, b) => a.priority - b.priority);
    const limitedResults = allResults.slice(0, parseInt(limit));

    res.json({
      success: true,
      query,
      count: limitedResults.length,
      results: limitedResults
    });
  } catch (error) {
    console.error('Smart search error:', error);
    res.status(500).json({
      message: 'Search failed',
      error: error.message
    });
  }
});

module.exports = router;
