#!/usr/bin/bash

set -e          # Para encerrar o script ao encontrar um erro
set -u          # Para encerrar se houver uso de variáveis não definidas
set -o pipefail # Para garantir que erros em pipes sejam capturados

LOG_FILE="/var/log/script_install.log"
echo "Iniciando script em $(date)" | sudo tee -a "$LOG_FILE"

common_apps=(
	"mise"
	"fzf"
	"pacman-mirrorlist"
	"reflector"
	"postgresql"
	"postgresql-docs"
	"postgresql-ip4r"
	"postgresql-libs"
	"mongodb"
	"redis"
	"memcached"
	"libmemcached"
	"podman"
	"podman-docker"
	"tmux"
	"exa"
	"bat"
	"git-delta"
	"fzf"
	"lazygit"
	"lazydocker"
)

log() {
	echo "$(date) - $1" | sudo tee -a "$LOG_FILE"
}

selectBestMirror() {
	log "Selecionando melhor mirror..."
	sudo cp -r "/etc/pacman.d" "/etc/pacman.d.bkp"
	sudo reflector --latest 10 --country Brazil --protocol sftp,https --sort rate --save "/etc/pacman.d/mirrorlist"
}

install_chaotic_aur() {
	log "Instalando Chaotic AUR..."
	sudo pacman-key --init
	sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
	sudo pacman-key --lsign-key 3056513887B78AEB
	sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --noconfirm
	sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
	grep -qxF '[chaotic-aur]' /etc/pacman.conf || echo '[chaotic-aur]' | sudo tee -a /etc/pacman.conf
	grep -qxF 'Include = /etc/pacman.d/chaotic-mirrorlist' /etc/pacman.conf || echo 'Include = /etc/pacman.d/chaotic-mirrorlist' | sudo tee -a /etc/pacman.conf
	sudo pacman -Sy --noconfirm && sudo pacman -Syyuu --noconfirm
}

install_apps() {
	log "Instalando aplicativos..."
	for item in "${common_apps[@]}"; do
		log "Instalando $item"
		sudo pacman -S "$item" --noconfirm
	done
}

configDB() {
	log "Configurando banco de dados..."
	if [ ! -d '/var/lib/postgres/' ]; then
		sudo -u postgres initdb --locale "$LANG" -E UTF8 -D "/var/lib/postgres/data"
		sudo systemctl enable --now postgresql.service
		sudo -u postgres createuser --interactive
		sudo -u postgres createdb "${USER}db"
	fi
}

moveDotfiles() {
	log "Movendo arquivos de configuração..."
	if [ -e "$HOME/.config/nvim" ]; then
		cp -r "$HOME/.config/nvim/" "$HOME/.config/nvim.bak"
	fi
	cp -r "./nvim/" "$HOME/.config/nvim/"
	if [ ! -e "$HOME/.zshrc" ]; then
		cp -r "./zsh/zshrc" "$HOME/.zshrc"
	fi
	if [ ! -e "$HOME/.aliasrc" ]; then
		cp -r "./zsh/aliasrc" "$HOME/.aliasrc"
	fi
	sudo cp "./services/x11-symlink.service" "/etc/systemd/system/"
	sudo systemctl enable x11-symlink
}

init() {
	log "Iniciando setup do sistema..."
	install_chaotic_aur
	install_apps
	selectBestMirror
	configDB
	moveDotfiles
	log "Setup finalizado com sucesso!"
}

init
