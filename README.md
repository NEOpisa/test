# Birfree

Área de trabalho da Neovanguard: shell Qt/QML própria sobre KWin/Wayland.
A versão 1.0 está em preparação. Estado registrado em 19/10/2026.

## Base própria na 1.0

A migração para BWin, birfree-workspace, gigamana, bscreen e bscreenlocker
começou a partir do Plasma 6.7.5, preservando histórico, créditos e licenças.
Os cinco clones e receitas estão preparados. O repo local `birfree-kde`
contém os 153 pacotes KDE/Qt desta máquina, conferidos com o Archive de 01/10.
**Os forks ainda não foram compilados em chroot nem instalados.** A sessão
real e os mirrors continuam na base anterior até o teste A/B.

As Configurações são as do Sistema (KDE), com a página Birfree na frente
(papel de parede, cor, janelas, vidro, barra e dock, comportamento e apps
X11 pelo XWayland). O Bcontrol do teste 5.5 foi retirado. O Birfree é só
Wayland.

As origens, licenças, comandos de build, limites e rollback estão no
[guia da base](base/README.md). A trava nova será só de KDE/Qt, com o restante
do Arch nos mirrors normais. Dois monitores estão fora do plano.

## Baixar e instalar a versão pública de teste

O canal público é https://github.com/NEOpisa/test.
A árvore de desenvolvimento NEOpisa/birfree é privada.

A pré-release mais recente é
[v1.0.0-test.6](https://github.com/NEOpisa/test/releases/tag/v1.0.0-test.6)
(patch de 20/10), com os pacotes prontos do commit 6b47fa0f. Roteiro de retomada: [RETOMAR.md](RETOMAR.md).

Os comandos abaixo valem para o arquivo da pré-release mais recente.

Em Arch Linux x86_64, como usuário normal:

```sh
curl -fL -O https://github.com/NEOpisa/test/releases/download/v1.0.0-test.6/Birfree-1.0.0-x86_64.tar.gz
curl -fL -O https://github.com/NEOpisa/test/releases/download/v1.0.0-test.6/SHA256SUMS
sha256sum --check SHA256SUMS
tar -xf Birfree-1.0.0-x86_64.tar.gz
cd Birfree-1.0.0-x86_64
./instalar-birfree --mostrar
./instalar-birfree
```

O arquivo inclui os instaladores atualizados e os pacotes completos, sem
precisar compilar. O fluxo padrão instala ou atualiza a DE na base atual,
confere a ABI de KWin/Qt e não troca mirrors, repositórios ou outros ambientes.
`./instalar-birfree --atualizar` continua disponível para instalações antigas.
Use `--mostrar` para conferir os pacotes antes de instalar.

A migração antiga fica disponível explicitamente em `--migrar`, com simulação
em `--simular` e reversão em `--desfazer`. Ela modifica o sistema e permanece
separada da atualização normal da DE. Depois de instalar, salve o trabalho,
saia e entre na sessão Birfree pelo SDDM.

Os binários foram compilados com KWin 6.7.5-1 e Qt 6.11.2-3.
A API dos efeitos do KWin exige recompilação quando houver incompatibilidade.
Ainda falta validar a instalação completa em uma máquina limpa.

## Desenvolvimento local

Fontes: `/home/neo/Projetos/birfree`.

- `./instalar.sh`: compila e instala a DE completa sobre a base KDE atual,
  incluindo menu (com o gerenciador de apps), sessão, estilos e efeitos.
- `./instalar.sh --base-forks`: compila contra os cinco forks já instalados.
  Prepare a base conforme [o guia](base/README.md).
- `./instalar.sh --gerar-pacotes`: gera os dois pacotes sem sudo nem instalação;
  as dependências de compilação precisam estar instaladas.
- `./instalar.sh --teste`: compila no prefixo local e abre uma sessão em janela.
- `./instalar.sh --sem-sddm`: usa a entrada Breeze; `--sddm` retorna à Birfree.
- `./instalar.sh --plymouth`: oferece configurar Plymouth e refazer o initramfs.

Antes de compilar em outra máquina, prepare as dependências declaradas em
`pacote/PKGBUILD` e `birfree-icons/pacote/PKGBUILD`. O script usa `--nodeps`;
a instalação posterior pelo pacman não supre bibliotecas ausentes na compilação.
Execute como usuário normal, com sudo disponível.

## Implementado e pendente

Shell com barra, dock, menu/busca, central, notificações, bandeja, menu global,
área de transferência e integração com KWin; sessão e recuperação de quedas;
Birfrost para Qt/GTK e decoração; cursor, marca, wallpapers com créditos,
SDDM, boas-vindas, português/inglês e escolha de accent.

O [changelog](CHANGELOG.md) detalha as alterações. O [plano](PLANO-1.0.txt)
é o checklist de conclusão: sessão real, forks e desfoque GTK via BWin seguem
pendentes; dois monitores estão fora da 1.0. Os ícones
continuam derivados do Fluent com licença e créditos; redesenho foi adiado.
A numeração 1.0.0 dos pacotes não representa lançamento estável.

A distro integra estes pacotes em uma árvore separada:
[estado da distro](../Neovanguard/distro/documentation/estado-local-2026-10-17.md).

## Animações das janelas

Desde o teste 2: efeitos da comunidade KDE incluídos no KWin. Scale abre e
fecha janelas; Magic Lamp minimiza/restaura; Wobbly Windows deforma as janelas
ao arrastar. O Condense fica desligado. A sessão instalada e os testes
aninhados usam os mesmos padrões.

## Instaladores

`so-birfree.sh` é a base canônica da migração. Na árvore fonte chama
`instalar.sh` para compilar; no arquivo público chama `instalar-pacotes`
para instalar os binários. O empacotador da distro copia essa mesma base,
sem manter uma segunda implementação da migração.

Regressões do fluxo: `python3 tests/test_instalador.py` e
`python3 tests/test_base_repos.py` (sem alterar o sistema). A árvore nova
exige os repositórios locais completos para migrar; o arquivo público test.3
mantém o fluxo Archive descrito acima. Ainda falta validar a migração completa
em uma VM limpa.
