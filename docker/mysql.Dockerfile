FROM mysql:8.0

# Initialization script that sets appropriate permissions
RUN mkdir -p /docker-entrypoint-initdb.d
COPY mysql-init.sh /docker-entrypoint-initdb.d/

# Ensure log directory exists and has correct permissions
RUN mkdir -p /var/log/mysql && chown -R mysql:mysql /var/log/mysql

EXPOSE 3306
