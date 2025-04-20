# Use official FastAPI image
FROM tiangolo/uvicorn-gunicorn-fastapi:python3.11

# Set working directory
WORKDIR /app

# Copy Python dependencies
COPY requirements.txt .

# Install Python dependencies
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY backend/ ./backend
COPY backend/utils/ ./backend/utils

# Ensure store and temp directories exist
RUN mkdir -p backend/store backend/temp

# Expose port
EXPOSE 8080

# Set environment variables for Supabase (Railway provides env vars)
ENV PYTHONUNBUFFERED=1

# Start the app with Uvicorn
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8080"]
