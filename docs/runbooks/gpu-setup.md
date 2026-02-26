# Runbook: GPU Detection and Setup

## Detect GPU Hardware

```bash
# List PCI devices, filter for VGA/3D controllers
lspci | grep -iE 'vga|3d|display'

# Detailed GPU info
lspci -v -s $(lspci | grep -iE 'vga|3d' | awk '{print $1}')
```

## Determine GPU Type

| lspci output contains | GPU type |
|----------------------|----------|
| `NVIDIA` | nvidia |
| `AMD` or `ATI` or `Radeon` | amd |
| `Intel` | intel |
| None of the above | none |

## Configure the GPU Module

Edit the hardware config or `flake.nix` to set:

```nix
valisos.gpu.type = "nvidia"; # or "amd", "intel", "none"
```

## Apply and Verify

1. Test: `sudo nixos-rebuild test`
2. Apply: `sudo nixos-rebuild switch` (may require reboot for driver changes)
3. Verify:

### NVIDIA
```bash
nvidia-smi
```

### AMD
```bash
rocm-smi
```

### Intel
```bash
clinfo
```

## Enable vLLM After GPU Setup

Once GPU drivers are confirmed working:

```nix
valisos.localLLM.enable = true;
valisos.localLLM.model = "Qwen/Qwen2.5-Coder-7B-Instruct";
```

Test and apply, then verify:
```bash
systemctl status vllm
curl http://127.0.0.1:8000/v1/models
```
