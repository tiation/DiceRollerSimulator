#!/usr/bin/env node

/**
 * Stripe Setup Script for DiceRollerSimulator
 * This script creates all the necessary products and prices in your Stripe account
 */

require('dotenv').config();
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

// Product configuration from your backend
const PRODUCTS = {
  // Premium Dice Skins
  premium_dice_pack_1: {
    name: 'Crystal Dice Pack',
    price: 199, // $1.99
    description: 'Beautiful crystal-themed dice with stunning animations',
    type: 'one_time',
    features: ['5 Crystal dice designs', 'Sparkle animations', 'Crystal sound effects']
  },
  premium_dice_pack_2: {
    name: 'Mystic Dice Pack',
    price: 299, // $2.99
    description: 'Magical dice with mystical effects and sounds',
    type: 'one_time',
    features: ['7 Mystic dice designs', 'Magic particle effects', 'Mystical audio']
  },
  premium_dice_pack_3: {
    name: 'Dragon Dice Pack',
    price: 399, // $3.99
    description: 'Epic dragon-themed dice with fire effects',
    type: 'one_time',
    features: ['10 Dragon dice designs', 'Fire and smoke effects', 'Dragon roar sounds']
  },
  
  // Statistics & Analytics
  advanced_stats: {
    name: 'Advanced Statistics',
    price: 199, // $1.99
    description: 'Detailed roll analytics and probability insights',
    type: 'one_time',
    features: ['Detailed roll history', 'Probability charts', 'Streak tracking', 'Export data']
  },
  
  // Custom Dice Creation
  custom_dice_creator: {
    name: 'Custom Dice Creator',
    price: 299, // $2.99
    description: 'Create and customize your own dice designs',
    type: 'one_time',
    features: ['Custom dice designer', 'Color customization', 'Pattern library', 'Save unlimited designs']
  },
  
  // Export/Import Features
  data_export: {
    name: 'Data Export & Import',
    price: 199, // $1.99
    description: 'Export roll history and import custom dice sets',
    type: 'one_time',
    features: ['Export roll history', 'Import dice sets', 'Backup data', 'Cloud sync']
  },
  
  // Subscription Services
  pro_subscription: {
    name: 'DiceRoller Pro',
    price: 299, // $2.99/month
    description: 'Unlimited dice, premium features, and ad-free experience',
    type: 'subscription',
    interval: 'month',
    features: ['Unlimited dice rolls', 'All premium dice packs', 'Ad-free experience', 'Priority support', 'Cloud backup']
  },
  
  // Remove Ads
  remove_ads: {
    name: 'Remove Ads',
    price: 199, // $1.99
    description: 'Enjoy an ad-free dice rolling experience',
    type: 'one_time',
    features: ['No advertisements', 'Clean interface', 'Faster app performance']
  }
};

async function createStripeProducts() {
  console.log('🎲 Setting up Stripe products for DiceRollerSimulator...\n');
  
  try {
    // Check if we're in test mode
    const isTestMode = process.env.STRIPE_SECRET_KEY.startsWith('sk_test_');
    console.log(`🔧 Mode: ${isTestMode ? 'TEST' : 'LIVE'}`);
    
    if (!isTestMode) {
      console.log('⚠️  WARNING: You are in LIVE mode. Products will be created in your live Stripe account.');
      console.log('⚠️  Make sure this is intentional. Press Ctrl+C to cancel if not.');
      await new Promise(resolve => setTimeout(resolve, 5000));
    }
    
    const results = [];
    
    for (const [productId, productData] of Object.entries(PRODUCTS)) {
      try {
        console.log(`📦 Creating product: ${productData.name}`);
        
        // Create or update product
        let product;
        try {
          product = await stripe.products.retrieve(productId);
          console.log(`   ✓ Product exists, updating...`);
          
          product = await stripe.products.update(productId, {
            name: productData.name,
            description: productData.description,
            metadata: {
              app: 'DiceRollerSimulator',
              type: productData.type,
              features: productData.features?.join(', ') || ''
            }
          });
        } catch (error) {
          if (error.code === 'resource_missing') {
            console.log(`   ✓ Creating new product...`);
            product = await stripe.products.create({
              id: productId,
              name: productData.name,
              description: productData.description,
              metadata: {
                app: 'DiceRollerSimulator',
                type: productData.type,
                features: productData.features?.join(', ') || ''
              }
            });
          } else {
            throw error;
          }
        }
        
        // Create price for the product
        let price;
        if (productData.type === 'subscription') {
          // Create recurring price
          console.log(`   💰 Creating subscription price: $${(productData.price / 100).toFixed(2)}/${productData.interval}`);
          price = await stripe.prices.create({
            unit_amount: productData.price,
            currency: 'usd',
            recurring: {
              interval: productData.interval
            },
            product: product.id,
            metadata: {
              app: 'DiceRollerSimulator',
              product_id: productId
            }
          });
        } else {
          // Create one-time price
          console.log(`   💰 Creating one-time price: $${(productData.price / 100).toFixed(2)}`);
          price = await stripe.prices.create({
            unit_amount: productData.price,
            currency: 'usd',
            product: product.id,
            metadata: {
              app: 'DiceRollerSimulator',
              product_id: productId
            }
          });
        }
        
        results.push({
          product_id: productId,
          product_name: productData.name,
          stripe_product_id: product.id,
          stripe_price_id: price.id,
          amount: productData.price,
          type: productData.type,
          status: 'created'
        });
        
        console.log(`   ✅ Success! Product ID: ${product.id}, Price ID: ${price.id}\n`);
        
      } catch (error) {
        console.error(`   ❌ Error creating ${productData.name}:`, error.message);
        results.push({
          product_id: productId,
          product_name: productData.name,
          status: 'failed',
          error: error.message
        });
      }
    }
    
    // Print summary
    console.log('\n📊 SETUP SUMMARY');
    console.log('================');
    
    const successful = results.filter(r => r.status === 'created');
    const failed = results.filter(r => r.status === 'failed');
    
    console.log(`✅ Successfully created: ${successful.length} products`);
    console.log(`❌ Failed: ${failed.length} products`);
    
    if (successful.length > 0) {
      console.log('\n🎉 Created Products:');
      successful.forEach(product => {
        console.log(`   • ${product.product_name} - $${(product.amount / 100).toFixed(2)}`);
        console.log(`     Product ID: ${product.stripe_product_id}`);
        console.log(`     Price ID: ${product.stripe_price_id}`);
        console.log('');
      });
    }
    
    if (failed.length > 0) {
      console.log('\n❌ Failed Products:');
      failed.forEach(product => {
        console.log(`   • ${product.product_name}: ${product.error}`);
      });
    }
    
    console.log('\n🔗 Next Steps:');
    console.log('1. Visit your Stripe Dashboard to review the products');
    console.log('2. Set up webhooks for payment notifications');
    console.log('3. Configure your payout settings');
    console.log('4. Test your integration in test mode');
    console.log('5. Complete account verification for live payments');
    
  } catch (error) {
    console.error('❌ Setup failed:', error.message);
    process.exit(1);
  }
}

// Run the setup
if (require.main === module) {
  createStripeProducts()
    .then(() => {
      console.log('\n🎲 Stripe setup completed!');
      process.exit(0);
    })
    .catch(error => {
      console.error('❌ Setup failed:', error);
      process.exit(1);
    });
}

module.exports = { createStripeProducts, PRODUCTS };
