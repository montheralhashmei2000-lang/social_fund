# Dockerfile for Oracle Cloud Backend (ARM Ampere Instances)
# Uses Ubuntu 22.04 LTS with PostgreSQL 14
FROM ubuntu:22.04

# Install required packages
RUN apt-get update && \
    apt-get install -y \
        postgresql-14 \
        libpq-dev \
        gcc \
        curl \
        git \
        ca-certificates \
        zip \
    && rm -rf /var/lib/apt/lists/*

# Create application directory
WORKDIR /app

# Copy project files
COPY . .

# Set environment variables
ENV PGPASSWORD=your_secure_password_here
ENV PGHOST=oracle_backend_host
ENV PGPORT=5432
ENV DATABASE_URL="postgres://user:password@${PGHOST}:${PGPORT}/social_fund" \
    ORACLE_CLUSTER_ID=your_oracle_cluster_id \
    ORACLE_REGION=us-phoenix-1

# Expose port (if needed for external access)
EXPOSE 5432

# Start PostgreSQL with Oracle Cloud configuration
CMD ["pg_ctl", "-D", "/var/lib/postgresql/data", "start"]