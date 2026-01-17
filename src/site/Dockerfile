FROM nginx:alpine

# Copy the HTML file to nginx default directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 8080 (Cloud Run requirement)
EXPOSE 8080

# Create nginx config for Cloud Run
RUN echo 'server { \
    listen 8080; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
