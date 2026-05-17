# dotfiles — Entorno de Desarrollo Embedded Linux



<div align="center">

![Badge](https://img.shields.io/badge/Ubuntu-26.04-orange)
![Badge](https://img.shields.io/badge/Arch-compatible-blue)
![Badge](https://img.shields.io/badge/Fedora-compatible-lightblue)
![Badge](https://img.shields.io/badge/Maintainer-obviousfancy-green)

</div>

# **ES**
Configuración reproducible de entorno para desarrollo de sistemas embebidos en Linux. Automatiza la instalación y configuración de herramientas de hardware, desarrollo y debug.

# **EN**
Setting up of environment for embedded systems develops on Linux.
Automate the installation and setting up of hardware tools , develop and debug apps.
---

## 🗂️ Estructura del repositorio

```
dotfiles/
├── install.sh                  # Orquestador principal
├── scripts/
│   ├── detect-os.sh            # Detección de distro y package manager
│   ├── hardware-tools.sh       # KiCad, OpenOCD, Arduino IDE, Vivado
│   ├── dev-tools.sh            # VS Code, Docker, Git, JetBrains
│   └── embedded-tools.sh       # ARM GCC, STM32CubeIDE, debug tools
├── configs/
│   └── .gitconfig              # Configuración base de Git
├── docs/
│   ├── ubuntu-setup.md         # Bitácora de instalación en Ubuntu 26.04
│   ├── kicad.md                # Notas específicas de KiCad
│   └── stm32cubeide.md         # Notas específicas de STM32CubeIDE
└── logs/                       # Generado al ejecutar los scripts
```

---

## 🚀 Instalación rápida

```bash
git clone https://github.com/obviousfancy/dotfiles.git
cd dotfiles
chmod +x install.sh
./install.sh
```

### Opciones

```bash
./install.sh           # Menú interactivo
./install.sh --all     # Instalar todo
./install.sh --hw      # Solo herramientas de hardware
./install.sh --dev     # Solo herramientas de desarrollo
./install.sh --emb     # Solo toolchain embedded
```

---

## 🔧 Herramientas incluidas

### Hardware (EDA & Programación)
| Herramienta | Versión | Método | Notas |
|---|---|---|---|
| **KiCad** | 10.0.x | PPA oficial | PCB y esquemáticos |
| **OpenOCD** | apt | apt | Debug JTAG/SWD |
| **Arduino IDE 2** | 2.3.x | AppImage oficial | Boards Arduino/ESP |
| **Vivado** | — | Manual (AMD) | Requiere cuenta AMD |

### Desarrollo
| Herramienta | Método | Notas |
|---|---|---|
| **VS Code** | Repo Microsoft | Con extensiones embedded |
| **Docker** | Repo Docker Inc. | Sin sudo configurado |
| **Git** | apt + config | SSH para GitHub incluido |
| **JetBrains Toolbox** | Oficial | Gestiona CLion, etc. |
| **Android Studio** | Via Toolbox | — |

### Embedded & Debug
| Herramienta | Método | Notas |
|---|---|---|
| **ARM GCC Toolchain** | apt | Compilación Cortex-M |
| **STM32CubeIDE** | Manual (ST) | Requiere cuenta ST |
| **MATLAB** | Manual (MathWorks) | Requiere licencia |
| **GDB Multiarch** | apt | Debug remoto |
| **stlink-tools** | apt | CLI para ST-Link |
| **sigrok / PulseView** | apt | Analizador lógico |
| **minicom / picocom** | apt | Monitor serie |

---

## 🐧 Compatibilidad

| Distro | Estado | Package Manager |
|---|---|---|
| Ubuntu 24.04 / 26.04 | ✅ Probado | apt |
| Debian 12+ | ✅ Compatible | apt |
| Fedora 40+ | 🟡 Scripts incluidos, no probado | dnf |
| Arch Linux | 🟡 Scripts incluidos, no probado | pacman |

---

## 📋 Bitácora de instalación

Ver [`docs/ubuntu-setup.md`](./docs/ubuntu-setup.md) para el registro completo de decisiones tomadas durante la configuración inicial.

---

## 📝 Convención de commits

| Prefijo | Uso |
|---|---|
| `feat` | Nuevo script o herramienta |
| `fix` | Corrección de bug en script |
| `docs` | Actualización de documentación |
| `refactor` | Mejora de estructura sin cambio funcional |
| `chore` | Mantenimiento general |

---

Desarrollado como parte de la formación en UNIT Electronics — I+D.
