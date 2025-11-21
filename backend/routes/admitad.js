const express = require('express');
const router = express.Router();
const admitadService = require('../services/admitadService');
const authRouter = require('./auth');

/**
 * Admitad API Routes
 * 
 * Endpoints for fetching products and generating affiliate links
 * from multiple stores via Admitad network
 */

// GET /api/admitad/status - Check if Admitad is configured
router.get('/status', (req, res) => {
  const isConfigured = admitadService.isConfigured();
  
  res.json({
    configured: isConfigured,
    message: isConfigured 
      ? 'Admitad API is configured and ready' 
      : 'Admitad API credentials not set. Please configure ADMITAD_CLIENT_ID and ADMITAD_CLIENT_SECRET in .env',
    setup: {
      register: 'https://publishers.admitad.com',
      docs: 'https://developers.admitad.com/en/',
    }
  });
});

// GET /api/admitad/stores - Get list of available stores/advertisers
router.get('/stores', async (req, res) => {
  try {
    if (!admitadService.isConfigured()) {
      return res.status(503).json({
        message: 'Admitad API not configured',
        setup: 'https://publishers.admitad.com'
      });
    }

    const stores = await admitadService.getAdvertisers();
    
    res.json({
      count: stores.length,
      stores: stores,
    });
  } catch (error) {
    console.error('Get stores error:', error);
    res.status(500).json({
      message: 'Failed to fetch stores',
      error: error.message
    });
  }
});

// GET /api/admitad/search - Search products across all stores
router.get('/search', async (req, res) => {
  try {
    if (!admitadService.isConfigured()) {
      return res.status(503).json({
        message: 'Admitad API not configured',
      });
    }

    const { q, query, limit = 20, offset = 0 } = req.query;
    const searchQuery = q || query;

    if (!searchQuery) {
      return res.status(400).json({
        message: 'Query parameter required (q or query)',
      });
    }

    const products = await admitadService.searchProducts({
      query: searchQuery,
      limit: parseInt(limit),
      offset: parseInt(offset),
    });

    res.json({
      query: searchQuery,
      count: products.length,
      products: products,
    });
  } catch (error) {
    console.error('Search error:', error);
    res.status(500).json({
      message: 'Product search failed',
      error: error.message
    });
  }
});

// GET /api/admitad/category/:categoryId - Get products by category
router.get('/category/:categoryId', async (req, res) => {
  try {
    if (!admitadService.isConfigured()) {
      return res.status(503).json({
        message: 'Admitad API not configured',
      });
    }

    const { categoryId } = req.params;
    const { limit = 20 } = req.query;

    const products = await admitadService.getProductsByCategory({
      categoryId: parseInt(categoryId),
      limit: parseInt(limit),
    });

    res.json({
      categoryId,
      count: products.length,
      products: products,
    });
  } catch (error) {
    console.error('Category products error:', error);
    res.status(500).json({
      message: 'Failed to fetch category products',
      error: error.message
    });
  }
});

// POST /api/admitad/affiliate-link - Generate affiliate link
router.post('/affiliate-link', authRouter.authenticateToken, async (req, res) => {
  try {
    if (!admitadService.isConfigured()) {
      return res.status(503).json({
        message: 'Admitad API not configured',
      });
    }

    const { url, campaignId } = req.body;

    if (!url) {
      return res.status(400).json({
        message: 'Product URL is required',
      });
    }

    const affiliateLink = await admitadService.generateAffiliateLink(
      url,
      campaignId
    );

    res.json({
      originalUrl: url,
      affiliateUrl: affiliateLink,
    });
  } catch (error) {
    console.error('Affiliate link error:', error);
    res.status(500).json({
      message: 'Failed to generate affiliate link',
      error: error.message
    });
  }
});

// GET /api/admitad/recommendations - Get product recommendations
router.get('/recommendations', async (req, res) => {
  try {
    if (!admitadService.isConfigured()) {
      return res.status(503).json({
        message: 'Admitad API not configured',
      });
    }

    const { product, limit = 5 } = req.query;

    if (!product) {
      return res.status(400).json({
        message: 'Product name required',
      });
    }

    const recommendations = await admitadService.getRecommendations(
      product,
      parseInt(limit)
    );

    res.json({
      product,
      count: recommendations.length,
      recommendations: recommendations,
    });
  } catch (error) {
    console.error('Recommendations error:', error);
    res.status(500).json({
      message: 'Failed to fetch recommendations',
      error: error.message
    });
  }
});

module.exports = router;
