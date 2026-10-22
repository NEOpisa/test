#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Deixa esta máquina só com o Birfree: instala o Birfree mais atualizado
# (desta pasta) e tira o Plasma e o LXQt. Fica só o que o Birfree usa do
# KDE. O Birfree é só Wayland: o kwin-x11 e a sessão X11 do Plasma saem.
#
#   ./so-birfree.sh                faz tudo (pede a senha do sudo e confirmação)
#   ./so-birfree.sh --simular      mostra o que faria, sem mudar nada
#   ./so-birfree.sh --atualizar   atualiza só os pacotes, sem migrar
#   ./so-birfree.sh --mostrar     mostra os pacotes prontos
#   ./so-birfree.sh --desfazer     reinstala o Plasma e o LXQt, devolve os
#                                  arquivos guardados e o mirrorlist (último backup)
#
# Trava o sistema na data da última atualização (TRAVA, no Arch Linux
# Archive): o Birfree é feito sobre o KDE 6.7.5 / Frameworks 6.30 / Qt 6.11,
# e o Plasma 6.8 (16/10/2026) trouxe Qt 6.12. O pacman -Syu passa a
# atualizar só até essa data, de
# forma coerente (o kernel CachyOS, que fica no fim do pacman.conf, segue).
#
# O Birfree é feito sobre peças do KDE (KWin, plasma-workspace, Kirigami,
# Configurações...): elas ficam. Sai a sessão Plasma e o que só ela usa.
set -euo pipefail

RAIZ=$(cd "$(dirname "$0")" && pwd)
GUARDA_RAIZ="${XDG_DATA_HOME:-$HOME/.local/share}/birfree-migracao"
CARIMBO=$(date +%Y%m%d-%H%M%S)-$$
GUARDA="$GUARDA_RAIZ/$CARIMBO"
SIMULAR=0
ACAO=migrar
# A data da última atualização completa (/var/log/pacman.log): o KDE e o Qt
# do Archive nesse dia são exatamente os instalados
TRAVA=2026/10/01
MIRRORLIST=/etc/pacman.d/mirrorlist
PACOTES_INSTALADOR="${BIRFREE_PACOTES_INSTALADOR:-$RAIZ/instalar-pacotes}"
# A árvore nova exige a base local pronta. Arquivos públicos anteriores,
# sem estas ferramentas, conservam o instalador compatível com seus binários.
REPOS_LOCAIS=0
[[ ! -f $RAIZ/base/forks.json ]] || REPOS_LOCAIS=1
REPO_LOCAL="${BIRFREE_REPO:-$(dirname "$RAIZ")/birfree-repo}"
# A distribuição pública inclui este ajudante e usa binários; a árvore fonte
# continua podendo compilar pelo instalar.sh original.
SUPORTE=(sddm kwin qt6-base plasma-desktop systemsettings kde-gtk-config xdg-desktop-portal-kde
         kscreen kscreenlocker bluedevil kdeplasma-addons qt6-tools kwallet-pam
         python-dbus networkmanager power-profiles-daemon)
if ((REPOS_LOCAIS)); then
    SUPORTE=(sddm bwin birfree-workspace gigamana bscreen bscreenlocker qt6-base
             plasma-desktop systemsettings kde-gtk-config xdg-desktop-portal-kde
             bluedevil kdeplasma-addons qt6-tools kwallet-pam python-dbus
             networkmanager power-profiles-daemon)
fi

