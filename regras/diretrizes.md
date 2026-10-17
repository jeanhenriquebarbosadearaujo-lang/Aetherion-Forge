# Diretrizes — Aetherion Forge

Contrato interno. O agente lê isto **antes** de publicar qualquer coisa.

## 1. Código

- Modular, comentado no *porquê*, não no óbvio.
- Uma responsabilidade por módulo. Sem arquivo faz-tudo.
- Validar entrada de remoto, DataStore e jogador. Falha = `{ ok = false, err = "..." }`, nunca silêncio.
- Commits pequenos: `tipo(escopo): resumo`.
- Sem Toolbox 3D/GUI. SFX de engine/Toolbox só se a diretriz de arte permitir.
- Luau com tipos onde ajudar. Não quebrar script com replace cego em nome de função (`paintSky` ≠ `pcall(paintSky)` no `function`).

## 2. Publicação

- **Testes primeiro:** universe `3418934068`, place `9095588296`.
- **Oficial** (`6569886344` / place `100835305649908`) só com autorização prévia, na mesma frase.
- Nunca publicar no place `6569886344` (não é o oficial).
- Não reconstruir o place inteiro de memória e mandar pro ar — isso apaga o jogo. Baixar o Test vivo, patch cirúrgico, publicar.
- Exceção: o dono pediu **zerar**. Aí sim place mínimo (baseplate + spawn).
- Uma mudança visível por publicação quando possível (mapa **ou** HUD **ou** economia).
- Depois de publicar: o jogador precisa **sair do servidor e entrar de novo** (cache).

## 3. UI / mobile

- Scale only. `UIAspectRatioConstraint`. Safe-zone (notch).
- Fechar só no controle de fechar. Ícone **X**, não texto. Builder Sans.
- Textos/botões não compartilham o mesmo Y (não sobrepor).
- Borda ouro de painel = **imagem** (`GoldFrame`), não `UIStroke`. Tile do fundo **embaixo** da borda.
- Não parentear GoldFrame sob `UIPadding`.

## 4. Agente (Arena)

- Responder em **português**.
- Não pedir permissão para ações de Teste; Produção sim.
- PAT / API key: só na memória do chat, ~10 min. **Nunca** arquivo, **nunca** commit. 401 → não reintentar essa chave.
- GitHub: este repo. Sem PAT → não inventar push.
- Extra fetch em loop (catálogo Roblox, fórum) cancela o turno. Não começar busca de catálogo.
- Sem viewport de Studio. 3D: o dono confirma com print / F9. Não adivinhar o que ele está vendo.

## 5. Dono

- Username `hack_275626`, UserId `3390155079`.
- Hierarquia de staff (quando existir): OWNER / DEPUTY OWNER / ADMIN / STAFF / HELPER.

## 6. Segurança

- Zero segredos no git.
- DataStore e remotes: validar `Player`, cooldown, tipos.
