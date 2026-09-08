# Diretrizes Internas — Aetherion Forge

Documento obrigatório. Todas as contribuições neste repositório devem seguir estas regras sem exceção.

---

## 1. Clean Code e Modularização

- Todo código deve ser **limpo, legível e comentado** o suficiente para que outro desenvolvedor entenda a intenção sem adivinhar.
- Organize o projeto em **módulos lógicos** (sistemas, entidades, UI, áudio, física, persistência, etc.). Evite arquivos “faz-tudo”.
- Funções e classes devem ter **uma responsabilidade clara**. Extraia lógica repetida; não copie e cole.
- Nomes devem descrever o que o código faz. Evite abreviações obscuras e variáveis de uma letra fora de loops curtos.
- Comentários explicam **porquê** (decisões, restrições, trade-offs), não o óbvio do *o quê*.
- Prefira APIs pequenas e estáveis entre módulos. Contratos explícitos valem mais do que acoplamento implícito.

## 2. Gestão de Performance

- Escreva código **otimizado o bastante** para o alvo da plataforma: evite travamentos, stuttering e picos de frame time.
- Não aloque memória de forma desenfreada em loops de jogo (update/render). Reutilize buffers, pools e estruturas já existentes quando fizer sentido.
- Fique atento a **vazamentos de memória (memory leaks)**: listeners, timers, handles de GPU/áudio, arquivos e referências circulares devem ser liberados no ciclo de vida correto.
- Profile antes de micro-otimizar. Corrija gargalos reais (alocação, I/O, overdraw, queries caras), não “otimize no escuro”.
- Operações pesadas (I/O, parsing, geração procedural grande) não devem bloquear o thread principal sem necessidade.

## 3. Tratamento de Erros

- Rotinas críticas (carregamento de assets, save/load, rede, parsing, inicialização da engine) **devem validar entradas** e tratar exceções/falhas de forma explícita.
- Falhas recuperáveis devem degradar com graça (fallback, log, estado seguro). Falhas irrecuperáveis devem falhar de forma **clara e rastreável**, nunca silenciosa.
- Nunca engula erros vazios (`catch` vazio, `except: pass` sem registro). Sempre registre contexto útil para diagnóstico.
- Valide dados externos (arquivos, JSON, input do jogador, respostas de API) antes de usá-los.
- Estados inválidos do jogo devem ser detectados cedo (asserts/invariantes em desenvolvimento).

## 4. Controle de Versão

- Commits **pequenos, atômicos e com mensagens claras** descrevendo o que mudou e por quê.
- Padrão sugerido de mensagem: `tipo(escopo): resumo` — exemplos: `feat(player): dash com cooldown`, `fix(save): não corromper slot ao falhar I/O`.
- Não misture refatoração grande com feature nova no mesmo commit.
- Não commite artefatos gerados, caches, builds locais ou arquivos de IDE sem necessidade.
- O histórico deve permitir entender a evolução do jogo sem abrir o diff em cada commit.

## 5. Segurança

- **Nunca** exponha o token do GitHub, chaves de API, senhas ou qualquer credencial em scripts, código-fonte, comentários, logs ou commits.
- Credenciais vivem apenas em variáveis de ambiente ou mecanismos secretos do provedor — nunca em arquivos versionados.
- Se um segredo vazar, **revogue imediatamente** e gere outro. Não “confie” que um force-push apaga o histórico público.
- Não registre dados pessoais de jogadores além do necessário. Sanitize logs.
- Dependências e assets de terceiros devem ter origem confiável e licença compatível.

---

## Aplicação

Estas diretrizes são o contrato interno do **Aetherion Forge**. Pull requests, features e refatorações que as violem devem ser corrigidas antes de entrar na branch principal.


---

## 6. Arte, modelagem, VFX e animação

Ver documento complementar obrigatório: [`regras/diretrizes-arte.md`](diretrizes-arte.md).

Resumo: conteúdo 100% autoral; **proibida** a Toolbox do Roblox; modelagem sênior e otimizada; VFX/animação com TweenService, Particles, Beams, Trails e CFrame fluidos.

