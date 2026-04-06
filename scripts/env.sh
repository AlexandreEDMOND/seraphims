#!/usr/bin/env bash
# Source ce fichier avant de lancer claw :
#   source ./scripts/env.sh
#
# LiteLLM expose une API compatible Anthropic sur le port 4000.
# claw est redirigé vers ce proxy au lieu de l'API Anthropic officielle.

export ANTHROPIC_BASE_URL="http://localhost:4000"
export ANTHROPIC_API_KEY="local"

echo "claw configuré pour utiliser Gemma 4 via LiteLLM (localhost:4000)"
