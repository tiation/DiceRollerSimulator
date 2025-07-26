# 🚀 Quick Deploy Guide - DiceRollerSimulator Backend

## 🎯 Deploy to VPS 145.223.22.7 in 3 Steps

### Step 1: Deploy Backend
```bash
cd /Users/tiaastor/tiation-github/DiceRollerSimulator/backend
./deploy.sh
```

### Step 2: Configure Environment (After Deploy)
```bash
# SSH into VPS and edit the .env file
ssh root@145.223.22.7
cd /opt/dicerollersimulator-backend/current
nano .env
```

**Important:** Replace these values in the .env file:
- `STRIPE_SECRET_KEY=sk_live_your_actual_stripe_key`
- `JWT_SECRET=your_64_character_random_secret_key`
- `DATABASE_URL=your_actual_database_url`

### Step 3: Setup SSL/HTTPS (Optional but Recommended)
```bash
# Back on your local machine
./setup-ssl.sh
```

## 🧪 Test Your Deployment

### Basic Health Check
```bash
curl http://145.223.22.7/health
```

### API Root
```bash
curl http://145.223.22.7/
```

### Test with HTTPS (if SSL setup)
```bash
curl https://api.dicerollersimulator.com/health
```

## 🔧 Quick Management Commands

### Check Status
```bash
ssh root@145.223.22.7 'pm2 status'
```

### View Logs
```bash
ssh root@145.223.22.7 'pm2 logs dicerollersimulator-backend'
```

### Restart Service
```bash
ssh root@145.223.22.7 'pm2 restart dicerollersimulator-backend'
```

## 📊 Your API Endpoints

After deployment, these endpoints will be available:

### Core
- `GET /` - API info
- `GET /health` - Health check

### Stripe
- `POST /api/v1/stripe/create-payment-intent`
- `POST /api/v1/stripe/webhook`

### Apple
- `POST /api/v1/apple/verify-receipt`
- `POST /api/v1/apple/webhook`

### Users
- `POST /api/v1/users/register`
- `POST /api/v1/users/login`
- `GET /api/v1/users/profile`

### Analytics
- `POST /api/v1/analytics/track`
- `GET /api/v1/analytics/dashboard`

## 🎯 What the Deploy Script Does

1. ✅ Tests VPS connectivity
2. 📦 Packages your backend code
3. 📤 Uploads to VPS
4. 🔧 Installs Node.js, PM2, Nginx
5. 🚀 Starts your API service
6. 🌐 Configures reverse proxy
7. 🔒 Sets up firewall
8. 🧪 Tests endpoints

## 🚨 If Something Goes Wrong

### App Won't Start
```bash
ssh root@145.223.22.7 'pm2 logs dicerollersimulator-backend'
```

### Check All Services
```bash
ssh root@145.223.22.7 'systemctl status nginx'
ssh root@145.223.22.7 'pm2 status'
```

### Restart Everything
```bash
ssh root@145.223.22.7 'systemctl restart nginx'
ssh root@145.223.22.7 'pm2 restart dicerollersimulator-backend'
```

## 🎉 Success Checklist

After deployment, you should have:

- ✅ API responding on http://145.223.22.7
- ✅ Health endpoint returning "healthy"
- ✅ PM2 showing "online" status
- ✅ Nginx proxying requests
- ✅ Firewall properly configured
- ✅ All endpoints accessible

## 📞 Need Help?

1. Check the logs: `pm2 logs dicerollersimulator-backend`
2. Review the full documentation: `DEPLOYMENT.md`
3. Test connectivity: `curl http://145.223.22.7/health`

---

**Ready to deploy? Run `./deploy.sh` now!** 🚀
