#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="$REPO_ROOT/.venv"
CONFIG="$REPO_ROOT/config/litellm.yaml"
PORT="${LITELLM_PORT:-4000}"

if [ ! -d "$VENV_DIR" ]; then
  echo "Erreur : environnement virtuel introuvable. Lance d'abord ./scripts/setup.sh"
  exit 1
fi

echo "=== Seraphims — Lancement du proxy LiteLLM ==="
echo "  Config  : $CONFIG"
echo "  Port    : $PORT"
echo "  Traduit : requêtes Anthropic → OpenAI → vLLM"
echo ""
echo "Dans un autre terminal, configure claw avec :"
echo "  source ./scripts/env.sh"
echo ""
echo "Appuie sur Ctrl+C pour arrêter le proxy."
echo ""

"$VENV_DIR/bin/litellm" \
  --config "$CONFIG" \
  --port "$PORT" \
  --host 127.0.0.1
