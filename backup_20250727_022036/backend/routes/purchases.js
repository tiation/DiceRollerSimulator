const express = require('express');
const router = express.Router();

// Purchase endpoint
router.post('/buy-item', (req, res) => {
    const { itemId } = req.body;
    // Dummy implementation, replace with real logic
    res.json({
        success: true,
        message: `Item ${itemId} purchased successfully!`
    });
});

module.exports = router;
