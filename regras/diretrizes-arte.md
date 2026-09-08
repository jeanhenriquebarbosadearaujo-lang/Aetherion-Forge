# Diretrizes de Produção — Modelagem, VFX e Animação

Obrigatórias em todo o Aetherion Forge. Complementam `regras/diretrizes.md`.

## 1. Criação autoral (100%)

- Todo modelo 3D, animação e efeito visual (VFX) deve ser **original**: construído via código Luau, geração procedural ou recursos próprios versionados neste repositório.
- **Proibido** usar ativos prontos da Toolbox / Oficina do Roblox (modelos, meshes, particles, animations, audio da loja, kits, etc.).
- **Proibido** importar packs de terceiros sem autoria clara e licença compatível. Em caso de dúvida, não entra.
- Texturas e decals: gerar no próprio pipeline (procedural, ImageLabel/ImageHandleAdornment, EditableImage quando fizer sentido) ou criar originalmente. Sem IDs de Toolbox.

## 2. Modelagem 3D — padrão sênior

- Proporções corretas, silhueta legível, hierarquia limpa (`Model` → peças nomeadas).
- Detalhe onde o jogador olha; simplificar o que está longe / repetido.
- **Otimização de geometria e partes:** o mínimo de `BasePart`/`MeshPart` que entregar a forma. Sem partes fantasma, sem união desnecessária, sem “part spam”.
- Preferir CSG/unions só quando o custo de runtime compensar; documentar o porquê.
- Collision: hitboxes simples (`CanCollide`/`CanQuery` conscientes). Visual detalhado ≠ collider detalhado.
- Anchored / Massless / NetworkOwnership explícitos em runtime. Nada de peças soltas gerando physics lixo.
- Nomeação consistente (`EB_Arma_Fuzil_Corpo`, não `Part23`).

## 3. VFX e animações

- TweenService para motion UI e transforms interpolados (easing explícito, sem magia).
- ParticleEmitters, Beams e Trails com budgets: taxa, lifetime, enabled só quando visível.
- CFrame para kinematic/IK leve, recoil, câmera e attachments de VFX. Sem animações “teleportadas”.
- Animações fluidas: in/out, anticipation, follow-through. Loops sem costura visível.
- Desligar emitters e cancelar tweens no `Destroy`/saída de estado (sem memory leak de VFX).
- Nunca depender de animação da Toolbox. Keyframes próprios ou procedural.

## 4. Performance (cruzado com diretrizes gerais)

- Orçamento de partes por asset deve caber em servidor cheio (50 players no place atual).
- VFX: pooling quando o efeito se repete (muzzle, impacto, fumaça).
- Nada de criar centenas de partes por segundo sem reciclar.

## Aplicação

PR de mapa, arma, personagem, veículo ou efeito que viole isto não entra na branch principal.
