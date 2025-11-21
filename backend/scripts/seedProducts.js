require('dotenv').config();
const mongoose = require('mongoose');
const Product = require('../models/Product');

const sampleProducts = [
  {
    name: 'Sony WH-1000XM5 Wireless Headphones',
    barcode: '4548736141574',
    imageUrl: 'https://example.com/sony-headphones.jpg',
    category: 'Electronics',
    brand: 'Sony',
    description: 'Industry-leading noise canceling wireless headphones with crystal-clear hands-free calling and Alexa voice control.',
    prices: [
      {
        store: 'Amazon',
        price: 399.99,
        currency: 'USD',
        url: 'https://amazon.com/sony-wh1000xm5',
        lastUpdated: new Date()
      },
      {
        store: 'Best Buy',
        price: 399.99,
        currency: 'USD',
        url: 'https://bestbuy.com/sony-wh1000xm5',
        lastUpdated: new Date()
      },
      {
        store: 'Target',
        price: 429.99,
        currency: 'USD',
        url: 'https://target.com/sony-wh1000xm5',
        lastUpdated: new Date()
      }
    ],
    reviews: {
      average: 4.7,
      count: 15234
    },
    coupons: [
      {
        code: 'SAVE50',
        discount: '$50 off',
        description: 'Save $50 on Sony headphones',
        expiryDate: new Date('2025-12-31')
      }
    ]
  },
  {
    name: 'Apple AirPods Pro (2nd Generation)',
    barcode: '194253397786',
    imageUrl: 'https://example.com/airpods-pro.jpg',
    category: 'Electronics',
    brand: 'Apple',
    description: 'Up to 2x more Active Noise Cancellation than the previous AirPods Pro.',
    prices: [
      {
        store: 'Apple Store',
        price: 249.00,
        currency: 'USD',
        url: 'https://apple.com/airpods-pro',
        lastUpdated: new Date()
      },
      {
        store: 'Amazon',
        price: 234.99,
        currency: 'USD',
        url: 'https://amazon.com/airpods-pro',
        lastUpdated: new Date()
      },
      {
        store: 'Walmart',
        price: 239.00,
        currency: 'USD',
        url: 'https://walmart.com/airpods-pro',
        lastUpdated: new Date()
      }
    ],
    reviews: {
      average: 4.8,
      count: 28456
    },
    coupons: []
  },
  {
    name: 'Samsung Galaxy Watch 6',
    barcode: '8806095005904',
    imageUrl: 'https://example.com/galaxy-watch.jpg',
    category: 'Wearables',
    brand: 'Samsung',
    description: 'Track your fitness goals, monitor your health, and stay connected.',
    prices: [
      {
        store: 'Samsung',
        price: 299.99,
        currency: 'USD',
        url: 'https://samsung.com/galaxy-watch-6',
        lastUpdated: new Date()
      },
      {
        store: 'Amazon',
        price: 289.99,
        currency: 'USD',
        url: 'https://amazon.com/galaxy-watch-6',
        lastUpdated: new Date()
      }
    ],
    reviews: {
      average: 4.5,
      count: 8932
    },
    coupons: []
  }
];

async function seedProducts() {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/marketlens', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ Connected to MongoDB');

    console.log('Clearing existing products...');
    await Product.deleteMany({});
    console.log('✅ Cleared existing products');

    console.log('Inserting sample products...');
    const result = await Product.insertMany(sampleProducts);
    console.log(`✅ Inserted ${result.length} products`);

    console.log('\n📊 Product Database Summary:');
    result.forEach((product, index) => {
      console.log(`${index + 1}. ${product.name} - $${Math.min(...product.prices.map(p => p.price))}`);
    });

    console.log('\n✅ Database seeding completed!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

seedProducts();
