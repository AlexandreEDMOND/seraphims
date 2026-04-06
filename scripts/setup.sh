#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== Seraphims — Installation ==="
echo ""

# ─── 1. uv ───────────────────────────────────────────────────────────────────
if ! command -v uv &>/dev/null; then
  echo "[1/3] Installation de uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  # Recharger le PATH pour la session courante
  export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
  echo "      uv installé : $(uv --version)"
else
  echo "[1/3] uv déjà présent : $(uv --version)"
fi

# ─── 2. vLLM via uv ──────────────────────────────────────────────────────────
VENV_DIR="$REPO_ROOT/.venv"

echo "[2/3] Création de l'environnement virtuel et installation de vLLM..."
uv venv "$VENV_DIR" --python 3.11

# vLLM avec support CUDA (ajuster l'extra si besoin : cpu / rocm / xpu)
uv pip install --python "$VENV_DIR/bin/python" \
  "vllm>=0.4.0" \
  "huggingface_hub"

echo "      vLLM installé : $("$VENV_DIR/bin/python" -c 'import vllm; print(vllm.__version__)')"

# ─── 3. claw-code via npm ────────────────────────────────────────────────────
echo "[3/3] Installation de claw-code..."
if ! command -v node &>/dev/null; then
  echo "      Node.js introuvable. Installation via nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  # shellcheck source=/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
fi

npm install -g claw-code

echo ""
echo "=== Installation terminée ==="
echo ""
echo "Prochaines étapes :"
echo "  1. Lancer le modèle  : ./scripts/start_model.sh"
echo "  2. Ouvrir claw-code  : claw-code"
