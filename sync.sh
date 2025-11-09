if [ -z "$1" ]; then
    echo "Usage: $0 <host>"
    exit 1
fi

set -e

HOST=$1
RSYNC="rsync -rv --exclude .git --exclude venv --exclude __pycache__'"
USER=${2:-bazzite}

cargo build --release
$RSYNC target/release/steamos-manager $HOST:

ssh $HOST /bin/bash << EOF
    sudo rpm-ostree usroverlay
    sudo mv steamos-manager /usr/bin/steamos-manager
    sudo chmod +x /usr/bin/steamos-manager
    sudo chcon -R -u system_u -r object_r --type=bin_t /usr/bin/steamos-manager

    sudo systemctl stop steamos-manager.service
    systemctl --user stop steamos-manager.service
    sudo systemctl start steamos-manager.service
    systemctl --user start steamos-manager.service
    bazzite-session-select gamescope
EOF