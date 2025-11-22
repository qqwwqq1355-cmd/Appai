const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const visionService = require('../services/visionService');

// Configure multer for file uploads
const upload = multer({
  dest: 'uploads/temp/',
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB max
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only JPEG, PNG, and WebP are allowed.'));
    }
  },
});

// Ensure upload directory exists
const uploadDir = path.join(__dirname, '../uploads/temp');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

/**
 * Google Cloud Vision API Routes
 * 
 * Endpoints for AI-powered image analysis and product recognition
 */

// GET /api/vision/status - Check if Vision API is configured
router.get('/status', (req, res) => {
  const isConfigured = visionService.isConfigured();
  
  res.json({
    configured: isConfigured,
    message: isConfigured 
      ? 'Google Cloud Vision is configured and ready' 
      : 'Google Cloud Vision not configured. Please set GOOGLE_APPLICATION_CREDENTIALS in .env',
    setup: {
      console: 'https://console.cloud.google.com',
      docs: 'https://cloud.google.com/vision/docs',
      steps: [
        '1. Create a GCP project',
        '2. Enable Cloud Vision API',
        '3. Create Service Account with Vision API role',
        '4. Download JSON key file',
        '5. Save as backend/config/google-cloud-key.json',
        '6. Set GOOGLE_APPLICATION_CREDENTIALS in .env',
      ]
    }
  });
});

// POST /api/vision/analyze - Analyze an image (comprehensive)
router.post('/analyze', upload.single('image'), async (req, res) => {
  let filePath = null;

  try {
    if (!visionService.isConfigured()) {
      return res.status(503).json({
        message: 'Google Cloud Vision not configured',
      });
    }

    if (!req.file) {
      return res.status(400).json({
        message: 'No image file provided',
      });
    }

    filePath = req.file.path;

    const analysis = await visionService.analyzeImage(filePath);

    res.json({
      success: true,
      analysis: analysis,
    });
  } catch (error) {
    console.error('Image analysis error:', error);
    res.status(500).json({
      message: 'Failed to analyze image',
      error: error.message
    });
  } finally {
    // Clean up uploaded file
    if (filePath && fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }
  }
});

// POST /api/vision/detect-product - Detect product in image
router.post('/detect-product', upload.single('image'), async (req, res) => {
  let filePath = null;

  try {
    if (!visionService.isConfigured()) {
      return res.status(503).json({
        message: 'Google Cloud Vision not configured',
      });
    }

    if (!req.file) {
      return res.status(400).json({
        message: 'No image file provided',
      });
    }

    filePath = req.file.path;

    const product = await visionService.detectProduct(filePath);

    res.json({
      success: true,
      product: product,
    });
  } catch (error) {
    console.error('Product detection error:', error);
    res.status(500).json({
      message: 'Failed to detect product',
      error: error.message
    });
  } finally {
    // Clean up uploaded file
    if (filePath && fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }
  }
});

// POST /api/vision/extract-text - Extract text from image (OCR)
router.post('/extract-text', upload.single('image'), async (req, res) => {
  let filePath = null;

  try {
    if (!visionService.isConfigured()) {
      return res.status(503).json({
        message: 'Google Cloud Vision not configured',
      });
    }

    if (!req.file) {
      return res.status(400).json({
        message: 'No image file provided',
      });
    }

    filePath = req.file.path;

    const text = await visionService.extractText(filePath);

    res.json({
      success: true,
      text: text,
    });
  } catch (error) {
    console.error('Text extraction error:', error);
    res.status(500).json({
      message: 'Failed to extract text',
      error: error.message
    });
  } finally {
    // Clean up uploaded file
    if (filePath && fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }
  }
});

// POST /api/vision/suggestions - Get product name suggestions from image
router.post('/suggestions', upload.single('image'), async (req, res) => {
  let filePath = null;

  try {
    if (!visionService.isConfigured()) {
      return res.status(503).json({
        message: 'Google Cloud Vision not configured',
      });
    }

    if (!req.file) {
      return res.status(400).json({
        message: 'No image file provided',
      });
    }

    filePath = req.file.path;

    const suggestions = await visionService.getProductSuggestions(filePath);

    res.json({
      success: true,
      count: suggestions.length,
      suggestions: suggestions,
    });
  } catch (error) {
    console.error('Suggestions error:', error);
    res.status(500).json({
      message: 'Failed to get suggestions',
      error: error.message
    });
  } finally {
    // Clean up uploaded file
    if (filePath && fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }
  }
});

// POST /api/vision/detect-logos - Detect brand logos in image
router.post('/detect-logos', upload.single('image'), async (req, res) => {
  let filePath = null;

  try {
    if (!visionService.isConfigured()) {
      return res.status(503).json({
        message: 'Google Cloud Vision not configured',
      });
    }

    if (!req.file) {
      return res.status(400).json({
        message: 'No image file provided',
      });
    }

    filePath = req.file.path;

    const logos = await visionService.detectLogos(filePath);

    res.json({
      success: true,
      count: logos.length,
      logos: logos,
    });
  } catch (error) {
    console.error('Logo detection error:', error);
    res.status(500).json({
      message: 'Failed to detect logos',
      error: error.message
    });
  } finally {
    // Clean up uploaded file
    if (filePath && fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }
  }
});

module.exports = router;
