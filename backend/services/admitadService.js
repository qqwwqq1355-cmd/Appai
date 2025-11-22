const axios = require('axios');

/**
 * Admitad API Service
 * 
 * Integration with Admitad affiliate network to fetch products from:
 * - Shein, Temu, AliExpress, Amazon, and other stores
 * 
 * API Documentation: https://developers.admitad.com/en/
 * Register: https://publishers.admitad.com
 */

class AdmitadService {
  constructor() {
    this.clientId = process.env.ADMITAD_CLIENT_ID;
    this.clientSecret = process.env.ADMITAD_CLIENT_SECRET;
    this.redirectUri = process.env.ADMITAD_REDIRECT_URI;
    
    this.baseUrl = 'https://api.admitad.com';
    this.accessToken = null;
    this.tokenExpiry = null;
  }

  /**
   * Get OAuth2 access token
   * Uses client credentials flow for server-to-server authentication
   */
  async getAccessToken() {
    // Return cached token if still valid
    if (this.accessToken && this.tokenExpiry && Date.now() < this.tokenExpiry) {
      return this.accessToken;
    }

    try {
      const auth = Buffer.from(`${this.clientId}:${this.clientSecret}`).toString('base64');
      
      const response = await axios.post(
        `${this.baseUrl}/token/`,
        'grant_type=client_credentials&client_id=' + this.clientId + '&scope=public_data',
        {
          headers: {
            'Authorization': `Basic ${auth}`,
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        }
      );

      this.accessToken = response.data.access_token;
      // Set expiry to 5 minutes before actual expiry for safety
      this.tokenExpiry = Date.now() + (response.data.expires_in - 300) * 1000;
      
      return this.accessToken;
    } catch (error) {
      console.error('Admitad auth error:', error.response?.data || error.message);
      throw new Error('Failed to authenticate with Admitad API');
    }
  }

  /**
   * Get list of available advertisers/stores
   * @returns {Promise<Array>} List of stores with their details
   */
  async getAdvertisers() {
    try {
      const token = await this.getAccessToken();
      
      const response = await axios.get(`${this.baseUrl}/advcampaigns/`, {
        headers: {
          'Authorization': `Bearer ${token}`,
        },
        params: {
          limit: 100,
          status: 'active', // Only active campaigns
        },
      });

      return response.data.results.map(advertiser => ({
        id: advertiser.id,
        name: advertiser.name,
        description: advertiser.description,
        region: advertiser.region,
        categories: advertiser.categories,
        gotolink: advertiser.gotolink,
        active: advertiser.status === 'active',
      }));
    } catch (error) {
      console.error('Failed to fetch advertisers:', error.message);
      return [];
    }
  }

  /**
   * Search products across all connected stores
   * @param {Object} params - Search parameters
   * @param {string} params.query - Search query
   * @param {number} params.limit - Number of results (default: 20)
   * @param {number} params.offset - Pagination offset
   * @returns {Promise<Array>} Product list
   */
  async searchProducts({ query, limit = 20, offset = 0 }) {
    try {
      const token = await this.getAccessToken();
      
      const response = await axios.get(`${this.baseUrl}/products/`, {
        headers: {
          'Authorization': `Bearer ${token}`,
        },
        params: {
          q: query,
          limit,
          offset,
        },
      });

      return response.data.results.map(product => this.formatProduct(product));
    } catch (error) {
      console.error('Product search error:', error.message);
      return [];
    }
  }

  /**
   * Get products by category
   * @param {Object} params - Category parameters
   * @param {number} params.categoryId - Category ID
   * @param {number} params.limit - Number of results
   * @returns {Promise<Array>} Product list
   */
  async getProductsByCategory({ categoryId, limit = 20 }) {
    try {
      const token = await this.getAccessToken();
      
      const response = await axios.get(`${this.baseUrl}/products/`, {
        headers: {
          'Authorization': `Bearer ${token}`,
        },
        params: {
          category: categoryId,
          limit,
        },
      });

      return response.data.results.map(product => this.formatProduct(product));
    } catch (error) {
      console.error('Category products error:', error.message);
      return [];
    }
  }

  /**
   * Generate affiliate link for a product
   * @param {string} url - Original product URL
   * @param {number} campaignId - Advertiser campaign ID
   * @returns {Promise<string>} Affiliate link
   */
  async generateAffiliateLink(url, campaignId) {
    try {
      const token = await this.getAccessToken();
      
      const response = await axios.get(`${this.baseUrl}/deeplink/`, {
        headers: {
          'Authorization': `Bearer ${token}`,
        },
        params: {
          url: url,
          campaign: campaignId,
        },
      });

      return response.data.deeplink;
    } catch (error) {
      console.error('Affiliate link generation error:', error.message);
      return url; // Return original URL if affiliate link fails
    }
  }

  /**
   * Format product data to match our schema
   * @param {Object} admitadProduct - Raw product from Admitad API
   * @returns {Object} Formatted product
   */
  formatProduct(admitadProduct) {
    return {
      externalId: admitadProduct.id,
      name: admitadProduct.name,
      description: admitadProduct.description,
      imageUrl: admitadProduct.picture,
      price: parseFloat(admitadProduct.price),
      currency: admitadProduct.currency || 'USD',
      originalPrice: admitadProduct.oldprice ? parseFloat(admitadProduct.oldprice) : null,
      discount: this.calculateDiscount(admitadProduct.price, admitadProduct.oldprice),
      url: admitadProduct.url,
      affiliateUrl: null, // Will be generated when needed
      store: admitadProduct.merchant,
      category: admitadProduct.category?.name,
      inStock: admitadProduct.available === 'yes',
      rating: null, // Admitad doesn't provide ratings
      vendor: 'admitad',
    };
  }

  /**
   * Calculate discount percentage
   */
  calculateDiscount(currentPrice, oldPrice) {
    if (!oldPrice || oldPrice <= currentPrice) return null;
    return Math.round(((oldPrice - currentPrice) / oldPrice) * 100);
  }

  /**
   * Search products by barcode
   * Note: Admitad doesn't have direct barcode search, so we search by product name
   * @param {string} barcode - Product barcode
   * @returns {Promise<Array>} Products matching the barcode
   */
  async searchByBarcode(barcode) {
    // For now, return empty array as Admitad doesn't support barcode search
    // You would need to maintain a barcode-to-product mapping in your database
    console.log(`Barcode search not directly supported by Admitad: ${barcode}`);
    return [];
  }

  /**
   * Get product recommendations
   * @param {string} productName - Product name to get recommendations for
   * @param {number} limit - Number of recommendations
   * @returns {Promise<Array>} Recommended products
   */
  async getRecommendations(productName, limit = 5) {
    return this.searchProducts({ query: productName, limit });
  }

  /**
   * Check if API credentials are configured
   * @returns {boolean} True if credentials are set
   */
  isConfigured() {
    return !!(this.clientId && this.clientSecret);
  }
}

module.exports = new AdmitadService();
