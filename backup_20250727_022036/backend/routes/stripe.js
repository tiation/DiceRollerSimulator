const express = require('express');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const router = express.Router();

// DiceRollerSimulator Product Configuration
const PRODUCTS = {
  // Premium Dice Skins
  premium_dice_pack_1: {
    name: 'Crystal Dice Pack',
    price: 199, // $1.99
    description: 'Beautiful crystal-themed dice with stunning animations',
    type: 'one_time'
  },
  premium_dice_pack_2: {
    name: 'Mystic Dice Pack',
    price: 299, // $2.99
    description: 'Magical dice with mystical effects and sounds',
    type: 'one_time'
  },
  premium_dice_pack_3: {
    name: 'Dragon Dice Pack',
    price: 399, // $3.99
    description: 'Epic dragon-themed dice with fire effects',
    type: 'one_time'
  },
  
  // Statistics & Analytics
  advanced_stats: {
    name: 'Advanced Statistics',
    price: 199, // $1.99
    description: 'Detailed roll analytics and probability insights',
    type: 'one_time'
  },
  
  // Custom Dice Creation
  custom_dice_creator: {
    name: 'Custom Dice Creator',
    price: 299, // $2.99
    description: 'Create and customize your own dice designs',
    type: 'one_time'
  },
  
  // Export/Import Features
  data_export: {
    name: 'Data Export & Import',
    price: 199, // $1.99
    description: 'Export roll history and import custom dice sets',
    type: 'one_time'
  },
  
  // Subscription Services
  pro_subscription: {
    name: 'DiceRoller Pro',
    price: 299, // $2.99/month
    description: 'Unlimited dice, premium features, and ad-free experience',
    type: 'subscription',
    interval: 'month'
  },
  
  // Remove Ads
  remove_ads: {
    name: 'Remove Ads',
    price: 199, // $1.99
    description: 'Enjoy an ad-free dice rolling experience',
    type: 'one_time'
  }
};

// Create Stripe Customer
router.post('/create-customer', async (req, res) => {
  try {
    const { email, name, deviceId } = req.body;
    
    const customer = await stripe.customers.create({
      email: email,
      name: name,
      metadata: {
        deviceId: deviceId,
        app: 'DiceRollerSimulator',
        platform: 'iOS'
      }
    });
    
    res.json({
      success: true,
      customer: {
        id: customer.id,
        email: customer.email
      }
    });
  } catch (error) {
    console.error('Create customer error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create customer'
    });
  }
});

// Create Payment Intent for One-time Purchases
router.post('/create-payment-intent', async (req, res) => {
  try {
    const { productId, customerId } = req.body;
    
    const product = PRODUCTS[productId];
    if (!product) {
      return res.status(400).json({
        success: false,
        error: 'Invalid product ID'
      });
    }
    
    const paymentIntent = await stripe.paymentIntents.create({
      amount: product.price,
      currency: 'usd',
      customer: customerId,
      metadata: {
        productId: productId,
        productName: product.name,
        app: 'DiceRollerSimulator'
      },
      automatic_payment_methods: {
        enabled: true
      }
    });
    
    res.json({
      success: true,
      clientSecret: paymentIntent.client_secret,
      product: product
    });
  } catch (error) {
    console.error('Create payment intent error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create payment intent'
    });
  }
});

// Create Subscription
router.post('/create-subscription', async (req, res) => {
  try {
    const { customerId, productId } = req.body;
    
    const product = PRODUCTS[productId];
    if (!product || product.type !== 'subscription') {
      return res.status(400).json({
        success: false,
        error: 'Invalid subscription product'
      });
    }
    
    // Create price if it doesn't exist
    let price;
    try {
      const prices = await stripe.prices.list({
        product: productId,
        active: true
      });
      
      if (prices.data.length === 0) {
        // Create the product first
        const stripeProduct = await stripe.products.create({
          id: productId,
          name: product.name,
          description: product.description,
          metadata: {
            app: 'DiceRollerSimulator'
          }
        });
        
        // Create the price
        price = await stripe.prices.create({
          unit_amount: product.price,
          currency: 'usd',
          recurring: {
            interval: product.interval
          },
          product: stripeProduct.id
        });
      } else {
        price = prices.data[0];
      }
    } catch (productError) {
      console.error('Product creation error:', productError);
      return res.status(500).json({
        success: false,
        error: 'Failed to create product'
      });
    }
    
    const subscription = await stripe.subscriptions.create({
      customer: customerId,
      items: [{ price: price.id }],
      trial_period_days: 7, // 7-day free trial
      metadata: {
        app: 'DiceRollerSimulator',
        productId: productId
      }
    });
    
    res.json({
      success: true,
      subscription: {
        id: subscription.id,
        status: subscription.status,
        current_period_end: subscription.current_period_end
      }
    });
  } catch (error) {
    console.error('Create subscription error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create subscription'
    });
  }
});

