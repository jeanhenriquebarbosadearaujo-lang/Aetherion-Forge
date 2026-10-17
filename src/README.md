# src

Código do jogo. Ainda **não** há pipeline Rojo automático: o agente publica no Test a partir destes arquivos.

## Mundo (fatia 1)

`Server/World/` — ilha, iluminação, ciclo. Sem HUD, inventário, craft ou PvP.

| Arquivo | Instância | Papel |
|---|---|---|
| `Bootstrap.server.lua` | Script `Bootstrap` | Entrada. Limpa baseplate, gera, spawna. |
| `Config.lua` | ModuleScript | Único lugar de números. |
| `Heightmap.lua` | ModuleScript | Altura e material por (x,z). |
| `TerrainGen.lua` | ModuleScript | WriteVoxels em chunks + spawn. |
| `LightingRig.lua` | ModuleScript | Lighting + Atmosphere + ciclo. |

Hierarquia no place:

```
ServerScriptService
  World
    Bootstrap          (Script)
    Config             (ModuleScript)
    Heightmap          (ModuleScript)
    TerrainGen         (ModuleScript)
    LightingRig        (ModuleScript)
```

Seed fixa = a mesma ilha em todo servidor. `Config.revision` sobe quando a ilha deve nascer de novo.
