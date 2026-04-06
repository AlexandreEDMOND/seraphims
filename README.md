# Seraphims

> Plateforme d'agents autonomes pour automatiser les tâches du quotidien, propulsée par un modèle Gemma 4 local via vLLM et pilotée par claw-code.

## Table des matières

- [À propos](#à-propos)
- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Lancer le modèle](#lancer-le-modèle)
- [Utilisation](#utilisation)

## À propos

**Seraphims** est un ensemble d'agents IA autonomes conçus pour exécuter des tâches répétitives et complexes sans intervention humaine. Le projet tourne entièrement en local :

- **CLI** : [claw-code](https://github.com/ultraworkers/claw-code) — implémentation Rust open-source du harness d'agent `claw`, compatible avec des modèles locaux
- **Modèle** : Gemma 4 (E4B Instruct) — modèle open-source de Google, servi localement
- **Inférence** : [vLLM](https://github.com/vllm-project/vllm) — serveur d'inférence haute performance, exposant une API compatible OpenAI
- **Environnement** : WSL2 (Windows Subsystem for Linux)

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│  Windows / WSL2                                              │
│                                                              │
│  ┌──────────┐   Anthropic API   ┌──────────┐  OpenAI API   │
│  │   claw   │ ────────────────▶ │ LiteLLM  │ ────────────▶ │
│  │  (CLI)   │                   │ :4000    │               │
│  └──────────┘                   └──────────┘               │
│                                      │                       │
│                                      ▼                       │
│                               ┌──────────────┐              │
│                               │    vLLM      │              │
│                               │    :8000     │              │
│                               │ (Gemma 4 E4B)│              │
│                               └──────────────┘              │
└──────────────────────────────────────────────────────────────┘
```

claw parle le protocole Anthropic. vLLM expose une API OpenAI-compatible. **LiteLLM** sert de proxy de traduction entre les deux.

## Prérequis

- WSL2 avec Ubuntu (ou distro Debian-based)
- GPU Nvidia avec drivers CUDA installés (recommandé pour vLLM)
- Python 3.10+ dans WSL
- [uv](https://github.com/astral-sh/uv) (installé automatiquement par le script)
- Rust toolchain (installée automatiquement par le script via rustup)
- Le modèle Gemma 4 E4B Instruct téléchargé dans `~/models/gemma-4-E4B-it`

### Vérifier CUDA dans WSL

```bash
nvidia-smi
nvcc --version
```

## Installation

Cloner le repo et lancer le script d'installation :

```bash
git clone https://github.com/AlexandreEDMOND/seraphims.git
cd seraphims
chmod +x scripts/setup.sh
./scripts/setup.sh
```

Le script installe :
1. `uv` (gestionnaire de paquets Python ultra-rapide)
2. Un environnement virtuel Python avec `vLLM` et `LiteLLM`
3. Rust via `rustup`, clone et compile `claw-code` depuis les sources, puis crée un lien `claw` dans `~/.local/bin`

## Lancer le modèle

Il faut **3 terminaux** :

**Terminal 1 — vLLM** (inférence GPU) :
```bash
./scripts/start_model.sh
# vérifier : curl http://localhost:8000/v1/models
```

**Terminal 2 — LiteLLM** (proxy Anthropic → OpenAI) :
```bash
./scripts/start_proxy.sh
# vérifier : curl http://localhost:4000/health
```

**Terminal 3 — claw** :
```bash
source ./scripts/env.sh
claw
```

`env.sh` positionne deux variables :
```bash
ANTHROPIC_BASE_URL=http://localhost:4000   # pointe sur LiteLLM
ANTHROPIC_API_KEY=local                    # valeur quelconque, non vérifiée
```

## Structure du projet

```
seraphims/
├── agents/                  # Définitions des agents autonomes
├── config/
│   └── litellm.yaml         # Config du proxy LiteLLM
├── scripts/
│   ├── setup.sh             # Installation complète
│   ├── start_model.sh       # Lancement de vLLM (port 8000)
│   ├── start_proxy.sh       # Lancement de LiteLLM (port 4000)
│   └── env.sh               # Variables d'env pour claw
└── README.md
```