// Get Customer's Subscriptions
router.get('/customer/:customerId/subscriptions', async (req, res) => {
  try {
    const { customerId } = req.params;
    
    const subscriptions = await stripe.subscriptions.list({
      customer: customerId,
      status: 'active'
    });
    
    res.json({
      success: true,
      subscriptions: subscriptions.data.map(sub => ({
        id: sub.id,
        status: sub.status,
        current_period_end: sub.current_period_end,
        cancel_at_period_end: sub.cancel_at_period_end
      }))
    });
  } catch (error) {
    console.error('Get subscriptions error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve subscriptions'
    });
  }
});

// Cancel Subscription
router.post('/cancel-subscription', async (req, res) => {
  try {
    const { subscriptionId } = req.body;
    
    const subscription = await stripe.subscriptions.update(subscriptionId, {
      cancel_at_period_end: true
    });
    
    res.json({
      success: true,
      subscription: {
        id: subscription.id,
        status: subscription.status,
        cancel_at_period_end: subscription.cancel_at_period_end
      }
    });
  } catch (error) {
    console.error('Cancel subscription error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to cancel subscription'
    });
  }
});

// Get Available Products
router.get('/products', (req, res) => {
  const productList = Object.keys(PRODUCTS).map(key => ({
    id: key,
    ...PRODUCTS[key]
  }));
  
  res.json({
    success: true,
    products: productList
  });
});

// Stripe Webhook Handler
router.post('/webhook', express.raw({type: 'application/json'}), async (req, res) => {
  const sig = req.headers['stripe-signature'];
  
  let event;
  try {
    event = stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET);
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }
  
  // Handle the event
  switch (event.type) {
    case 'payment_intent.succeeded':
      const paymentIntent = event.data.object;
      console.log('Payment succeeded:', paymentIntent.id);
      // Update user's purchased items
      await handleSuccessfulPayment(paymentIntent);
      break;
      
    case 'customer.subscription.created':
      const subscription = event.data.object;
      console.log('Subscription created:', subscription.id);
      await handleSubscriptionCreated(subscription);
      break;
      
    case 'customer.subscription.updated':
      const updatedSubscription = event.data.object;
      console.log('Subscription updated:', updatedSubscription.id);
      await handleSubscriptionUpdated(updatedSubscription);
      break;
      
    case 'customer.subscription.deleted':
      const deletedSubscription = event.data.object;
      console.log('Subscription deleted:', deletedSubscription.id);
      await handleSubscriptionDeleted(deletedSubscription);
      break;
      
    default:
      console.log(`Unhandled event type: ${event.type}`);
  }
  
  res.json({received: true});
});

// Helper Functions
async function handleSuccessfulPayment(paymentIntent) {
  // Update database with successful purchase
  console.log('Processing successful payment:', paymentIntent.metadata);
  // TODO: Update user's purchases in database
}

async function handleSubscriptionCreated(subscription) {
  // Update database with new subscription
  console.log('Processing new subscription:', subscription.metadata);
  // TODO: Update user's subscription status in database
}

async function handleSubscriptionUpdated(subscription) {
  // Update database with subscription changes
  console.log('Processing subscription update:', subscription.metadata);
  // TODO: Update user's subscription status in database
}

async function handleSubscriptionDeleted(subscription) {
  // Update database with subscription cancellation
  console.log('Processing subscription deletion:', subscription.metadata);
  // TODO: Update user's subscription status in database
}

module.exports = router;
