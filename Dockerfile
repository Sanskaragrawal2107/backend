# Use Python slim image for smaller size
FROM python:3.10-slim

# Install system dependencies for OpenCV and other libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Python dependencies
COPY requirements.txt .

# Install Python dependencies in stages for better caching
RUN pip install --upgrade pip && pip install --no-cache-dir setuptools wheel

# Install dependencies one by one to better isolate failures
RUN pip install --no-cache-dir fastapi==0.95.1 uvicorn==0.22.0 python-multipart==0.0.6
RUN pip install --no-cache-dir supabase==1.0.3 python-dotenv==1.0.0
RUN pip install --no-cache-dir opencv-python-headless==4.7.0.72 numpy==1.24.3
RUN pip install --no-cache-dir deepface==0.0.75
RUN pip install --no-cache-dir faiss-cpu==1.7.3

# Copy application code
COPY backend/ ./backend
COPY backend/utils/ ./backend/utils

# Ensure store and temp directories exist
RUN mkdir -p backend/store backend/temp

# Expose port
EXPOSE 8080

# Set environment variables for Supabase (Railway provides env vars)
ENV PYTHONUNBUFFERED=1

# Create a startup script that handles the PORT environment variable
RUN echo '#!/bin/bash\nPORT=${PORT:-8080}\nuvicorn backend.main:app --host 0.0.0.0 --port $PORT' > /app/start.sh && chmod +x /app/start.sh

# Start the app with the shell script
CMD ["/bin/bash", "/app/start.sh"]
