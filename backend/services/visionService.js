const vision = require('@google-cloud/vision');
const path = require('path');

/**
 * Google Cloud Vision Service
 * 
 * AI-powered image recognition for product identification
 * 
 * Setup Instructions:
 * 1. Go to https://console.cloud.google.com
 * 2. Create a new project or select existing
 * 3. Enable Cloud Vision API
 * 4. Create Service Account:
 *    - Go to IAM & Admin > Service Accounts
 *    - Create Service Account with "Cloud Vision API User" role
 *    - Create and download JSON key
 * 5. Save the JSON file as: backend/config/google-cloud-key.json
 * 6. Set GOOGLE_APPLICATION_CREDENTIALS in .env
 */

class VisionService {
  constructor() {
    this.client = null;
    this.initialized = false;
  }

  /**
   * Initialize the Vision API client
   */
  async initialize() {
    if (this.initialized) return;

    try {
      // Check if credentials are configured
      if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
        console.warn('⚠️  Google Cloud Vision not configured. Set GOOGLE_APPLICATION_CREDENTIALS in .env');
        return;
      }

      // Initialize client with credentials
      this.client = new vision.ImageAnnotatorClient({
        keyFilename: process.env.GOOGLE_APPLICATION_CREDENTIALS,
      });

      this.initialized = true;
      console.log('✅ Google Cloud Vision initialized');
    } catch (error) {
      console.error('❌ Failed to initialize Google Cloud Vision:', error.message);
      console.log('Make sure:');
      console.log('1. You have created a GCP project');
      console.log('2. Cloud Vision API is enabled');
      console.log('3. Service account JSON key is in the correct path');
      console.log('4. GOOGLE_APPLICATION_CREDENTIALS points to the JSON file');
    }
  }

  /**
   * Detect labels/objects in an image
   * @param {string} imagePath - Path to image file or image buffer
   * @returns {Promise<Array>} Detected labels with confidence scores
   */
  async detectLabels(imagePath) {
    await this.initialize();

    if (!this.client) {
      throw new Error('Google Cloud Vision not configured');
    }

    try {
      const [result] = await this.client.labelDetection(imagePath);
      const labels = result.labelAnnotations;

      return labels.map(label => ({
        description: label.description,
        score: label.score,
        confidence: Math.round(label.score * 100),
      }));
    } catch (error) {
      console.error('Label detection error:', error.message);
      throw new Error('Failed to detect labels in image');
    }
  }

  /**
   * Detect products in an image using Web Detection
   * Best for identifying commercial products
   * @param {string} imagePath - Path to image file
   * @returns {Promise<Object>} Product detection results
   */
  async detectProduct(imagePath) {
    await this.initialize();

    if (!this.client) {
      throw new Error('Google Cloud Vision not configured');
    }

    try {
      const [result] = await this.client.webDetection(imagePath);
      const webDetection = result.webDetection;

      return {
        // Best guess labels
        bestGuess: webDetection.bestGuessLabels?.map(label => label.label) || [],
        
        // Full matching images (exact product)
        fullMatches: webDetection.fullMatchingImages?.map(img => img.url) || [],
        
        // Partial matching images (similar products)
        partialMatches: webDetection.partialMatchingImages?.map(img => img.url) || [],
        
        // Web entities (product names, brands)
        entities: webDetection.webEntities?.map(entity => ({
          description: entity.description,
          score: entity.score,
        })) || [],
        
        // Pages with matching images
        pagesWithMatches: webDetection.pagesWithMatchingImages?.map(page => ({
          url: page.url,
          title: page.pageTitle,
        })) || [],
      };
    } catch (error) {
      console.error('Product detection error:', error.message);
      throw new Error('Failed to detect product in image');
    }
  }

  /**
   * Extract text from image (OCR)
   * Useful for reading product names, prices, barcodes
   * @param {string} imagePath - Path to image file
   * @returns {Promise<string>} Extracted text
   */
  async extractText(imagePath) {
    await this.initialize();

    if (!this.client) {
      throw new Error('Google Cloud Vision not configured');
    }

    try {
      const [result] = await this.client.textDetection(imagePath);
      const detections = result.textAnnotations;

      if (detections && detections.length > 0) {
        return detections[0].description; // First result is full text
      }

      return '';
    } catch (error) {
      console.error('Text extraction error:', error.message);
      throw new Error('Failed to extract text from image');
    }
  }

  /**
   * Detect logos in an image
   * Useful for identifying brand logos
   * @param {string} imagePath - Path to image file
   * @returns {Promise<Array>} Detected logos
   */
  async detectLogos(imagePath) {
    await this.initialize();

    if (!this.client) {
      throw new Error('Google Cloud Vision not configured');
    }

    try {
      const [result] = await this.client.logoDetection(imagePath);
      const logos = result.logoAnnotations;

      return logos.map(logo => ({
        description: logo.description,
        score: logo.score,
        confidence: Math.round(logo.score * 100),
      }));
    } catch (error) {
      console.error('Logo detection error:', error.message);
      throw new Error('Failed to detect logos in image');
    }
  }

  /**
   * Comprehensive image analysis
   * Combines multiple detection types for best results
   * @param {string} imagePath - Path to image file
   * @returns {Promise<Object>} Complete analysis results
   */
  async analyzeImage(imagePath) {
    await this.initialize();

    if (!this.client) {
      throw new Error('Google Cloud Vision not configured');
    }

    try {
      const [labels, product, text, logos] = await Promise.allSettled([
        this.detectLabels(imagePath),
        this.detectProduct(imagePath),
        this.extractText(imagePath),
        this.detectLogos(imagePath),
      ]);

      return {
        labels: labels.status === 'fulfilled' ? labels.value : [],
        product: product.status === 'fulfilled' ? product.value : null,
        text: text.status === 'fulfilled' ? text.value : '',
        logos: logos.status === 'fulfilled' ? logos.value : [],
      };
    } catch (error) {
      console.error('Image analysis error:', error.message);
      throw new Error('Failed to analyze image');
    }
  }

  /**
   * Check if Vision API is configured
   * @returns {boolean} True if API is configured
   */
  isConfigured() {
    return !!process.env.GOOGLE_APPLICATION_CREDENTIALS;
  }

  /**
   * Get suggested product names from image analysis
   * @param {string} imagePath - Path to image file
   * @returns {Promise<Array<string>>} Suggested product names
   */
  async getProductSuggestions(imagePath) {
    const analysis = await this.analyzeImage(imagePath);
    
    const suggestions = new Set();

    // Add best guess labels
    if (analysis.product?.bestGuess) {
      analysis.product.bestGuess.forEach(guess => suggestions.add(guess));
    }

    // Add web entities
    if (analysis.product?.entities) {
      analysis.product.entities
        .filter(entity => entity.score > 0.5)
        .forEach(entity => suggestions.add(entity.description));
    }

    // Add logos
    if (analysis.logos) {
      analysis.logos.forEach(logo => suggestions.add(logo.description));
    }

    // Add top labels
    if (analysis.labels) {
      analysis.labels
        .filter(label => label.score > 0.7)
        .slice(0, 3)
        .forEach(label => suggestions.add(label.description));
    }

    return Array.from(suggestions).slice(0, 10);
  }
}

module.exports = new VisionService();