# ------------------------------------------------------------ as listas --
# Plasma que sai: a sessão (Wayland e X11), o metapacote e o que só o
# Plasma usa. As Configurações, o Discover, o Spectacle, o Flatpak etc. ficam.
PLASMA_SAI=(
    plasma-meta plasma-x11-session plasma-welcome plasma-browser-integration
    plasma-vault plasma-thunderbolt plasma-keyboard plasma-login-manager
    oxygen oxygen-cursors oxygen-icons oxygen-sounds krdp kwrited kwin-x11
)
# LXQt que sai (com as bibliotecas dele) e as ferramentas que só a sessão
# LXQt usava. kdialog (aviso de queda da shell) e playerctl ficam.
LXQT_SAI=(
    lxqt-session lxqt-panel lxqt-globalkeys lxqt-qtplugin lxqt-notificationd
    lxqt-powermanagement lxqt-themes lxqt-menu-data xcape i3lock xss-lock copyq
)
# Nunca podem sair (o Birfree usa): conferidos antes de remover
PROTEGIDOS=(
    birfree birfree-icons kwin kglobalacceld polkit-kde-agent powerdevil
    kwallet-pam plasma-workspace plasma-desktop systemsettings kde-gtk-config
    breeze breeze-gtk breeze-cursors xsettingsd xdg-desktop-portal-kde aurorae
    kscreen kscreenlocker plasma-nm plasma-pa bluedevil milou kdeplasma-addons
    qt6-tools python-dbus kdialog playerctl
    dolphin konsole kate ark spectacle discover flatpak
)
if ((REPOS_LOCAIS)); then
    PROTEGIDOS+=(bwin birfree-workspace gigamana bscreen bscreenlocker)
fi
# Sessões do Plasma que o SDDM não deve mais mostrar (o .desktop do Wayland é
# do plasma-workspace, que fica; o NoExtract impede que volte na atualização)
SESSAO_PLASMA=usr/share/wayland-sessions/plasma.desktop

# Arquivos da sessão LXQt com peças do KDE (~/Projetos/lxqt-kde): guardados,
# não apagados
CONF=${XDG_CONFIG_HOME:-$HOME/.config}
DATA=${XDG_DATA_HOME:-$HOME/.local/share}
LXQT_ARQUIVOS=(
    "$CONF/lxqt"
    "$DATA/lxqt/themes/Moe-KDE"
    "$CONF/autostart/lxqt-kde-inicio.desktop"
    "$DATA/applications/lxqt-mimeapps.list"
    "$CONF/xdg-desktop-portal/lxqt-portals.conf"
    "$DATA/kglobalaccel/sessao-escolher.desktop"
    "$DATA/applications/com.github.hluk.copyq.desktop"
    "$HOME/.local/bin/trocar-sessao"
    "$HOME/.local/bin/lxqt-kde-wm"
    "$HOME/.local/bin/lxqt-kde-inicio"
    "$HOME/.local/bin/lxqt-kde-tecla"
)
LXQT_ROOT=(/etc/sudoers.d/50-trocar-sessao /usr/local/libexec/trocar-sessao-sddm)
# Atalhos do kde-dock (a dock do tempo do Plasma): Meta+A e Meta+Ctrl+A
# disparavam junto com os da dock do Birfree ("o plasmashell não respondeu").
# A ponte do Discord virou a b-dock-discord do pacote (o instalar.sh desliga
# a kde-dock-discord.service).
KDE_DOCK_ATALHOS=(
    "$DATA/applications/kde-dock.desktop"
    "$DATA/applications/kde-dock-jogo.desktop"
)

