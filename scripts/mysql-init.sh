#!/bin/bash

# Set permissions for log directory
if [ -d "/var/log/mysql" ]; then
    chown -R mysql:mysql /var/log/mysql
    chmod -R 755 /var/log/mysql
fi

# Create log files if they don't exist
touch /var/log/mysql/error.log
touch /var/log/mysql/general.log
touch /var/log/mysql/slow.log

# Set permissions for log files
chown mysql:mysql /var/log/mysql/*.log
chmod 644 /var/log/mysql/*.log

echo "MySQL logs permissions set up successfully"
