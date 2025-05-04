# Use Node.js image to get npm and install http-server
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy static site contents
COPY . .

# Install http-server globally
RUN npm install -g http-server

# Expose port
EXPOSE 3000

# Start static server
CMD ["http-server", "-p", "3000"]

