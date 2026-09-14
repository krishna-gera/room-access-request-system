# Production Dockerfile for Flutter Web Application
# Base image: Official unprivileged Nginx on Alpine (runs non-root, ultra-lightweight, 0 vulnerabilities)
FROM nginxinc/nginx-unprivileged:alpine

# Set working directory to Nginx HTML root
WORKDIR /usr/share/nginx/html

# Copy custom Nginx configuration for Flutter SPA routing and caching
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy compiled Flutter web release assets into html root
COPY build/web/ .

# Expose unprivileged HTTP port (8080)
EXPOSE 8080

# Run Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
