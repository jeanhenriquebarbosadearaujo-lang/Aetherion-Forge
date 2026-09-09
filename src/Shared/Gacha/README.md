# Gacha (Rolls)

Sorteio autoritativo no servidor. Cartas originais no gênero horse-girl / trainer.
Ilustrações de UI 100% programadas (`Portrait.lua`). Sem Toolbox.

## Módulos

| Arquivo | Runtime | Papel |
|---|---|---|
| `src/Shared/Gacha/Catalog.lua` | ModuleScript | Cartas, raridades, chances |
| `src/Shared/Gacha/Portrait.lua` | ModuleScript | Ilustração vetorial da carta |
| `src/Server/Gacha/GachaService.server.lua` | Script | RNG + cooldown + inventário de sessão |
| `src/Client/Gacha/GachaClient.client.lua` | LocalScript | Menu, Girar, Auto-Roll |
| `src/Client/PreviewHub/Hub.client.lua` | LocalScript | Slot #1 = Girar / Rolls |

Remote: `ReplicatedStorage.AetherionRemotes.RollOnce` (RemoteFunction).
