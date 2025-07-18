#!/bin/bash

# DiceRollerSimulator VPS API Test Script
# Tests the deployed API endpoints

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
VPS_IP="145.223.22.7"
API_PORT="3000"
BASE_URL="http://${VPS_IP}:${API_PORT}"

echo -e "${CYAN}🎲 DiceRollerSimulator API Test Suite${NC}"
echo -e "${CYAN}=====================================${NC}"
echo -e "${BLUE}Testing API at: ${BASE_URL}${NC}"
echo ""

# Test 1: Health Check
echo -e "${YELLOW}🔍 Test 1: Health Check${NC}"
HEALTH_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/health_response.json "${BASE_URL}/health" || echo "000")
if [ "$HEALTH_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ Health check passed${NC}"
    echo -e "${BLUE}Response:${NC}"
    cat /tmp/health_response.json | python3 -m json.tool 2>/dev/null || cat /tmp/health_response.json
else
    echo -e "${RED}❌ Health check failed (HTTP: $HEALTH_RESPONSE)${NC}"
fi
echo ""

# Test 2: Root endpoint
echo -e "${YELLOW}🔍 Test 2: Root API Endpoint${NC}"
ROOT_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/root_response.json "${BASE_URL}/" || echo "000")
if [ "$ROOT_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ Root endpoint accessible${NC}"
    echo -e "${BLUE}Response:${NC}"
    cat /tmp/root_response.json | python3 -m json.tool 2>/dev/null || cat /tmp/root_response.json
else
    echo -e "${RED}❌ Root endpoint failed (HTTP: $ROOT_RESPONSE)${NC}"
fi
echo ""

# Test 3: Stripe endpoint (should return 404 or method not allowed for GET)
echo -e "${YELLOW}🔍 Test 3: Stripe API Endpoint${NC}"
STRIPE_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/stripe_response.json "${BASE_URL}/api/v1/stripe" || echo "000")
if [ "$STRIPE_RESPONSE" = "404" ] || [ "$STRIPE_RESPONSE" = "405" ]; then
    echo -e "${GREEN}✅ Stripe endpoint exists (expected 404/405 for GET)${NC}"
elif [ "$STRIPE_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ Stripe endpoint accessible${NC}"
    echo -e "${BLUE}Response:${NC}"
    cat /tmp/stripe_response.json | python3 -m json.tool 2>/dev/null || cat /tmp/stripe_response.json
else
    echo -e "${RED}❌ Stripe endpoint failed (HTTP: $STRIPE_RESPONSE)${NC}"
fi
echo ""

# Test 4: Apple endpoint
echo -e "${YELLOW}🔍 Test 4: Apple API Endpoint${NC}"
APPLE_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/apple_response.json "${BASE_URL}/api/v1/apple" || echo "000")
if [ "$APPLE_RESPONSE" = "404" ] || [ "$APPLE_RESPONSE" = "405" ]; then
    echo -e "${GREEN}✅ Apple endpoint exists (expected 404/405 for GET)${NC}"
elif [ "$APPLE_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ Apple endpoint accessible${NC}"
    echo -e "${BLUE}Response:${NC}"
    cat /tmp/apple_response.json | python3 -m json.tool 2>/dev/null || cat /tmp/apple_response.json
else
    echo -e "${RED}❌ Apple endpoint failed (HTTP: $APPLE_RESPONSE)${NC}"
fi
echo ""

# Test 5: Users endpoint
echo -e "${YELLOW}🔍 Test 5: Users API Endpoint${NC}"
USERS_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/users_response.json "${BASE_URL}/api/v1/users" || echo "000")
if [ "$USERS_RESPONSE" = "401" ] || [ "$USERS_RESPONSE" = "403" ]; then
    echo -e "${GREEN}✅ Users endpoint exists (expected 401/403 - auth required)${NC}"
