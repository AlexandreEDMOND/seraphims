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

- **CLI** : [claw-code](https://github.com/ultraworkers/claw-code) — fork de Claude Code adapté pour dialoguer avec des modèles compatibles OpenAI API
- **Modèle** : Gemma 4 (E4B Instruct) — modèle open-source de Google, servi localement
- **Inférence** : [vLLM](https://github.com/vllm-project/vllm) — serveur d'inférence haute performance, exposant une API compatible OpenAI
- **Environnement** : WSL2 (Windows Subsystem for Linux)

## Architecture

```
┌─────────────────────────────────────────────┐
│  Windows / WSL2                             │
│                                             │
│  ┌──────────────┐     ┌──────────────────┐  │
│  │  claw-code   │────▶│  vLLM server     │  │
│  │  (CLI)       │     │  localhost:8000  │  │
│  └──────────────┘     │  (Gemma 4 E4B)   │  │
│                       └──────────────────┘  │
│                                             │
│  Agents définis dans /agents                │
└─────────────────────────────────────────────┘
```

## Prérequis

- WSL2 avec Ubuntu (ou distro Debian-based)
- GPU Nvidia avec drivers CUDA installés (recommandé pour vLLM)
- Python 3.10+ dans WSL
- [uv](https://github.com/astral-sh/uv) (installé automatiquement par le script)
- Node.js 18+ (pour claw-code)
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
2. Un environnement virtuel Python avec `vLLM`
3. `claw-code` via npm

## Lancer le modèle

```bash
./scripts/start_model.sh
```

Le serveur vLLM démarre sur `http://localhost:8000` et expose une API compatible OpenAI.

Pour vérifier que le serveur est prêt :

```bash
curl http://localhost:8000/v1/models
```

## Utilisation

Une fois le serveur vLLM lancé, ouvrir un autre terminal et lancer claw-code :

```bash
claw-code
```

claw-code est configuré (via `.clawcode` ou variable d'environnement) pour pointer vers le serveur local :

```bash
export OPENAI_API_BASE=http://localhost:8000/v1
export OPENAI_API_KEY=local  # n'importe quelle valeur, vLLM n'authentifie pas en local
```

## Structure du projet

```
seraphims/
├── agents/          # Définitions des agents autonomes
├── scripts/
│   ├── setup.sh     # Installation complète
│   └── start_model.sh  # Lancement du serveur vLLM
└── README.md
```
