# Configuration WSL2 pour Gemma 4

Le modèle Gemma 4 E4B pèse ~16 Go. WSL2 alloue par défaut la moitié de ta RAM
physique (max 8 Go), ce qui est insuffisant pour charger le modèle **en plus** du
KV cache GPU.

## Prérequis RAM minimum

| Composante | Taille estimée |
|---|---|
| Modèle safetensors (mmap) | ~16 Go |
| KV cache GPU (8192 tokens, bf16) | ~2–4 Go |
| Overhead vLLM + Python | ~1–2 Go |
| **Total recommandé** | **≥ 20 Go** |

## Étapes

1. Ouvre un terminal **PowerShell** (Windows) et crée ou édite le fichier :

```powershell
notepad "$env:USERPROFILE\.wslconfig"
```

2. Colle ce contenu (adapte `memory` à ta RAM disponible) :

```ini
[wsl2]
memory=20GB        # RAM allouée à WSL2 — au moins 20 Go pour Gemma 4 E4B
swap=8GB           # swap optionnel si RAM limitée
processors=8       # ajuste selon ton CPU
```

3. Redémarre WSL2 depuis PowerShell :

```powershell
wsl --shutdown
wsl
```

4. Vérifie que la RAM est bien disponible dans WSL2 :

```bash
free -h
```

## Note sur vm.max_map_count

Le script `start_model.sh` applique automatiquement `sudo sysctl -w vm.max_map_count=1048576`
avant de lancer vLLM. Ce réglage est nécessaire pour que le kernel Linux puisse
mapper le fichier safetensors de ~16 Go en mémoire virtuelle. La valeur revient
à la normale au prochain redémarrage WSL.

Pour le rendre permanent dans WSL2, ajoute cette ligne dans `/etc/sysctl.conf` :

```
vm.max_map_count=1048576
```
