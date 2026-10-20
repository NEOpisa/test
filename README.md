# Birfree — TESTE 6

Pré-release para **Arch Linux x86_64**, de 20/10/2026.

## Instalar ou atualizar

O comando continua o mesmo dos testes anteriores:

```sh
curl -fLO https://raw.githubusercontent.com/NEOpisa/test/main/atualizar-birfree
chmod +x atualizar-birfree
./atualizar-birfree
```

**Neste teste, a compilação acontece no seu computador.** O atualizador baixa
os fontes, confere o SHA-256, instala as dependências com confirmação do
pacman e compila os pacotes como usuário normal. Só depois de a compilação
terminar com sucesso ele pede confirmação para instalar os dois pacotes locais.
Nenhum pacote binário foi compilado na máquina de publicação.

Para escolher especificamente esta versão:

```sh
./atualizar-birfree v1.0.0-test.6
```

Depois da instalação, salve seu trabalho, saia e entre novamente em **Birfree**.
O script não encerra sua sessão automaticamente.

## O que entra no teste 6

- Correções gerais do vidro: campos de edição sobre listas, ícones e tabelas
  cobrem o texto antigo ao renomear, incluindo os cantos do campo. Correções
  também de sobreposições QML/Kirigami, restauração do fundo e troca de cores.
- Menus Birfree no launcher, nas tarefas da dock, nas áreas de trabalho,
  no menu global e na bandeja: vidro, atalhos, checks, submenus, teclado e
  atualização das ações enquanto o menu está aberto.
- Área de widgets própria: galeria, edição, relógio e Tocando agora, com
  suporte a widgets do KDE. **Nenhum widget vem ligado por padrão.**
  Botão direito na barra/dock → **Adicionar widgets…** ou **Editar área de trabalho**.
- Mantém as melhorias do teste 5.5: Configurações do Sistema, sessão no
  rodapé do menu, gerenciador de aplicativos e compatibilidade X11.

Dock integrada e personalização da ordem dos itens das barras ainda não
entram neste teste. A base continua sendo o KDE/Qt instalado; os cinco forks
em desenvolvimento não são compilados nem substituídos por este instalador.
Este teste não representa a versão 1.0 final.

## Download manual

[Baixar instalador e fontes](https://github.com/NEOpisa/test/releases/download/v1.0.0-test.6/Birfree-1.0.0-x86_64.tar.gz)

```sh
curl -fLO https://github.com/NEOpisa/test/releases/download/v1.0.0-test.6/Birfree-1.0.0-x86_64.tar.gz
curl -fLO https://github.com/NEOpisa/test/releases/download/v1.0.0-test.6/SHA256SUMS
sha256sum --check SHA256SUMS
tar -xf Birfree-1.0.0-x86_64.tar.gz
cd Birfree-1.0.0-x86_64
./instalar-birfree
```

O arquivo contém instaladores, fontes, licenças, versões e checksums; não
contém pacotes prontos. `./instalar-birfree --mostrar` confere a integridade
sem compilar, instalar dependências ou extrair os fontes de compilação.
`./instalar-birfree --atualizar` também é aceito.

## Compilação e instalação

Dependências vêm das receitas de `birfree-icons` e `birfree`. A compilação
usa duas tarefas por padrão. Fontes, pacotes gerados e `compilacao.log` ficam
em `~/.cache/birfree/compilacoes/`. Se o build falhar, os pacotes do Birfree
instalados são preservados e o log permanece para diagnóstico.

Não troca mirrors/repositórios, não remove outras sessões e não muda o perfil
de energia. A migração antiga continua separada em `--migrar`; `--desfazer`
continua disponível para quem a usou anteriormente.

## Validação

O instalador passou em testes com comandos simulados para integridade,
consulta sem instalação, falha de compilação e instalação dos dois pacotes
locais. O arquivo publicado foi extraído e seus checksums conferidos.
Nenhuma compilação foi executada para publicar este teste. As correções
visuais foram exercitadas anteriormente na sessão aninhada; o teste na sua
sessão instalada continua necessário.

Veja as revisões em `VERSOES.txt` e as licenças nos fontes. O tema Fluent
é obtido no commit fixo indicado em `birfree-icons/tools/montar.py` durante
a geração dos ícones no computador de destino.
