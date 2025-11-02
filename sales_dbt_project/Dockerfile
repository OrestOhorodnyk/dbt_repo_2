# ================================
# Stage 1: install dbt runtime
# ================================
FROM python:3.11-slim

# Install lightweight system deps and git
RUN apt-get update && apt-get install -y --no-install-recommends libpq-dev git && \
    pip install --no-cache-dir --upgrade pip setuptools wheel && \
    rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /opt/dbt

# Copy requirements and install dbt + adapter
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy your dbt project files
COPY . /opt/dbt/

# ✅ Copy precompiled manifest and other target artifacts
#    (Run `dbt deps && dbt compile` locally before building)
COPY target /opt/dbt/target

# Environment variables for runtime (optional, Cosmos uses Airflow connection)
ENV DBT_PROJECT_DIR=/opt/dbt \
    DBT_PROFILES_DIR=/opt/dbt/profiles

# Add simple dbt entrypoint that forwards arguments
# Option 1: Use entrypoint script (must forward args)
COPY entrypoint.sh /usr/local/bin/dbt-entrypoint
RUN chmod +x /usr/local/bin/dbt-entrypoint
ENTRYPOINT ["/usr/local/bin/dbt-entrypoint"]

# Option 2 (Alternative): Use dbt directly (simpler)
# ENTRYPOINT ["dbt"]