# ------------------------------------------------------------- ajudantes --
passo() { printf '\n\033[1;35m▸ %s\033[0m\n' "$*"; }
ok() { printf '  \033[32m✓\033[0m %s\n' "$*"; }
info() { printf '  · %s\n' "$*"; }
erro() { printf '\033[1;31m✗ %s\033[0m\n' "$*" >&2; exit 1; }
x() {
    if ((SIMULAR)); then
        printf '  \033[33m[simular]\033[0m %s\n' "$*"
    else
        "$@"
    fi
}
instalado() { pacman -Q "$1" >/dev/null 2>&1; }
so_instalados() {
    local p
    for p in "$@"; do instalado "$p" && echo "$p"; done
    return 0
}
# O Arch Linux Archive é um servidor só e corta quem abre muitas conexões:
# com ParallelDownloads alto ele chega a "Less than 1 bytes/sec transferred
# the last 10 seconds" e o pacman desiste da transação inteira. Aqui o pacman
# baixa de 3 em 3 e tenta de novo; o que já desceu fica no cache.
PACMAN_CONF_ARCHIVE=""
pacman_archive() {
    local tentativa conf
    if [[ -z $PACMAN_CONF_ARCHIVE ]]; then
        PACMAN_CONF_ARCHIVE=$(mktemp --tmpdir birfree-pacman.XXXXXX.conf)
        trap 'rm -f "$PACMAN_CONF_ARCHIVE"' EXIT
        sed -E 's/^[[:space:]]*#?[[:space:]]*ParallelDownloads.*/ParallelDownloads = 3/' \
            /etc/pacman.conf >"$PACMAN_CONF_ARCHIVE"
        grep -q '^ParallelDownloads' "$PACMAN_CONF_ARCHIVE" ||
            sed -i 's/^\[options\]$/&\nParallelDownloads = 3/' "$PACMAN_CONF_ARCHIVE"
    fi
    conf=$PACMAN_CONF_ARCHIVE
    for tentativa in 1 2 3 4 5; do
        sudo pacman --config "$conf" "$@" && return 0
        ((tentativa < 5)) || break
        info "o download falhou (o Archive costuma ficar lento); tentando de novo em 15 s ($((tentativa + 1))/5)"
        sleep 15
        # depois do -yy da 1ª tentativa o banco já está na data travada
        set -- "${@/#-Syyu/-Syu}"
    done
    return 1
}

# ------------------------------------------------------------ migração --
conferir() {
    passo "Conferindo"
    [[ $EUID -ne 0 ]] || erro "rode como você mesmo (o script chama o sudo quando precisa)"
    [[ -x "$PACOTES_INSTALADOR" || -x "$RAIZ/instalar.sh" ]] || erro "não achei o instalador de pacotes nem instalar.sh"
    command -v pacman >/dev/null || erro "este instalador requer Arch Linux com pacman"
    [[ $(uname -m) == x86_64 ]] || erro "este pacote requer x86_64"
    if [[ -x "$PACOTES_INSTALADOR" ]]; then
        "$PACOTES_INSTALADOR" --mostrar || erro "pacotes ausentes ou corrompidos; nada foi alterado"
    fi
    command -v sudo >/dev/null || erro "precisa do sudo"
    if [[ ${XDG_CURRENT_DESKTOP:-} == *KDE* || ${XDG_CURRENT_DESKTOP:-} == *LXQt* ]]; then
        info "você está numa sessão ${XDG_CURRENT_DESKTOP}: ela continua aberta, mas"
        info "depois de terminar saia dela e entre no Birfree"
    fi
    ok "pronto para começar"
}

guardar_estado() {
    passo "Guardando o estado de agora (para o --desfazer)"
    x mkdir -p "$GUARDA"
    if ((!SIMULAR)); then
        pacman -Qqe >"$GUARDA/explicitos.txt"
        pacman -Qqd >"$GUARDA/dependencias.txt"
        mkdir -p "$GUARDA/raiz/etc"
        cp -a /etc/pacman.conf "$GUARDA/raiz/etc/pacman.conf"
        systemctl is-enabled sddm.service >"$GUARDA/sddm-antes.txt" 2>/dev/null || true
        so_instalados "${PLASMA_SAI[@]}" >"$GUARDA/plasma-removidos.txt"
        so_instalados "${LXQT_SAI[@]}" >"$GUARDA/lxqt-removidos.txt"
    fi
    ok "em ${GUARDA/#$HOME/\~}"
}

