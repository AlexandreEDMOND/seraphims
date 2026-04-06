#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="$REPO_ROOT/.venv"
MODEL_PATH="${MODEL_PATH:-$HOME/models/gemma-4-E4B-it}"

# ─── Vérifications ───────────────────────────────────────────────────────────
if [ ! -d "$VENV_DIR" ]; then
  echo "Erreur : environnement virtuel introuvable. Lance d'abord ./scripts/setup.sh"
  exit 1
fi

if [ ! -d "$MODEL_PATH" ]; then
  echo "Erreur : modèle introuvable dans $MODEL_PATH"
  echo "  Vérifie que Gemma 4 E4B est bien téléchargé à cet emplacement,"
  echo "  ou surcharge la variable MODEL_PATH :"
  echo "    MODEL_PATH=/chemin/vers/modele ./scripts/start_model.sh"
  exit 1
fi

# ─── Configuration ───────────────────────────────────────────────────────────
HOST="${VLLM_HOST:-0.0.0.0}"
PORT="${VLLM_PORT:-8000}"
GPU_UTIL="${VLLM_GPU_UTIL:-0.90}"
MAX_MODEL_LEN="${VLLM_MAX_MODEL_LEN:-8192}"
DTYPE="${VLLM_DTYPE:-bfloat16}"

echo "=== Seraphims — Lancement du serveur vLLM ==="
echo "  Modèle      : $MODEL_PATH"
echo "  Adresse     : http://$HOST:$PORT"
echo "  GPU util    : $GPU_UTIL"
echo "  Max tokens  : $MAX_MODEL_LEN"
echo "  dtype       : $DTYPE"
echo ""
echo "Variables d'environnement pour claw-code :"
echo "  export OPENAI_API_BASE=http://localhost:$PORT/v1"
echo "  export OPENAI_API_KEY=local"
echo ""
echo "Appuie sur Ctrl+C pour arrêter le serveur."
echo ""

# ─── Lancement vLLM ──────────────────────────────────────────────────────────
"$VENV_DIR/bin/python" -m vllm.entrypoints.openai.api_server \
  --model "$MODEL_PATH" \
  --host "$HOST" \
  --port "$PORT" \
  --gpu-memory-utilization "$GPU_UTIL" \
  --max-model-len "$MAX_MODEL_LEN" \
  --dtype "$DTYPE" \
  --served-model-name "gemma-4"
