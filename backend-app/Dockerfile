# Use Node.js official image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy backend code
COPY . .

# Install dependencies
RUN npm install

# Expose backend port
EXPOSE 8080

# Start the backend
CMD ["node", "app.js"]

