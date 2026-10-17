# Aetherion Forge

Repositório de trabalho do jogo. Fonte da verdade para **regras**, **estado** e o código.

Place de Testes: ainda **v236 vazio** até o agente publicar a fatia 1. Código da fatia já está em `src/`.

Direção: **survival** no espírito de **Rust**.

## Fatia 1 (em código, aguardando publish)

Ilha em estádio, mar, lighting profissional, ciclo dia/noite (~12 min). Sem HUD, craft ou PvP.

## Documentos

| Arquivo | Para quê |
|---|---|
| [`src/README.md`](src/README.md) | Como o código entra no place |
| [`regras/diretrizes.md`](regras/diretrizes.md) | Como o agente e qualquer contribuidor devem trabalhar |
| [`regras/diretrizes-arte.md`](regras/diretrizes-arte.md) | 3D, UI, VFX, som |
| [`notas/estado.md`](notas/estado.md) | O que está no ar agora (IDs, versão, o que NÃO existe) |
| [`notas/proximo.md`](notas/proximo.md) | Direção do rebuild |
| [`notas/nao-fazer.md`](notas/nao-fazer.md) | Armadilhas já pagas |

## Ambientes

| | Universe | Place |
|---|---|---|
| **Testes** | `3418934068` | `9095588296` |
| **Oficial** | `6569886344` | `100835305649908` |

Tudo nasce em Testes. Produção só com autorização explícita do dono.

Place ID `6569886344` **não** é o jogo oficial (é o Universe ID da produção). Não publicar nesse número.

## Segurança

Nunca commitar PAT, API key, cookie ou `.env`. Segredo que vazar: revogar, não “apagar o commit”.
