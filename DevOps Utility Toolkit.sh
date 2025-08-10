#!/bin/bash
# ==============================================
# DevOps Utility Toolkit - Swiss Army Knife
# Author: Your Name
# ==============================================

# ======== CONFIG ========
LOG_DIR="/var/log/myapp"
DISK_THRESHOLD=80
ADMIN_EMAIL="admin@example.com"

MYSQL_USER="root"
MYSQL_PASS="mypassword"
MYSQL_DB="mydb"
BACKUP_DIR="/backup/mysql"
S3_BUCKET="mybucket"

SERVICE_NAME="nginx"

DOCKER_IMAGE="myapp"
DOCKER_REGISTRY="myregistry.com"
K8S_NAMESPACE="production"
K8S_DEPLOYMENT="myapp"

# ======== FUNCTIONS ========

# 1. Cleanup old logs
cleanup_logs() {
    echo "[INFO] Cleaning up logs older than 30 days..."
    find "$LOG_DIR" -type f -mtime +30 -exec rm -f {} \;
}

# 2. Disk usage monitor
check_disk_usage() {
    USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$USAGE" -gt "$DISK_THRESHOLD" ]; then
        echo "Disk usage is above $DISK_THRESHOLD% (Current: $USAGE%)" | \
        mail -s "Disk Alert" "$ADMIN_EMAIL"
    fi
}

# 3. Service health check
check_service() {
    if ! systemctl is-active --quiet "$SERVICE_NAME"; then
        echo "[WARN] $SERVICE_NAME is down! Restarting..."
        systemctl restart "$SERVICE_NAME"
    fi
}

# 4. MySQL backup
backup_mysql() {
    DATE=$(date +%F)
    mkdir -p "$BACKUP_DIR"
    mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASS" "$MYSQL_DB" > "$BACKUP_DIR/${MYSQL_DB}_${DATE}.sql"
    echo "[INFO] MySQL backup complete: $BACKUP_DIR/${MYSQL_DB}_${DATE}.sql"

    # Upload to S3
    aws s3 cp "$BACKUP_DIR/${MYSQL_DB}_${DATE}.sql" "s3://$S3_BUCKET/"
}

# 5. Docker build & push
build_and_push_docker() {
    TAG=$(date +%Y%m%d%H%M)
    docker build -t "$DOCKER_IMAGE:$TAG" .
    docker tag "$DOCKER_IMAGE:$TAG" "$DOCKER_REGISTRY/$DOCKER_IMAGE:$TAG"
    docker push "$DOCKER_REGISTRY/$DOCKER_IMAGE:$TAG"
    echo "[INFO] Docker image pushed: $DOCKER_REGISTRY/$DOCKER_IMAGE:$TAG"
}

# 6. Restart Kubernetes deployment
restart_k8s() {
    kubectl rollout restart deployment/"$K8S_DEPLOYMENT" -n "$K8S_NAMESPACE"
    echo "[INFO] Kubernetes deployment restarted: $K8S_DEPLOYMENT"
}

# ======== MENU ========
echo "=============================================="
echo "     DevOps Utility Toolkit"
echo "=============================================="
echo "1) Cleanup old logs"
echo "2) Check disk usage"
echo "3) Check and restart service"
echo "4) Backup MySQL database (local + S3)"
echo "5) Build & push Docker image"
echo "6) Restart Kubernetes deployment"
echo "7) Run all tasks"
echo "0) Exit"
echo "=============================================="

read -p "Select an option: " CHOICE

case $CHOICE in
    1) cleanup_logs ;;
    2) check_disk_usage ;;
    3) check_service ;;
    4) backup_mysql ;;
    5) build_and_push_docker ;;
    6) restart_k8s ;;
    7) cleanup_logs; check_disk_usage; check_service; backup_mysql; build_and_push_docker; restart_k8s ;;
    0) echo "Exiting..."; exit 0 ;;
    *) echo "Invalid choice!" ;;
esac
