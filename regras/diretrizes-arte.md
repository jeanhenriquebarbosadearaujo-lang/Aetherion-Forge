# Arte, mapa, VFX, UI

- **3D, animação e VFX autorais.** Toolbox **proibida** (exceção: SFX, se combinado).
- GUI/HUD gerada no código, não importada da Toolbox.
- Superfícies de mapa (material/cor de Part) podem usar materiais nativos do engine.
- Animação: TweenService, CFrame, Motor6D. VFX: ParticleEmitter, Beam, Trail.
- Forma: evitar só cubo e só bola. Squircle / estádio / laje com canto quando fizer sentido.
- Não espalhar “tema ouro” em tudo. Ouro é acento.
- Iluminação (Lighting + Atmosphere + ColorCorrection) faz parte do mapa, não é afterthought.
- Performance: poucos emitters, partes ancoradas, sem overlap de colisão no mesmo volume (jitter).
