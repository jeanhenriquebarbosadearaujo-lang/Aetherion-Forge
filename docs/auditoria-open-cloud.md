# Auditoria de escopo — Open Cloud API Key

Data: 2026-09-08  
Método: `POST https://apis.roblox.com/api-keys/v1/introspect` + cruzamento com Testes e Oficial.  
**Nenhuma credencial neste arquivo.**

## Identidade da chave (sem segredo)

| Campo | Valor |
|---|---|
| Nome no dashboard | Exército Brasileiro - Api-Key |
| authorizedUserId | 3390155079 (mesmo dono das duas experiências) |
| enabled | true |
| expired | false |
| expirationTimeUtc | `null` (a chave no dashboard não tem expiry; o token de sessão colado no chat é que vive ~10 min) |
| Restrição por experiência | **Não.** Quase todos os escopos de universe usam `universeIds: ["*"]` |

## Cobertura dos ambientes

| Ambiente | Universe | Place | Coberto pela key? |
|---|---|---|---|
| Testes | 3418934068 | 9095588296 | Sim (`*`) |
| Oficial | 6569886344 | 100835305649908 | Sim (`*`) |

A key **não** está limitada a esses dois universes: qualquer experiência do usuário (e futuras) herda os mesmos scopes. Operacionalmente isso libera Testes e Oficial; em segurança aumenta a superfície. Não bloqueia o fluxo atual.

## Serviços Open Cloud LIBERADOS

Escopos efetivos (45). Operações entre parênteses.

### Universes, places, instâncias, publicação
- `universe` (read, write) — `*`
- `universe.place` (read, write) — `*`
- `universe-places` (write) — publicação de `.rbxl` / `.rbxlx` — `*`
- `universe.place.instance` (read, write) — DataModel via Open Cloud — `*`
- `universe.place.luau-execution-session` (read, write) — `*`
- `legacy-universe` (manage)
- `legacy-team-collaboration` (manage)

### Dados
- `universe-datastores.control` (create, delete, list, snapshot) — `*`
- `universe-datastores.objects` (create, delete, list, read, update) — universe `*`
- `universe-datastores.versions` (list, read) — universe `*`
- `universe.ordered-data-store.scope.entry` (read, write) — `*`
- `memory-store` (flush, get) — `*`
- `memory-store.sorted-map` (read, write) — `*`
- `memory-store.queue` (add, dequeue, discard) — `*`
- `universe.secret` (read, write) — `*`

### Live ops / social da experiência
- `universe-messaging-service` (publish) — `*`
- `universe.user-restriction` (read, write) — `*`
- `universe.event` (read, write)
- `universe.analytics` (read) — `*`
- `universe.thumbnail` (read, write)
- `user.user-notification` (write) — `*`
- `universe.subscription-product.subscription` (read)

### Monetização e assets
- `asset` (read, write) — groups `*`, users `*`
- `asset-permissions` (write)
- `legacy-asset` (manage)
- `developer-product` (read, write) — `*`
- `legacy-developer-product` (manage)
- `game-pass` (read, write) — `*`
- `legacy-game-pass` (manage)
- `legacy-badge` (manage)
- `legacy-universe.badge` (manage-and-spend-robux, write)
- `creator-store-product` / `creator-store-save` (read, write)
- `thumbnail` (read)

### Ads, grupos, usuário
- `ad.billing` (read)
- `ad.campaign` (read, write)
- `group` / `group-forum` (read, write)
- `legacy-group` (manage)
- `legacy-user` (manage)
- `user.advanced` / `user.inventory-item` / `user.social` (read)
- `legacy-universe.following` (read, write)
- `studio-evaluations` (create)

## Limitações / lacunas (registradas)

Não faltou permissão para o fluxo de desenvolvimento do jogo (ler/escrever place, instâncias, publicar mapa, Luau Execution, DataStores) em **Testes nem Oficial**.

Limitações reais a respeitar:

1. **Sem restrição de universe** — a key vale para `*`. Não usar isso como desculpa para publicar em Oficial sem autorização de fluxo (`docs/ambientes.md`).
2. **Token de sessão curto** — o valor colado no chat expira ~10 min; a key do dashboard está `expired: false` e sem `expirationTimeUtc`.
3. **Escopos que não aparecem no introspect** (tratar como ausentes até prova em contrário): matchmaking API, experiments/configs explícitos, billing de ads em write. Se uma tarefa exigir isso, registrar aqui e seguir só o permitido — sem perguntar.
4. **Probes de rota** (não são falta de scope): listagem `badges/v1` 404 de path; `memory-store/sorted-maps` 404 de path; `assets/v1/assets/1` 404 de recurso inexistente. Os scopes `legacy-badge`, `memory-store.*` e `asset` estão presentes.
5. **Nunca versionar a API Key.** Só memória de sessão.

## Política interna de execução

Antes de qualquer chamada Open Cloud:

1. Conferir este arquivo + `docs/ambientes.md`.
2. Se o scope existir e o ambiente for Testes → executar.
3. Se o ambiente for Oficial → executar só com autorização prévia de fluxo (exceto a limpeza já feita).
4. Se o scope não existir → **não perguntar**; anotar a lacuna neste documento e entregar o que for possível.

Última auditoria: 2026-09-08.
