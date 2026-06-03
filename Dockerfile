# Start from official Python image
FROM python:3.11-slim

# Set working directory inside the container
WORKDIR /app

# Copy requirements first (Docker caches this layer — faster builds)
COPY requirements.txt .

# Install Python packages
RUN pip install --no-cache-dir -r requirements.txt

# Copy all app code
COPY . .

# Tell Docker this container listens on port 5000
EXPOSE 5000

# Command to run when container starts
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