travar_sistema() {
    if ((REPOS_LOCAIS)); then
        travar_kde
        return
    fi
    passo "Travando o sistema em ${TRAVA} (Arch Linux Archive)"
    if grep -q "archive.archlinux.org/repos/$TRAVA/" "$MIRRORLIST" 2>/dev/null; then
        ok "o mirrorlist já aponta para $TRAVA"
        # Rodada de novo (ex.: o download falhou da outra vez): o mirrorlist de
        # antes está num backup anterior; o --desfazer só olha o último
        local antes
        antes=$(ls -1d "$GUARDA_RAIZ"/*/raiz"$MIRRORLIST" 2>/dev/null | grep -v "/$CARIMBO/" | tail -1) || true
        if [[ -n $antes ]]; then
            x sudo mkdir -p "$GUARDA/raiz/etc/pacman.d"
            x sudo cp -a "$antes" "$GUARDA/raiz$MIRRORLIST"
            info "mirrorlist de antes trazido de ${antes/#$HOME/\~}"
        fi
    else
        x sudo mkdir -p "$GUARDA/raiz/etc/pacman.d"
        x sudo cp -a "$MIRRORLIST" "$GUARDA/raiz$MIRRORLIST"
        if ((SIMULAR)); then
            info "[simular] $MIRRORLIST -> Server = https://archive.archlinux.org/repos/$TRAVA/\$repo/os/\$arch"
        else
            printf '%s\n' \
                "# Birfree: sistema travado em $TRAVA (so-birfree.sh). O Birfree é feito" \
                "# sobre o KDE 6.7.5 / Qt 6.11; o Plasma 6.8 quebraria ele." \
                "# O mirrorlist de antes está em ${GUARDA}/raiz$MIRRORLIST" \
                "# (./so-birfree.sh --desfazer devolve)." \
                "Server = https://archive.archlinux.org/repos/$TRAVA/\$repo/os/\$arch" |
                sudo tee "$MIRRORLIST" >/dev/null
        fi
        ok "pacman apontando para o Archive de $TRAVA"
    fi
    # -yy: o banco local foi sincronizado com o Arch de hoje (Plasma 6.8) e
    # precisa voltar ao da data travada; o -u traz só o que faltar até ela
    if ((SIMULAR)); then
        info "[simular] sudo pacman -Syyu --noconfirm (de 3 em 3 downloads, até 5 tentativas)"
    else
        pacman_archive -Syyu --noconfirm ||
            erro "o pacman -Syyu na data travada falhou (o Archive pode estar fora do ar); nada foi removido. Rode o ./so-birfree.sh de novo mais tarde: ele continua de onde parou"
    fi
    ok "repositórios sincronizados em $TRAVA (versões instaladas conferidas antes de remover sessões)"
}

travar_kde() {
    passo "Travando KDE/Qt nos repositórios locais; Arch volta a atualizar"
    if ((SIMULAR)); then
        info "[simular] conferir os cinco forks e o snapshot KDE/Qt em $REPO_LOCAL"
        info "[simular] inserir [birfree] e [birfree-kde] antes do Arch, com backup"
        info "[simular] restaurar o mirrorlist normal do backup anterior"
        info "[simular] sudo pacman -Syyu (transação completa, sem downgrade automático)"
        return
    fi
    python3 "$RAIZ/tools/birfree-repos.py" --check || erro "prepare a base local antes de migrar (base/README.md); nada foi instalado"
    local normal conf
    normal=$(python3 "$RAIZ/tools/birfree-repos.py" --mirror-backup) || erro "falta o mirrorlist normal"
    touch "$GUARDA/repos-locais"
    # DownloadUser=alpm precisa atravessar a home para acessar file://.
    # O ACL concede somente travessia, sem listar ou ler os outros arquivos.
    if [[ $(pacman-conf DownloadUser 2>/dev/null) == alpm ]]; then
        command -v getfacl >/dev/null && command -v setfacl >/dev/null || erro "instale acl para o repo local"
        getfacl -p "$HOME" >"$GUARDA/repo-home-acl.txt"
        setfacl -m u:alpm:--x "$HOME"
        sudo -u alpm test -r "$REPO_LOCAL/birfree-kde/birfree-kde.db" || erro "alpm não consegue ler $REPO_LOCAL; confira a travessia dos diretórios"
    fi
    mkdir -p "$GUARDA/raiz/etc/pacman.d"
    cp -a "$MIRRORLIST" "$GUARDA/raiz$MIRRORLIST"
    conf=$(mktemp --tmpdir birfree-local.XXXXXX.conf)
    python3 "$RAIZ/tools/birfree-repos.py" --render /etc/pacman.conf >"$conf" || { rm -f "$conf"; erro "pacman.conf não foi alterado"; }
    sudo install -m644 "$conf" /etc/pacman.conf
    rm -f "$conf"
    sudo install -m644 "$normal" "$MIRRORLIST"
    pacman_archive -Syyu || erro "a atualização não terminou; os repositórios e o backup foram preservados em $GUARDA"
    ok "KDE/Qt em $TRAVA; demais pacotes nos mirrors normais"
}

instalar_birfree() {
    passo "Instalando o Birfree"
    if ((SIMULAR)); then
        info "[simular] instalar suporte: ${SUPORTE[*]}"
        info "[simular] ${PACOTES_INSTALADOR} (ou instalar.sh na árvore fonte)"
        return
    fi
    pacman_archive -S --needed --noconfirm "${SUPORTE[@]}" || erro "falha nas dependências; nenhuma sessão removida"
    if [[ -x "$PACOTES_INSTALADOR" ]]; then
        "$PACOTES_INSTALADOR" || erro "a instalação do Birfree falhou; nenhuma sessão removida. Backup: $GUARDA"
    else
        "$RAIZ/instalar.sh" || erro "a instalação do Birfree falhou; nenhuma sessão removida"
    fi
    instalado birfree && instalado birfree-icons || erro "faltam pacotes Birfree; nenhuma sessão removida"
    [[ -x /usr/bin/startbirfree && -f /usr/share/wayland-sessions/birfree.desktop ]] || erro "sessão Birfree incompleta; nenhuma sessão removida"
    ok "$(pacman -Q birfree) e $(pacman -Q birfree-icons)"
}

configurar_login() {
    passo "Configurando a entrada Birfree no SDDM"
    local conf=/etc/sddm.conf.d/99-birfree-migracao.conf
    if [[ -e $conf ]]; then
        x sudo mkdir -p "$GUARDA/raiz/etc/sddm.conf.d"
        x sudo cp -a "$conf" "$GUARDA/raiz$conf"
    elif ((!SIMULAR)); then
        printf '%s\n' "$conf" >>"$GUARDA/criados-root.txt"
    fi
    if ((SIMULAR)); then
        info "[simular] tema e última sessão Birfree em $conf"
    else
        sudo mkdir -p /etc/sddm.conf.d
        printf '[Theme]\nCurrent=birfree\nCursorTheme=iBirfree\n[Users]\nRememberLastSession=true\n' | sudo tee "$conf" >/dev/null
        sudo mkdir -p /var/lib/sddm
        if [[ -f /var/lib/sddm/state.conf ]]; then
            sudo mkdir -p "$GUARDA/raiz/var/lib/sddm"
            sudo cp -a /var/lib/sddm/state.conf "$GUARDA/raiz/var/lib/sddm/state.conf"
        else
            printf '%s\n' /var/lib/sddm/state.conf >>"$GUARDA/criados-root.txt"
        fi
        sudo kwriteconfig6 --file /var/lib/sddm/state.conf --group Last --key Session /usr/share/wayland-sessions/birfree.desktop
        sudo chown sddm:sddm /var/lib/sddm/state.conf
    fi
    # Não reinicia o gerenciador: mantém a sessão atual aberta.
    x sudo systemctl enable sddm.service || erro "não consegui habilitar SDDM; nenhuma sessão removida"
    if systemctl --user is-active --quiet kde-dock-discord.service 2>/dev/null || systemctl --user is-enabled --quiet kde-dock-discord.service 2>/dev/null; then
        x systemctl --user disable --now kde-dock-discord.service
    fi
}

proteger() {
    passo "Protegendo o que o Birfree usa"
    # Tudo o que uma remoção recursiva levaria junto (fora a própria lista)
    # vira "instalado de propósito": nada do que fica vira órfão, nem agora
    # nem num pacman -Qdt futuro (o plasma-meta é que segurava essas peças)
    local alvos levaria p lista marcar=()
    mapfile -t alvos < <(so_instalados "${PLASMA_SAI[@]}")
    if ((${#alvos[@]})); then
        lista=$(pacman -Rsp --print-format '%n' "${alvos[@]}") || erro "não consegui prever as dependências do Plasma"
        mapfile -t levaria <<<"$lista"
        for p in "${levaria[@]}"; do
            [[ " ${alvos[*]} " == *" $p "* ]] || marcar+=("$p")
        done
    fi
    for p in "${PROTEGIDOS[@]}"; do
        instalado "$p" && marcar+=("$p")
    done
    if ((${#marcar[@]})); then
        x sudo pacman -D --asexplicit "${marcar[@]}" >/dev/null
        ok "${#marcar[@]} pacotes marcados como instalados de propósito"
    fi
}

remover_plasma() {
    passo "Tirando o Plasma"
    local alvos
    mapfile -t alvos < <(so_instalados "${PLASMA_SAI[@]}")
    if ((${#alvos[@]} == 0)); then
        ok "nada do Plasma para tirar"
    else
        info "saem: ${alvos[*]}"
        # Sem -s: só a lista. As dependências que ficariam órfãs já foram protegidas
        conferir_protegidos -Rp "${alvos[@]}"
        x sudo pacman -R --noconfirm "${alvos[@]}" || erro "o pacman -R do Plasma falhou"
        ok "Plasma fora"
    fi

    # A sessão Plasma (Wayland) fica no plasma-workspace, que o Birfree usa:
    # some do SDDM e não volta nas atualizações
    if grep -qE "^NoExtract.*$SESSAO_PLASMA" /etc/pacman.conf; then
        ok "a sessão Plasma já estava no NoExtract"
    else
        x sudo sed -i "/^\[options\]/a NoExtract = $SESSAO_PLASMA" /etc/pacman.conf
        ((SIMULAR)) || grep -qF "NoExtract = $SESSAO_PLASMA" /etc/pacman.conf || erro "não consegui gravar NoExtract"
    fi
    if [[ -e /$SESSAO_PLASMA ]]; then
        x sudo mkdir -p "$GUARDA/raiz/usr/share/wayland-sessions"
        x sudo mv "/$SESSAO_PLASMA" "$GUARDA/raiz/$SESSAO_PLASMA"
        ok "sessão Plasma fora do SDDM"
    fi
}

remover_lxqt() {
    passo "Tirando o LXQt"
    local alvos
    mapfile -t alvos < <(so_instalados "${LXQT_SAI[@]}")
    if ((${#alvos[@]} == 0)); then
        ok "nada do LXQt para tirar"
    else
        info "saem (com as bibliotecas do LXQt): $(pacman -Rsp --print-format '%n' "${alvos[@]}" | tr '\n' ' ')"
        conferir_protegidos -Rsp "${alvos[@]}"
        x sudo pacman -Rs --noconfirm "${alvos[@]}" || erro "o pacman -Rs do LXQt falhou"
        ok "LXQt fora"
    fi

    # Os arquivos da sessão LXQt com peças do KDE: guardados, não apagados
    local f destino movidos=0
    for f in "${LXQT_ARQUIVOS[@]}" "$HOME"/.local/bin/.lxqt-kde-tecla.bak-* "$DATA"/applications/sessao-*.desktop \
        "${KDE_DOCK_ATALHOS[@]}"; do
        [[ -e $f || -L $f ]] || continue
        destino="$GUARDA/casa${f#"$HOME"}"
        x mkdir -p "$(dirname "$destino")"
        x mv "$f" "$destino"
        movidos=$((movidos + 1))
    done
    ok "$movidos arquivos da sessão LXQt e atalhos do kde-dock guardados em ${GUARDA/#$HOME/\~}/casa"
    for f in "${LXQT_ROOT[@]}"; do
        # /etc/sudoers.d só é legível pelo root: o teste vai pelo sudo (já
        # autenticado a esta altura; no --simular, sem senha, só o visível)
        [[ -e $f ]] || sudo -n test -e "$f" 2>/dev/null || continue
        x sudo mkdir -p "$GUARDA/raiz$(dirname "$f")"
        x sudo mv "$f" "$GUARDA/raiz$f"
        ok "$f guardado"
    done
}

# Para tudo se uma remoção fosse levar algo que o Birfree usa.
# Uso: conferir_protegidos -Rp|-Rsp PACOTES (o mesmo modo da remoção de verdade)
conferir_protegidos() {
    local modo=$1 p levaria
    shift
    levaria=$(pacman "$modo" --print-format '%n' "$@") || erro "não consegui prever a remoção; operação interrompida"
    levaria=" ${levaria//$'\n'/ } "
    for p in "${PROTEGIDOS[@]}"; do
        [[ $levaria == *" $p "* ]] && erro "a remoção levaria $p (protegido); nada foi removido"
    done
    return 0
}

resumo() {
    passo "Pronto"
    local orfaos
    orfaos=$(pacman -Qqdt 2>/dev/null | tr '\n' ' ') || true
    [[ -n $orfaos ]] && info "órfãos que sobraram (não removidos): $orfaos"
    if ((REPOS_LOCAIS)); then
        info "KDE/Qt em $TRAVA por [birfree-kde]; demais pacotes acompanham o Arch"
        info "BWin só Wayland"
        info "Backup: $GUARDA · voltar: $0 --desfazer"
        info "Saia desta sessão e entre em Birfree no SDDM"
        return
    fi
    cat <<EOF

  Saia desta sessão e entre em "Birfree" no SDDM.
  Sistema travado em $TRAVA: o pacman -Syu não traz o Plasma 6.8.
  Backup: ${GUARDA/#$HOME/\~}   ·   voltar: $0 --desfazer
  Tela de entrada Birfree configurada no SDDM.
EOF
}

# ------------------------------------------------------------- desfazer --
desfazer() {
    passo "Desfazendo (último backup)"
    [[ $EUID -ne 0 ]] || erro "rode como você mesmo"
    local ultimo pacotes f
    ultimo=$(ls -1d "$GUARDA_RAIZ"/*/ 2>/dev/null | tail -1) || true
    [[ -n $ultimo ]] || erro "nenhum backup em $GUARDA_RAIZ"
    ultimo=${ultimo%/}
    info "backup: ${ultimo/#$HOME/\~}"
    # Os arquivos são copiados para manter o backup reutilizável.
    # Devolve os repositórios antes de tentar reinstalar sessões.
    if [[ -f $ultimo/repos-locais ]]; then
        if [[ -f $ultimo/repo-home-acl.txt ]]; then
            x setfacl --restore="$ultimo/repo-home-acl.txt"
        fi
        x sudo cp -a "$ultimo/raiz/etc/pacman.conf" /etc/pacman.conf
        x sudo cp -a "$ultimo/raiz$MIRRORLIST" "$MIRRORLIST"
        PACMAN_CONF_ARCHIVE=""
    fi
    pacotes=$(cat "$ultimo/plasma-removidos.txt" "$ultimo/lxqt-removidos.txt" 2>/dev/null | tr '\n' ' ')
    if [[ -n $pacotes ]]; then
        # shellcheck disable=SC2086
        if ((SIMULAR)); then
            info "[simular] sudo pacman -S --needed --noconfirm $pacotes"
        else
            pacman_archive -S --needed --noconfirm $pacotes || erro "não consegui reinstalar: $pacotes"
        fi
        ok "reinstalados: $pacotes"
    fi
    # Compatibilidade com os backups gerados em 16/10 pelo script original.
    if [[ ! -f $ultimo/raiz/etc/pacman.conf ]]; then
        x sudo sed -i -E "s# $SESSAO_PLASMA##; s#^NoExtract   = $SESSAO_PLASMA\$#\#NoExtract   =#" /etc/pacman.conf
    fi
    if [[ -f $ultimo/criados-root.txt ]]; then
        while IFS= read -r f; do
            [[ $f == /etc/sddm.conf.d/99-birfree-migracao.conf || $f == /var/lib/sddm/state.conf ]] || erro "caminho inesperado no backup"
            x sudo rm -f "$f"
        done <"$ultimo/criados-root.txt"
    fi
    # O mirrorlist de antes da trava volta junto com os outros arquivos do
    # sistema (raiz/etc/pacman.d/mirrorlist) logo abaixo
    if [[ -d $ultimo/raiz ]]; then
        while IFS= read -r -d '' f; do
            x sudo mkdir -p "$(dirname "${f#"$ultimo/raiz"}")"
            x sudo cp -a "$f" "${f#"$ultimo/raiz"}"
        done < <(sudo find "$ultimo/raiz" \( -type f -o -type l \) -print0)
        ok "arquivos do sistema devolvidos (sessão Plasma, ajudante do LXQt)"
    fi
    if [[ -d $ultimo/casa ]]; then
        while IFS= read -r -d '' f; do
            x mkdir -p "$(dirname "$HOME${f#"$ultimo/casa"}")"
            x cp -a "$f" "$HOME${f#"$ultimo/casa"}"
        done < <(find "$ultimo/casa" \( -type f -o -type l \) -print0)
        ok "arquivos da sessão LXQt devolvidos"
    fi
    if [[ -f $ultimo/explicitos.txt ]]; then
        local -a explicitos=() dependencias=()
        mapfile -t explicitos < <(so_instalados $(cat "$ultimo/explicitos.txt"))
        mapfile -t dependencias < <(so_instalados $(cat "$ultimo/dependencias.txt"))
        ((${#explicitos[@]} == 0)) || x sudo pacman -D --asexplicit "${explicitos[@]}"
        ((${#dependencias[@]} == 0)) || x sudo pacman -D --asdeps "${dependencias[@]}"
    fi
    if [[ -f $ultimo/sddm-antes.txt ]] && ! grep -qx enabled "$ultimo/sddm-antes.txt"; then
        x sudo systemctl disable sddm.service
    fi
    info "o Birfree continua instalado; o Plasma e o LXQt voltam a aparecer no SDDM"
}

# ------------------------------------------------------------ principal --
for arg in "$@"; do
    case $arg in
        --simular) SIMULAR=1 ;;
        --desfazer) ACAO=desfazer ;;
        --atualizar) ACAO=atualizar ;;
        --mostrar) ACAO=mostrar ;;
        -h | --help) sed -n '3,18p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) erro "opção desconhecida: $arg (veja --help)" ;;
    esac
done
((SIMULAR)) && printf '\033[1;33m  Modo --simular: nada será alterado.\033[0m\n'

if [[ $ACAO == desfazer ]]; then
    desfazer
    exit 0
fi

if [[ $ACAO == mostrar ]]; then
    [[ -x "$PACOTES_INSTALADOR" ]] || erro "--mostrar exige os pacotes prontos"
    exec "$PACOTES_INSTALADOR" --mostrar
fi
if [[ $ACAO == atualizar ]]; then
    conferir
    if ((SIMULAR)); then
        info "[simular] atualizar apenas Birfree; sem alterar repositórios ou sessões"
    elif [[ -x "$PACOTES_INSTALADOR" ]]; then
        exec "$PACOTES_INSTALADOR"
    else
        exec "$RAIZ/instalar.sh"
    fi
    exit 0
fi

conferir
if ((!SIMULAR)); then
    if ((REPOS_LOCAIS)); then
        printf '\nIsto usa os forks locais, mantém KDE/Qt em 01/10/2026, libera o resto do Arch e REMOVE as sessões Plasma/LXQt (com backup). Continuar? [s/N] '
    else
        printf '\nIsto usa o Arch Archive de 01/10/2026, instala o Birfree, configura o SDDM e REMOVE as sessões Plasma e LXQt (com backup). Continuar? [s/N] '
    fi
    read -r resposta
    [[ $resposta == [sS]* ]] || { echo "Nada foi mudado."; exit 0; }
fi
guardar_estado
travar_sistema
instalar_birfree
configurar_login
proteger
remover_plasma
remover_lxqt
resumo
