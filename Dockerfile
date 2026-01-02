# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Install system dependencies (ffmpeg is often needed by yt-dlp)
RUN apt-get update && apt-get install -y \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Make port 10000 available to the world outside this container
EXPOSE 10000

# Define environment variable
ENV PORT 10000

# Run app.py when the container launches using gunicorn
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app
