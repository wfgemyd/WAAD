const express = require('express');
const router = express.Router();
const authorize = require('./authorize.js');
const onboarding = require('./onboarding.js');

// Protected routes
router.use('/api/onboarding', authorize, onboarding);


// router.use('/api/tickets', authorize, tickets);

module.exports = router;
