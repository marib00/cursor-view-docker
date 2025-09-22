# Stage 1: Build the frontend
FROM node:18-alpine AS builder
WORKDIR /app/frontend

COPY frontend/package.json frontend/package-lock.json ./
RUN npm install

COPY frontend/ ./
RUN npm run build

# Stage 2: Final image with Python, Gunicorn, and Nginx
FROM python:3.9-slim
WORKDIR /app

# Install Nginx
RUN apt-get update && apt-get install -y nginx

# Copy Python requirements and install them (including Gunicorn)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt gunicorn

# Copy all application code
COPY . .

# Copy the built frontend from the builder stage into the Nginx static file directory
COPY --from=builder /app/frontend/build /var/www/html

# Create the Nginx configuration file directly inside the image
RUN echo "upstream gunicorn_server { server 127.0.0.1:8000; } \
\
server { \
    listen 5000; \
    server_name _; \
\
    root /var/www/html; \
    index index.html; \
\
    location /api/ { \
        proxy_pass http://gunicorn_server; \
        proxy_set_header Host \$host; \
        proxy_set_header X-Real-IP \$remote_addr; \
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for; \
    } \
\
    location / { \
        try_files \$uri /index.html; \
    } \
}" > /etc/nginx/sites-available/default

# Create the startup script directly inside the image
RUN echo "#!/bin/sh\n\
# Start Gunicorn in the background listening on port 8000\n\
gunicorn --bind 0.0.0.0:8000 server:app &\n\
# Start Nginx in the foreground to keep the container running\n\
nginx -g 'daemon off;'" > /app/start.sh

# Make the startup script executable
RUN chmod +x /app/start.sh

EXPOSE 5000

# Run the startup script
CMD ["/app/start.sh"]

# --- How to use ---
# 1. Build the Docker image:
#    docker build -t cursor-view .
#
# 2. Run the Docker container (macOS example):
#    docker run -p 5001:5000 -v ~/Library/Application\\ Support/Cursor:/root/.config/Cursor --name cursor-view cursor-view
