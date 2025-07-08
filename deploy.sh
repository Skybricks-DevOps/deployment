SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
sh "$SCRIPT_DIR/helm/install_nginc_controller.sh"
helm upgrade --install backend "$SCRIPT_DIR/helm/backend"
helm upgrade --install frontend "$SCRIPT_DIR/helm/frontend"