FROM python:3.11-slim

# Install Supercronic (cron runner)
RUN apt-get update && apt-get install -y curl && \
    curl -fsSLO "https://github.com/aptible/supercronic/releases/latest/download/supercronic-linux-amd64" && \
    chmod +x supercronic-linux-amd64 && \
    mv supercronic-linux-amd64 /usr/bin/supercronic

# Install uv using the official installer script
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# Copy dependency files first to leverage Docker caching
COPY pyproject.toml uv.lock ./

# Install dependencies exactly as locked without updating the lockfile
RUN uv sync --frozen --no-cache

# Copy the rest of your code (including crontab, main.py, etc.)
COPY . /app

# Run supercronic pointing to your crontab file
CMD ["/usr/bin/supercronic", "/app/crontab"]