# Birfree — TESTE 3

Pré-release experimental para **Arch Linux x86_64**.

## Baixar

[Baixar Birfree-1.0.0-x86_64.tar.gz](https://github.com/NEOpisa/test/releases/download/v1.0.0-test.3/Birfree-1.0.0-x86_64.tar.gz)

O arquivo inclui os pacotes, o **so-birfree.sh original**, instalador,
licença, versões e checksums. Não precisa do repositório privado nem compilar.
Extraia em uma pasta nova; não misture com arquivos dos testes 1 ou 2.
Os scripts neste repositório documentam o fluxo; para instalar, baixe o
arquivo completo da Release, que também contém os pacotes.

## O que mudou no instalador

Por padrão, `./instalar-birfree` executa a migração do `so-birfree.sh`:

- Guarda configurações e listas em `~/.local/share/birfree-migracao/`.
- Aponta o mirrorlist para **Arch Archive de 01/10/2026** e roda `pacman -Syyu`.
- Instala as dependências de suporte e os pacotes prontos do Birfree.
- Configura tema e sessão Birfree no SDDM, habilitando-o sem reiniciar o serviço.
- Protege as peças KDE usadas pelo Birfree/Glinux e remove sessões Plasma/LXQt.

A confirmação inicial informa a troca dos repositórios e as remoções.
Se a instalação da DE falhar, nenhuma sessão é removida. A sessão atual
permanece aberta. O procedimento modifica o sistema inteiro, incluindo os
repositórios usados nas próximas atualizações.

A migração usa o mesmo script da árvore original (commit `edcaa7ab`),
adaptado para usar pacotes prontos no arquivo público.
As animações do teste 2 permanecem: Scale, Magic Lamp e Wobbly Windows.
Os pacotes da DE continuam em `birfree 1.0.0.r67.gf0eb355a-2` e
`birfree-icons 1.0.0.r15.gf2e541b6-1`; o teste 3 muda o instalador.

## Passos

Primeiro, baixe o arquivo e o checksum:

```sh
curl -fLO https://github.com/NEOpisa/test/releases/download/v1.0.0-test.3/Birfree-1.0.0-x86_64.tar.gz
curl -fLO https://github.com/NEOpisa/test/releases/download/v1.0.0-test.3/SHA256SUMS
sha256sum --check SHA256SUMS
```

Extraia em uma pasta nova e entre nela:

```sh
mkdir Birfree-teste3
tar -xf Birfree-1.0.0-x86_64.tar.gz -C Birfree-teste3
cd Birfree-teste3/Birfree-1.0.0-x86_64
```

Confira o plano sem mudar nada:

```sh
./instalar-birfree --simular
```

Depois execute a migração como usuário normal, com sudo disponível:

```sh
./instalar-birfree
```

No fim, salve o trabalho e entre em **Birfree** no SDDM.

## Outras opções

| Comando | Ação |
|---|---|
| `./instalar-birfree --mostrar` | Confere integridade e lista os dois pacotes |
| `./instalar-birfree --atualizar` | Atualiza só os pacotes; não migra nem troca repositórios |
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

A migração completa ainda precisa ser validada em uma VM limpa e no
computador que apresentou o problema. A causa específica naquele computador
não foi confirmada; o teste 3 corrige a diferença entre os instaladores.

SHA-256 do arquivo desta pré-release:

```text
4420f61e22607958ee05a6b81bfc798bd10294c76fd25d5b61d2539291e9ede6
```

## Licença

GPL-3.0-or-later. Pacotes mantêm as licenças de seus componentes.
