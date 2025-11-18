const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const port = 3000;

const productsRouter = require('./routes/products');
const authRouter = require('./routes/auth');

// Middleware
app.use(bodyParser.json());

// Routes
app.use('/products', productsRouter);
app.use('/auth', authRouter);

app.get('/', (req, res) => {
  res.send('MarketLens Backend');
});

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});
