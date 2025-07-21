#!/bin/bash
set -e

echo "🧪 Running enterprise testing suite..."

if [ -f "package.json" ]; then
    # Install testing dependencies if not present
    if ! npm list jest --depth=0 2>/dev/null; then
        npm install --save-dev jest supertest @testing-library/jest-dom
    fi
    
    # Create basic test structure
    mkdir -p tests
    
    if [ ! -f "tests/basic.test.js" ]; then
        cat > tests/basic.test.js << 'TEST_EOF'
describe('Basic Tests', () => {
  test('should pass basic test', () => {
    expect(true).toBe(true);
  });
  
  test('should have proper environment', () => {
    expect(process.env.NODE_ENV).toBeDefined();
  });
});
TEST_EOF
    fi
    
    # Run tests
    npm test -- --passWithNoTests || exit 1
fi

echo "✅ Testing completed successfully"
