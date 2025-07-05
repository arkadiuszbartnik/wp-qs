#!/bin/bash

# Function to copy MySQL logs from container
copy_mysql_logs() {
    container_name="wordpress-db-1"
    
    echo "ℹ Copying MySQL logs from container..."
    
    # Check if container is running
    if ! docker ps | grep -q "$container_name"; then
        echo "❌ MySQL container is not running"
        return 1
    fi
    
    # Create directory if it doesn't exist
    mkdir -p logs/mysql
    
    # Copy logs from container
    docker exec "$container_name" sh -c 'ls /var/log/mysql/ 2>/dev/null' | while read logfile; do
        if [ -n "$logfile" ]; then
            echo "📄 Copying $logfile..."
            docker cp "$container_name:/var/log/mysql/$logfile" "logs/mysql/$logfile" 2>/dev/null || echo "⚠️  Cannot copy $logfile"
        fi
    done
    
    echo "✅ Finished copying MySQL logs"
}

# Main function
case "$1" in
    copy-mysql-logs)
        copy_mysql_logs
        ;;
    *)
        echo "Usage: $0 copy-mysql-logs"
        exit 1
        ;;
esac
