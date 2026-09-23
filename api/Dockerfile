# ─────────────────────────────────────────────────────────────────────────────
# Room Access API — Dockerfile
# DevSecOps Experiment 7
# Base: python:3.12-slim (small footprint, no unnecessary packages)
# ─────────────────────────────────────────────────────────────────────────────

FROM python:3.12-slim

LABEL experiment="7-devsecops" \
      description="Room Access Request System Security API" \
      maintainer="lab-student"

# Create a non-root user for better security posture
RUN useradd -m -u 1001 appuser

WORKDIR /app

# Copy and install dependencies first (leverages Docker layer cache)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY app.py .

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 5000

# Docker health check — used by the CI/CD pipeline readiness probe
HEALTHCHECK --interval=10s --timeout=5s --retries=5 --start-period=10s \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" \
  || exit 1

# Start Flask application
CMD ["python", "app.py"]
