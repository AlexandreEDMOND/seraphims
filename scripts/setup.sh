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

echo "[2/3] Création de l'environnement virtuel et installation de vLLM + LiteLLM..."
uv venv "$VENV_DIR" --python 3.11

# vLLM avec support CUDA + LiteLLM comme proxy Anthropic→OpenAI
uv pip install --python "$VENV_DIR/bin/python" \
  "vllm>=0.4.0" \
  "huggingface_hub" \
  "litellm[proxy]"

echo "      vLLM installé : $("$VENV_DIR/bin/python" -c 'import vllm; print(vllm.__version__)')"
echo "      LiteLLM installé : $("$VENV_DIR/bin/python" -c 'import litellm; print(litellm.__version__)')"

# ─── 3. claw-code (build depuis les sources) ─────────────────────────────────
CLAW_DIR="$REPO_ROOT/claw-code"

echo "[3/3] Installation de claw-code (Rust)..."

# 3a. Rust / cargo
if ! command -v cargo &>/dev/null; then
  echo "      Rust introuvable. Installation via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  export PATH="$HOME/.cargo/bin:$PATH"
fi
echo "      cargo : $(cargo --version)"

# 3b. Cloner le repo si besoin
if [ ! -d "$CLAW_DIR" ]; then
  git clone https://github.com/ultraworkers/claw-code.git "$CLAW_DIR"
else
  echo "      claw-code déjà cloné, mise à jour..."
  git -C "$CLAW_DIR" pull --ff-only
fi

# 3c. Compiler le workspace Rust
echo "      Compilation en cours (peut prendre quelques minutes)..."
cargo build --release --manifest-path "$CLAW_DIR/rust/Cargo.toml" --workspace

# 3d. Lien symbolique dans ~/.local/bin
CLAW_BIN="$CLAW_DIR/rust/target/release/claw"
mkdir -p "$HOME/.local/bin"
ln -sf "$CLAW_BIN" "$HOME/.local/bin/claw"

# S'assurer que ~/.local/bin est dans le PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo ""
  echo "  Ajoute cette ligne à ton ~/.bashrc ou ~/.zshrc pour rendre 'claw' accessible :"
  echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

echo "      claw installé : $("$CLAW_BIN" --version 2>/dev/null || echo 'ok')"

echo ""
echo "=== Installation terminée ==="
echo ""
echo "Prochaines étapes :"
echo "  1. Lancer vLLM         : ./scripts/start_model.sh"
echo "  2. Lancer le proxy     : ./scripts/start_proxy.sh"
echo "  3. Ouvrir claw         : source ./scripts/env.sh && claw"
