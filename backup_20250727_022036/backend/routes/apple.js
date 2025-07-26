const express = require('express');
const router = express.Router();

// Apple In-App Purchase Configuration
const appleSignIn = require('apple-signin-auth');

// Verify Apple Receipt
router.post('/verify-receipt', async (req, res) => {
  try {
    const { receiptData, transactionId } = req.body;
    
    // Verify receipt with Apple's servers
    const verificationResult = await verifyAppleReceipt(receiptData);
    
    if (verificationResult.status === 0) {
      // Receipt is valid
      const purchase = verificationResult.receipt.in_app.find(
        item => item.transaction_id === transactionId
      );
      
      if (purchase) {
        res.json({
          success: true,
          purchase: {
            product_id: purchase.product_id,
            transaction_id: purchase.transaction_id,
            purchase_date: purchase.purchase_date,
            expires_date: purchase.expires_date
          }
        });
      } else {
        res.status(400).json({
          success: false,
          error: 'Transaction not found in receipt'
        });
      }
    } else {
      res.status(400).json({
        success: false,
        error: 'Invalid receipt',
        status: verificationResult.status
      });
    }
  } catch (error) {
    console.error('Apple receipt verification error:', error);
    res.status(500).json({
      success: false,
      error: 'Receipt verification failed'
    });
  }
});

// Apple Sign In
router.post('/signin', async (req, res) => {
  try {
    const { identityToken, authorizationCode } = req.body;
    
    // Verify Apple Sign In token
    const appleUser = await appleSignIn.verifyIdToken(identityToken);
    
    res.json({
      success: true,
      user: {
        id: appleUser.sub,
        email: appleUser.email,
        email_verified: appleUser.email_verified
      }
    });
  } catch (error) {
    console.error('Apple Sign In error:', error);
    res.status(401).json({
      success: false,
      error: 'Apple Sign In verification failed'
    });
  }
});

// Helper function to verify Apple receipt
async function verifyAppleReceipt(receiptData) {
  const isProduction = process.env.NODE_ENV === 'production';
  const verifyUrl = isProduction
    ? 'https://buy.itunes.apple.com/verifyReceipt'
    : 'https://sandbox.itunes.apple.com/verifyReceipt';
  
  const requestBody = {
    'receipt-data': receiptData,
    'password': process.env.APPLE_SHARED_SECRET
  };
  
  const response = await fetch(verifyUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(requestBody)
  });
  
  const result = await response.json();
  
  // If status is 21007, try sandbox environment
  if (result.status === 21007 && isProduction) {
    const sandboxResponse = await fetch('https://sandbox.itunes.apple.com/verifyReceipt', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(requestBody)
    });
    
    return await sandboxResponse.json();
  }
  
  return result;
}

module.exports = router;