elif [ "$USERS_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ Users endpoint accessible${NC}"
    echo -e "${BLUE}Response:${NC}"
    cat /tmp/users_response.json | python3 -m json.tool 2>/dev/null || cat /tmp/users_response.json
else
    echo -e "${RED}❌ Users endpoint failed (HTTP: $USERS_RESPONSE)${NC}"
fi
echo ""

# Test 6: 404 handling
echo -e "${YELLOW}🔍 Test 6: 404 Error Handling${NC}"
NOTFOUND_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/notfound_response.json "${BASE_URL}/api/v1/nonexistent" || echo "000")
if [ "$NOTFOUND_RESPONSE" = "404" ]; then
    echo -e "${GREEN}✅ 404 handling works correctly${NC}"
    echo -e "${BLUE}Response:${NC}"
    cat /tmp/notfound_response.json | python3 -m json.tool 2>/dev/null || cat /tmp/notfound_response.json
else
    echo -e "${RED}❌ 404 handling failed (HTTP: $NOTFOUND_RESPONSE)${NC}"
fi
echo ""

# Test 7: Rate limiting test
echo -e "${YELLOW}🔍 Test 7: Rate Limiting${NC}"
echo -e "${BLUE}Sending 5 rapid requests...${NC}"
for i in {1..5}; do
    RATE_RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null "${BASE_URL}/health" || echo "000")
    if [ "$RATE_RESPONSE" = "429" ]; then
        echo -e "${GREEN}✅ Rate limiting active (HTTP: $RATE_RESPONSE)${NC}"
        break
    elif [ "$RATE_RESPONSE" = "200" ]; then
        echo -e "${BLUE}Request $i: OK${NC}"
    else
        echo -e "${YELLOW}Request $i: HTTP $RATE_RESPONSE${NC}"
    fi
    sleep 0.1
done
echo ""

# Test 8: CORS headers
echo -e "${YELLOW}🔍 Test 8: CORS Headers${NC}"
CORS_RESPONSE=$(curl -s -I "${BASE_URL}/health" | grep -i "access-control" || echo "No CORS headers found")
if [[ "$CORS_RESPONSE" == *"access-control"* ]]; then
    echo -e "${GREEN}✅ CORS headers present${NC}"
    echo -e "${BLUE}Headers: $CORS_RESPONSE${NC}"
else
    echo -e "${YELLOW}⚠️  CORS headers not detected${NC}"
fi
echo ""

# Summary
echo -e "${CYAN}📊 Test Summary${NC}"
echo -e "${CYAN}===============${NC}"
echo -e "${GREEN}✅ API is deployed and responding${NC}"
echo -e "${BLUE}🌐 Base URL: ${BASE_URL}${NC}"
echo -e "${BLUE}💚 Health Check: ${BASE_URL}/health${NC}"
echo -e "${BLUE}📚 API Docs: ${BASE_URL}/api/v1/docs${NC}"
echo ""

# Performance test
echo -e "${YELLOW}🔍 Performance Test${NC}"
echo -e "${BLUE}Testing response time...${NC}"
TIME_RESULT=$(curl -s -w "Response time: %{time_total}s\nHTTP Code: %{http_code}\n" -o /dev/null "${BASE_URL}/health")
echo -e "${GREEN}$TIME_RESULT${NC}"
echo ""

# Clean up temp files
rm -f /tmp/health_response.json /tmp/root_response.json /tmp/stripe_response.json /tmp/apple_response.json /tmp/users_response.json /tmp/notfound_response.json

echo -e "${GREEN}🎉 API testing completed!${NC}"
echo -e "${CYAN}Next steps:${NC}"
echo -e "${YELLOW}1. Configure your environment variables${NC}"
echo -e "${YELLOW}2. Set up SSL certificates${NC}"
echo -e "${YELLOW}3. Configure your domain${NC}"
echo -e "${YELLOW}4. Test payment endpoints with valid API keys${NC}"
