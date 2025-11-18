const express = require('express');
const router = express.Router();

// In a real application, this would involve a proper authentication system.
// For now, we'll just simulate a successful login.

// POST /auth/login
router.post('/login', (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required' });
  }

  // Simulate a successful login
  res.json({
    token: 'sample-jwt-token',
    user: {
      id: 1,
      name: 'Test User',
      email: email,
    },
  });
});

module.exports = router;
