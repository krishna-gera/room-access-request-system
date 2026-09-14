# Controlled Vulnerability Demonstration for Experiment 6 (DevSecOps Lab)
# Base image: Legacy Nginx 1.14.0 Alpine (contains multiple known HIGH & CRITICAL CVEs)
FROM nginx:1.14.0-alpine

# Working directory
WORKDIR /usr/share/nginx/html

# Copy configuration and web assets
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY build/web/ .

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
