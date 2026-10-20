# Birfree — TESTE 6 (patch de 20/10)

Pré-release experimental para **Arch Linux x86_64**.

## Baixar

[Baixar Birfree-1.0.0-x86_64.tar.gz](https://github.com/NEOpisa/test/releases/download/v1.0.0-test.6/Birfree-1.0.0-x86_64.tar.gz)

O arquivo inclui os pacotes prontos, os instaladores, licenças, versões,
checksums e os fontes desta versão. **Não compila nada no seu computador**:
só baixa e instala. Extraia em uma pasta nova; não misture com testes
anteriores.

## Já tem o Birfree? Atualize

```sh
curl -fLO https://raw.githubusercontent.com/NEOpisa/test/main/atualizar-birfree
chmod +x atualizar-birfree
./atualizar-birfree
```

O script baixa o teste mais novo, confere o SHA-256 e instala só os pacotes
do Birfree (não migra, não troca repositórios, não mexe nas sessões).
Depois, salve o trabalho, saia da sessão e entre de novo em **Birfree**.

Com o arquivo já extraído, `./instalar-birfree` faz a mesma atualização.
A migração completa do sistema é `./instalar-birfree --migrar`.

## O que há de novo no patch do teste 6 (20/10)

O link e o `atualizar-birfree` são os mesmos: quem já tem o Birfree só roda
o `./atualizar-birfree` de novo.

- **Instalação sem compilar, como era antes.** A primeira versão do teste 6
  compilava tudo no seu computador e podia parar com erro de compilação.
  Agora o arquivo volta a trazer os pacotes prontos: baixa, confere e instala.
  Se você ficou com uma compilação pela metade, nada do Birfree instalado foi
  mudado; os restos ficam em `~/.cache/birfree/compilacoes/` e podem ser
  apagados.
- **Papel de parede nítido.** A área de widgets (uma camada transparente do
  tamanho da tela) recebia o desfoque do vidro inteiro e deixava o papel de
  parede embaçado.
- **Widgets funcionando.** A galeria não conseguia adicionar nenhum widget;
  agora adiciona na tela em que foi aberta.
- **Relógio melhor.** Modelo novo **Analógico** (marcas, ponteiro dos segundos
  na cor de destaque com movimento suave, dia no mostrador); a hora da linha
  de baixo dos modelos Spaced e Minimal na cor de destaque; barrinha dos
  segundos no modelo Glass.
- **Luz do teclado.** Controle novo na central (Meta+S) e no painel de energia,
  que só aparece se o computador tiver teclado com luz (ThinkPad e outros):
  Desligada, Baixa, Alta. O Birfree lembra o último nível e o devolve ao entrar.
- **Konsole translúcido sem fantasma.** Com o fundo semitransparente, o texto
  antigo ficava uma linha abaixo do novo no chat das IAs de terminal.
- **Só Wayland.** O `birfree-x11` saiu. Os apps X11 continuam abrindo pelo
  XWayland, e a página Apps X11 das Configurações continua. A migração
  (`--migrar`) agora também tira o `kwin-x11` e a sessão X11 do Plasma.

Pacotes: `birfree 1.0.0.r94.g6b47fa0f-1` e
`birfree-icons 1.0.0.r18.ge4b55699-1`, compilados contra KWin 6.7.5-1 e
Qt 6.11.2-3 (o instalador recusa outra versão sem remover nada).

## O que havia de novo no teste 6 (primeira versão)

- Correções gerais do vidro: campos de edição sobre listas, ícones e tabelas
  cobrem o texto antigo ao renomear, incluindo os cantos do campo.
- Menus Birfree no launcher, nas tarefas da dock, nas áreas de trabalho,
  no menu global e na bandeja: vidro, atalhos, checks, submenus, teclado e
  atualização das ações enquanto o menu está aberto.
- Área de widgets própria: galeria, edição, relógio e Tocando agora, com
  suporte a widgets do KDE. **Nenhum widget vem ligado por padrão.**
  Botão direito na área de trabalho, na barra ou na dock → **Adicionar
  widgets…** ou **Editar área de trabalho**.

## O que havia de novo no patch do 5.5 (19/10)

- As Configurações voltam a ser as Configurações do Sistema (o Bcontrol saiu),
  com o cartão **Apps X11** na página Birfree.
- Sessão no menu redesenhada (botões redondos no rodapé, segundo clique para
  sair, reiniciar e desligar).
- Gerenciador de apps no menu: novo atalho, editar, restaurar, tirar do menu
  (seção **Ocultos**) e desinstalar (pacote, Flatpak ou AppImage).

## O que havia de novo no teste 5.5 (primeira versão)

- **Sessão dentro do menu.** O botão Sessão saiu da barra superior e foi para
  o rodapé do menu de aplicativos: um clique expande Bloquear, Suspender,
  Sair, Reiniciar e Desligar ali mesmo. Sair, reiniciar e desligar pedem um
  segundo clique.
- **Bcontrol**, Configurações próprias (retirado no patch).
- **Apps X11:** escala e leitura do teclado nas Configurações (o comando
  `birfree-x11` desse teste saiu no teste 6: o Birfree é só Wayland).
- Dock em pé, à esquerda ou à direita, e correções de sessão, traduções e
  estilo da árvore atual.
- Os fontes dos cinco forks KDE 6.7.5 (BWin, birfree-workspace, gigamana,
  bscreen, bscreenlocker) vão no arquivo, mas **ainda não são instalados**:
  a base continua sendo o KWin/Plasma do Arch.

Pacotes: `birfree 1.0.0.r78.gdd6bf20b-1` e
`birfree-icons 1.0.0.r16.gdd6bf20b-1`, compilados contra KWin 6.7.5-1 e
Qt 6.11.2-3 (o instalador recusa outra versão sem remover nada).

## O que havia de novo no teste 5

**Instalação que aguenta o Arch Archive lento.** No teste 4 a migração
podia parar em

```text
error: failed retrieving file 'mesa-…' from archive.archlinux.org : Operation too slow. Less than 1 bytes/sec transferred the last 10 seconds
✗ o pacman -Syyu na data travada falhou; nada foi removido
```

O Archive é um servidor só e engasga com muitos downloads ao mesmo tempo.
Agora o `so-birfree.sh` baixa dele de 3 em 3 e tenta até 5 vezes (o que
já baixou fica no cache). Se parou assim no teste 4, nada foi removido:
baixe o teste 5 e rode a instalação de novo — o backup do mirrorlist
original continua valendo para o `--desfazer`.

Os pacotes são os mesmos do teste 4; só o `so-birfree.sh` mudou.

## O que havia de novo no teste 4

**Só escuro.** Nada fica branco, nem os navegadores:

- A cada login, um esquema de cores claro volta para o Birfree (o accent
  fica). Com a sessão aberta, a shell desfaz na hora e avisa.
- Apps GTK e Flatpak escuros (Adwaita escuro nos Flatpak).
- Chrome, Chromium e Brave com interface e páginas escurecidas.
- Firefox (nativo e Flatpak) com o Dark Reader instalado pela política,
  tema escuro e PDF em fundo escuro. Feche e abra o navegador depois de
  entrar na sessão.

**Configurações do Birfree em cartões.** Configurações › Birfree virou um
painel com Papel de parede, Cor de destaque, Janelas, Vidro, Barra e dock e
Comportamento:

- Papel de parede: preencher, ajustar, esticar, centralizar ou lado a lado;
  um papel para cada monitor; troca automática (5 min, 15 min, 1 h, 1 dia,
  em ordem ou aleatória) pela pasta Birfree Wallpapers.
- Janelas: botões no padrão Birfree, todos à esquerda (✕ ─ ▢) ou todos à
  direita (─ ▢ ✕); cantos e borda de vidro ajustáveis; animações de
  abrir, minimizar e janelas gelatinosas.
- Vidro: um controle só, do mais transparente ao mais sólido.
- Barra e dock: tamanho da dock, altura da barra e barra que se esconde
  quando há janela maximizada.

Pacotes: `birfree 1.0.0.r71.g8b714f89-1` (novo) e
`birfree-icons 1.0.0.r15.gf2e541b6-1` (o mesmo do teste 3). O instalador e o
`so-birfree.sh` são os mesmos do teste 3.

## O instalador (instalação nova)

`./instalar-birfree --migrar` executa a migração do `so-birfree.sh`:

- Guarda configurações e listas em `~/.local/share/birfree-migracao/`.
- Aponta o mirrorlist para **Arch Archive de 01/10/2026** e roda `pacman -Syyu`.
- Instala as dependências de suporte e os pacotes prontos do Birfree.
- Configura tema e sessão Birfree no SDDM, habilitando-o sem reiniciar o serviço.
- Protege as peças KDE usadas pelo Birfree e remove as sessões Plasma (Wayland e
  X11, com o `kwin-x11`) e LXQt.

A confirmação inicial informa a troca dos repositórios e as remoções.
Se a instalação da DE falhar, nenhuma sessão é removida. A sessão atual
permanece aberta. O procedimento modifica o sistema inteiro, incluindo os
repositórios usados nas próximas atualizações.

A migração usa o mesmo script da árvore original (commit `edcaa7ab`),
adaptado para usar pacotes prontos no arquivo público.
As animações do teste 2 permanecem: Scale, Magic Lamp e Wobbly Windows.

## Passos

Primeiro, baixe o arquivo e o checksum:

```sh
curl -fLO https://github.com/NEOpisa/test/releases/download/v1.0.0-test.6/Birfree-1.0.0-x86_64.tar.gz
curl -fLO https://github.com/NEOpisa/test/releases/download/v1.0.0-test.6/SHA256SUMS
sha256sum --check SHA256SUMS
```

Extraia em uma pasta nova e entre nela:

```sh
mkdir Birfree-teste6
tar -xf Birfree-1.0.0-x86_64.tar.gz -C Birfree-teste6
cd Birfree-teste6/Birfree-1.0.0-x86_64
```

Confira o plano sem mudar nada:

```sh
./instalar-birfree --simular
```

Depois execute a migração como usuário normal, com sudo disponível:

```sh
./instalar-birfree --migrar
```

No fim, salve o trabalho e entre em **Birfree** no SDDM.

## Outras opções

| Comando | Ação |
|---|---|
| `./instalar-birfree` | Instala/atualiza só os pacotes (o mesmo que `--atualizar`) |
| `./instalar-birfree --mostrar` | Confere integridade e lista os dois pacotes |
| `./instalar-birfree --atualizar` | Atualiza só os pacotes; não migra nem troca repositórios |
| `./atualizar-birfree` | Baixa o teste mais novo e roda o `--atualizar` |
| `./instalar-birfree --desfazer` | Restaura arquivos do último backup e reinstala sessões retiradas |

O desfazer mantém o Birfree instalado; não é rollback completo das atualizações
do sistema feitas pelo pacman. Suporta também os backups do script original.

## Compatibilidade

Internet, sudo, Arch Linux x86_64. Binários compilados com **KWin 6.7.5-1** e
**Qt 6.11.2-3**, conforme `VERSOES.txt`. A verificação exige essas versões antes
de instalar os binários. `pacman -Syyu` não faz downgrade automático de pacotes
mais novos: nesse caso, a instalação interrompe antes de remover sessões.
O pacote não traz todas as dependências; elas vêm dos repositórios do sistema.

## Validação

- Oito regressões com subprocessos simulados: simulação sem alterações,
  cancelamento, proteção de pacotes, falhas de prévia e de atualização,
  atualização sem migração, ABI incompatível e corrupção antes de backup.
- Arquivo portátil extraído fora do projeto: `--mostrar` e `--simular` passaram.
- Script de migração contido no arquivo idêntico ao original atualizado.
- Arquivo corrompido recusado antes de iniciar a migração.

- Teste 4: arquivo extraído fora do projeto, `--mostrar` e
  `--atualizar --simular` passaram; as configurações novas e o só escuro
  foram testados na sessão Birfree em janela.
- Teste 5: as tentativas do download testadas com `sudo` falso; `--mostrar`
  e `--simular` do arquivo extraído passaram (o `--simular` mostra o backup
  do mirrorlist levado adiante numa segunda rodada).

- Patch do 5.5: arquivo extraído fora do projeto, checksums externo e interno,
  `--mostrar` e `--simular` passaram; o gerenciador de apps e a sessão no
  menu foram testados na sessão Birfree em janela. Desinstalar pacote e
  Flatpak de verdade ainda precisa da sessão real.

- Patch do teste 6: arquivo extraído fora do projeto, checksums externo e
  interno e `--mostrar` passaram; 18 testes do instalador passaram. Na
  sessão Birfree instalada: papel de parede nítido, widget adicionado,
  configuração nova do relógio e luz do teclado conferidos. O Konsole sem
  fantasma ainda precisa de uso real para confirmar.

A migração completa ainda precisa ser validada em uma VM limpa e no
computador que apresentou o problema.

SHA-256 do arquivo desta pré-release:

```text
d5767c6eb045155e4ca3603ca5e9f631f0d6469063031c19c6af124b685c3b75
```

## Licença

GPL-3.0-or-later. Pacotes mantêm as licenças de seus componentes.
