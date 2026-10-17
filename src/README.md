# src

Código do jogo. Ainda **não** há pipeline Rojo automático: o agente publica no Test a partir destes arquivos.

## Mundo (fatia 1)

`World.server.lua` é o que **roda** no place (um Script só). Os ModuleScripts ficam para o heightmap depois — v237 com Folder+require não gerou ilha.

| Arquivo | Instância | Papel |
|---|---|---|
| `World.server.lua` | Script `World` em ServerScriptService | Ilha Fill* + lighting + ciclo. **Publicar este.** |
| `Bootstrap.server.lua` / `Config.lua` / `Heightmap.lua` / `TerrainGen.lua` / `LightingRig.lua` | — | Próximo passo (ruído). Não injetar até o chão Fill* estar ok. |

Hierarquia no place:

```
ServerScriptService
  World     (Script, RunContext Server)
```
