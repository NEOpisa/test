# Instalador por fontes do teste 6

`atualizar-birfree` baixa a Release e verifica o SHA-256. O wrapper
`instalar-birfree` encaminha o bundle sem pacotes/ para `instalar-fontes`.
Este confere os arquivos, extrai os fontes no cache, resolve as dependências
das receitas e executa `instalar.sh --base-atual --gerar-pacotes` no PC de
quem instala. O pacman só recebe os dois pacotes locais depois do sucesso.

Releases anteriores com pacotes/ mantêm o fluxo de instalar-pacotes.
O repositório avulso precisa do arquivo completo da Release para instalar.
O atualizador baixa esse arquivo automaticamente. Consulte README.md.
