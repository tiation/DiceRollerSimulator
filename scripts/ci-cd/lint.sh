#!/bin/bash
set -e

echo "🔍 Running enterprise linting checks..."

# Install linting tools if not present
if [ -f "package.json" ]; then
    if ! npm list eslint --depth=0 2>/dev/null; then
        npm install --save-dev eslint prettier eslint-config-prettier eslint-plugin-security
    fi
    
    # Create ESLint config if not exists
    if [ ! -f ".eslintrc.js" ]; then
        cat > .eslintrc.js << 'ESLINT_EOF'
module.exports = {
  env: {
    browser: true,
    es2021: true,
    node: true,
  },
  extends: [
    'eslint:recommended',
    'plugin:security/recommended',
    'prettier'
  ],
  plugins: ['security'],
  rules: {
    'no-console': 'warn',
    'no-unused-vars': 'error',
    'security/detect-object-injection': 'error',
  },
};
ESLINT_EOF
    fi
    
    # Run linting
    npx eslint . --ext .js,.jsx,.ts,.tsx || exit 1
    npx prettier --check . || exit 1
fi

echo "✅ Linting completed successfully"
