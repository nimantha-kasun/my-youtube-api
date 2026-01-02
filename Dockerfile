# Use Python 3.10 to fix deprecation warning and improve compatibility
FROM python:3.10-slim

# Install system dependencies
# ffmpeg: required for yt-dlp merging
# curl: for healthchecks
RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the requirements file
COPY requirements.txt .

# Install Python dependencies
# 1. Upgrade pip
# 2. Install requirements
# 3. Force upgrade yt-dlp to latest nightly/release to fix bot detection
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir --upgrade yt-dlp

# Copy the rest of the application code
COPY . .

# Expose port (Render sets PORT env, but good for local)
EXPOSE 10000

# Define environment variable
ENV PORT 10000

# Run app.py using gunicorn
# Increased timeout to 120s to allow for longer video processing
CMD exec gunicorn --bind :$PORT --workers 2 --threads 4 --timeout 120 app:app
