FROM ubuntu:18.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /app

# Install system dependencies (INTENTIONALLY OLD BASE IMAGE)
RUN apt-get update \
 && apt-get install -y \
    python3 \
    python3-pip \
    gcc \
    libmysqlclient-dev \
    pkg-config \
 && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt || true

# Copy application code
COPY . .

# Run app
CMD ["python3", "app.py"]
