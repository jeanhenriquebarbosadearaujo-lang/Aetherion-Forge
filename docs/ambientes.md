# Ambientes — Aetherion Forge

Documento operacional. Sem credenciais.

## Mapeamento (IDs corretos)

Os IDs oficiais informados inicialmente estavam **invertidos**. A tabela abaixo é a fonte da verdade.

| Ambiente | Experiência | Universe ID | Place ID (root) | Papel |
|---|---|---|---|---|
| **Testes (Dev/Staging)** | Novo Projeto - Testes | `3418934068` | `9095588296` | Desenvolvimento e validação |
| **Oficial (Produção)** | Novo Projeto (Oficial) | `6569886344` | `100835305649908` | Somente após autorização |

Dono de ambas: `users/3390155079`. Visibilidade: PRIVATE. Server size: 50.

> Place ID `6569886344` **não** é o jogo oficial. Esse número é o Universe ID da produção. O place `6569886344` pertence a outra experiência (`Asdfqwreyu's Place`) e **não deve ser modificado**.

## Fluxo de trabalho (obrigatório)

1. Implementar código, mapa e mecânica **somente** no Ambiente de Testes.
2. Validar no place `9095588296`.
3. **Nada** vai para Produção sem autorização prévia explícita.
4. Versionar scripts e modelos neste repositório **antes** de publicar no Roblox.
5. Nunca commitar API Keys, PATs ou cookies.

## Estado após limpeza (2026-09-08)

Ambos os places foram publicados com o baseplate padrão zerado:

- Workspace: `Terrain`, `Camera`, `Baseplate` (512×16×512), `SpawnLocation`
- ServerScriptService / ReplicatedStorage / ServerStorage / StarterGui: vazios
- Scripts legados do Dev (`Vivo`, `Construtor`) removidos

Arquivo-fonte do place limpo: [`places/Baseplate.rbxlx`](../places/Baseplate.rbxlx)

Versões publicadas nesta limpeza:

- Dev: versão **175**
- Produção: versão **48**
