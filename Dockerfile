# ------------------------------------------------------------------
# STAGE 1: Builder (For dependencies requiring build tools)
# ------------------------------------------------------------------
FROM python:3.10-slim AS builder

# Install build dependencies and clean up apt cache
RUN apt-get update && apt-get install -y build-essential curl --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
COPY setup.py .
COPY . .

# Use the added timeout here (you have this already, ensure it is retained)
RUN pip install --no-cache-dir -e . --timeout 1200 

# ------------------------------------------------------------------
# STAGE 2: Final Runtime Image (Minimal size)
# This stage only copies the necessary runtime files and installed packages.
# ------------------------------------------------------------------
FROM python:3.10-slim

WORKDIR /app

# Copy the application source code
COPY --from=builder /app /app

# Copy the installed Python packages (excludes the huge build-essential overhead)
COPY --from=builder /usr/local/lib/python3.10/site-packages/ /usr/local/lib/python3.10/site-packages/

# Example entry point (adjust if needed)
CMD ["python", "app/app.py"]

