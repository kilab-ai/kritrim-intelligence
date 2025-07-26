#!/bin/bash

set -e

# Create necessary directories
mkdir -p docs
mkdir -p .github/workflows

# Create markdown files if not exist
touch_if_not_exist() {
  local file=$1
  if [ ! -f "$file" ]; then
    echo "Creating $file"
    cat <<EOF > "$file"
# $(basename "$file" .md | tr '[:lower:]' '[:upper:]')

Content for $(basename "$file")
EOF
  fi
}

touch_if_not_exist docs/index.md
touch_if_not_exist docs/privacy.md
touch_if_not_exist docs/license.md
touch_if_not_exist docs/gdpr.md

# Create mkdocs.yml if not exist
if [ ! -f mkdocs.yml ]; then
  echo "Creating mkdocs.yml"
  cat <<EOF > mkdocs.yml
site_name: AI App Privacy & Licensing
nav:
  - Home: index.md
  - Privacy Policy: privacy.md
  - Licensing: license.md
  - GDPR: gdpr.md
theme:
  name: material
EOF
fi

# Create GitHub Actions workflow
if [ ! -f .github/workflows/deploy.yml ]; then
  echo "Creating GitHub Actions workflow"
  cat <<EOF > .github/workflows/deploy.yml
name: Deploy MkDocs site to GitHub Pages

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.x'

      - name: Install dependencies
        run: |
          pip install mkdocs mkdocs-material

      - name: Build and deploy
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: \${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./site
          publish_branch: gh-pages
          force_orphan: true
EOF
fi

echo "✅ Setup complete."
