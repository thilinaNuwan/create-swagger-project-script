#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 <project_name>"
    exit 1
}

# Check if project name is provided
if [ -z "$1" ]; then
    usage
fi

# Set the project name
PROJECT_NAME=$1

# Set the base directory of the monorepo
BASE_DIR="$(pwd)/$PROJECT_NAME"

# Create the project directory
mkdir -p $BASE_DIR

# Create necessary directories
mkdir -p $BASE_DIR/src/apis
mkdir -p $BASE_DIR/.build

# Create index.html
cat <<EOL > $BASE_DIR/index.html
<!doctype html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Our API Documentation</title>
    </head>
    <body>
        <div id="swagger"></div>
    </body>
</html>
EOL

# Create index.js
cat <<EOL > $BASE_DIR/index.js
import SwaggerUI from "swagger-ui";
import "swagger-ui/dist/swagger-ui.css";
import spec from "./.build/swagger.yaml";
SwaggerUI({
  spec,
  dom_id: "#swagger",
});
EOL

# Create package.json
cat <<EOL > $BASE_DIR/package.json
{
  "name": "$PROJECT_NAME",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "validate": "swagger-cli bundle -t yaml ./src/swagger-config.yaml -o ./.build/swagger.yaml && swagger-cli validate ./.build/swagger.yaml",
    "build": "swagger-cli bundle -t yaml ./src/swagger-config.yaml -o ./.build/swagger.yaml && webpack",
    "start": "swagger-cli bundle -t yaml ./src/swagger-config.yaml -o ./.build/swagger.yaml && webpack serve --open --mode development"
  },
  "author": "",
  "license": "ISC",
  "devDependencies": {
    "css-loader": "^7.1.2",
    "html-webpack-plugin": "^5.6.0",
    "style-loader": "^4.0.0",
    "swagger-cli": "^4.0.4",
    "webpack": "^5.91.0",
    "webpack-cli": "^5.1.4",
    "webpack-dev-server": "^5.0.4",
    "yaml-loader": "^0.8.1"
  },
  "dependencies": {
    "swagger-ui": "^5.17.14"
  }
}
EOL

# Create webpack.config.js
cat <<EOL > $BASE_DIR/webpack.config.js
const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const outputPath = path.resolve(__dirname, "dist");

module.exports = {
  mode: "development",
  entry: {
    app: "./index.js",
  },
  module: {
    rules: [
      {
        test: /\.yaml$/,
        use: [{ loader: "yaml-loader" }],
      },
      {
        test: /\.css$/,
        use: [{ loader: "style-loader" }, { loader: "css-loader" }],
      },
    ],
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: "index.html",
    }),
  ],
  output: {
    filename: "[name].bundle.js",
    path: outputPath,
  },
};
EOL

# Create README.md
cat <<EOL > $BASE_DIR/README.md
# $PROJECT_NAME

This project contains the Swagger documentation for the $PROJECT_NAME API.

## Structure

- \`index.html\`: The HTML template for Swagger UI.
- \`index.js\`: The entry point for the Webpack build.
- \`package.json\`: The NPM configuration file.
- \`webpack.config.js\`: The Webpack configuration file.
- \`src/apis/apis.yaml\`: The main Swagger API definition file.
- \`src/swagger-config.yaml\`: Configuration for bundling Swagger files.

## Usage

1. Replace \`src/apis/apis.yaml\` with your API specification.
2. Run \`npm install\` to install dependencies.
3. Use \`npm run validate\` to validate your Swagger file.
4. Use \`npm run build\` to bundle and build your project.
5. Use \`npm start\` to serve the documentation locally.

EOL

# Create .gitignore
cat <<EOL > $BASE_DIR/.gitignore
# Node modules
node_modules
dist
.build
EOL

# Create src/swagger-config.yaml
cat <<EOL > $BASE_DIR/src/swagger-config.yaml
swagger: '2.0'
info:
  title: $PROJECT_NAME API
  description: API documentation for $PROJECT_NAME.
  version: 1.0.0
host: www.smata.com
basePath: /
schemes:
  - https
paths: {}
EOL

# Create src/apis/apis.yaml
cat <<EOL > $BASE_DIR/src/apis/apis.yaml
swagger: '2.0'
info:
  title: $PROJECT_NAME API
  description: API documentation for $PROJECT_NAME.
  version: 1.0.0
paths: {}
EOL

# Print completion message
echo "Swagger documentation setup for '$PROJECT_NAME' created successfully at $BASE_DIR"
