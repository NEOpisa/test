# Birfree — TESTE

Pacote experimental do **Birfree 1.0**, a área de trabalho da Neovanguard,
com shell Qt/QML sobre o KWin em Wayland.

**Este repositório é de testes. A distribuição está marcada como pré-release,
não como versão estável.**

## Baixar

[Baixar Birfree-1.0.0-x86_64.tar.gz](https://github.com/NEOpisa/test/releases/download/v1.0.0-test.2/Birfree-1.0.0-x86_64.tar.gz)

O arquivo único tem aproximadamente **24,2 MiB** e contém os pacotes
`birfree` e `birfree-icons`, o instalador, instruções, licença e somas SHA-256.
Não é uma ISO e não precisa da pasta do projeto nem de recompilação.

## Animações — teste 2

Efeitos da comunidade KDE, já incluídos no KWin:

- **Scale** ao abrir/fechar janelas.
- **Magic Lamp** ao minimizar/restaurar.
- **Wobbly Windows** ao arrastar janelas.

O Condense do Birfree fica desligado. Esta revisão altera os padrões da
sessão e reaproveita os binários existentes, sem recompilar.
O pacote `birfree` passa de `1.0.0.r67.gf0eb355a-1` para
`1.0.0.r67.gf0eb355a-2`; os ícones permanecem iguais.
Para quem já usa o Birfree, instale o novo arquivo e saia/entre na sessão.

## Requisitos

- Arch Linux x86_64 ou sistema compatível com pacman.
- Pilha gráfica KDE/KWin compatível. Estes binários foram compilados com
  **KWin 6.7.5-1** e **Qt 6.11.2-3**; não foram validados com outras versões.
- Acesso a `sudo` para instalar os pacotes.
- Internet caso faltem dependências: o pacman baixa o que for necessário.

O pacote inclui a DE e os ícones, não todas as dependências do sistema.
As versões completas estão no arquivo `VERSOES.txt` do pacote e neste repositório.

## Instalar ou atualizar

Na pasta em que você salvou o download, execute como usuário normal:

```sh
tar -xf Birfree-1.0.0-x86_64.tar.gz
cd Birfree-1.0.0-x86_64
./instalar-birfree
```

O instalador confere a integridade dos arquivos, mostra os dois pacotes e
pede a senha do sudo e a confirmação da transação do pacman. O mesmo comando
instala o Birfree ou atualiza uma instalação existente.

Para conferir os pacotes sem instalar:

```sh
./instalar-birfree --mostrar
```

Depois da instalação, salve seu trabalho, saia da sessão e selecione
**Birfree** na tela de entrada. O instalador não encerra a sessão atual.

## Integridade do download

```sh
sha256sum Birfree-1.0.0-x86_64.tar.gz
```

SHA-256 desta pré-release:

```text
5d5344bc2ec858af54e551276b4d334f574755d5c39f2db4f5b663ff8a624d56
```

O instalador também confere os arquivos extraídos usando o `SHA256SUMS`
incluído no pacote e interrompe a instalação se detectar alteração.

## O que foi validado

- Extração e execução do instalador fora da pasta do projeto.
- Consulta dos pacotes com `--mostrar`, sem instalar.
- Recusa de um pacote corrompido antes da instalação.
- Compilação dos pacotes nas versões informadas de KWin e Qt.

Ainda é uma distribuição de teste; a instalação neste pacote não foi validada
em todas as distribuições derivadas do Arch nem em outras versões da pilha gráfica.

## Licença

GPL-3.0-or-later. O texto está em `LICENSE`; os pacotes mantêm os avisos e as
licenças dos componentes que entregam.
