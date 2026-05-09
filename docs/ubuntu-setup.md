# Bitácora de instalación — Ubuntu 26.04 LTS

> Registro de decisiones técnicas durante la configuración del entorno de desarrollo embedded.
> Formato: qué hice, por qué lo hice, qué aprendí.

---

## 2026-05-09 — Instalación base del sistema

**Contexto:** Dual boot Windows/Ubuntu en SSD de 500 GB asignados a Ubuntu.

**Decisiones tomadas:**
- Ubuntu 26.04 LTS elegido por soporte de 5 años y compatibilidad con herramientas de UNIT.
- Partición de 500 GB sin LVM para simplificar (entorno de aprendizaje, no producción).

---

## 2026-05-09 — KiCad 10.0.2

**Problema:** Ubuntu 26.04 trae KiCad 9.0.8 en sus repos oficiales.

**Opciones evaluadas:**

| Opción | Pros | Contras |
|---|---|---|
| AppImage oficial | Sin dependencias, portable | Sin integración con apt, actualizaciones manuales |
| PPA oficial KiCad | Integrado con apt, auto-actualizable | Depende de que el PPA se mantenga |
| Repos base Ubuntu | Sin config extra | Versión 9.0.8 desactualizada |

**Decisión:** PPA oficial `ppa:kicad/kicad-10.0-releases`.

**Comandos ejecutados:**
```bash
sudo add-apt-repository ppa:kicad/kicad-10.0-releases       #Actualizar en caso de nueva version 
sudo apt update
sudo apt install kicad
```

**Resultado:** KiCad 10.0.2 instalado (build 2026-05-08).

**Aprendizajes:**
- `--install-recommends` es redundante en Ubuntu (activo por defecto), útil en Debian.
- PPAs se nombran por versión mayor — cuando salga KiCad 11 habrá que agregar nuevo PPA.
- `apt-cache policy <paquete>` muestra de qué fuente viene cada paquete instalado.

**Para actualizar en el futuro:**
```bash
sudo apt update && sudo apt upgrade
# Parches menores (10.0.x) llegan automáticamente
# Para KiCad 11: sudo add-apt-repository ppa:kicad/kicad-11.0-releases
```

---

<!-- 
Plantilla para próximas entradas:

## YYYY-MM-DD — [Herramienta]

**Problema:** 

**Opciones evaluadas:**

**Decisión:** 

**Comandos ejecutados:**
```bash

```

**Resultado:** 

**Aprendizajes:**

-->
