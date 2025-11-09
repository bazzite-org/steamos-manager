if [ -z "$1" ]; then
    echo "Usage: $0 <host>"
    exit 1
fi

HOST=$1
RSYNC="rsync -rv --exclude .git --exclude venv --exclude __pycache__'"
USER=${2:-bazzite}

cargo build --release
$RSYNC target/debug/steamos-manager $HOST:

ssh $HOST /bin/bash << EOF
    sudo rpm-ostree usroverlay
    sudo mv steamos-manager /usr/bin/steamos-manager

    sudo systemctl restart steamos-manager.service
    systemctl --user restart steamos-manager.service
    bazzite-session-select gamescope
EOF