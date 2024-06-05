#!/usr/bin/bash

common_apps=(
	"asdf-vm"
	"fzf"
	"pacman-mirrorlist"
	"reflector"
	"postgresql"
	"postgresql-docs"
	"postgresql-ip4r"
	"postgresql-libs"
	"mongodb-bin"
	"redis"
	"memcached"
	"libmemcached"
	"podman"
	"podman-compor"
	"podman-docker"
	"tmux"
	"goanime"
)

selectBestMirror() {
	sudo cp -r "/etc/pacman.d" "/etc/pacman.d.bkp"
	sudo reflector --latest 10 --country Brazil --protocol sftp,https --sort rate --save "/etc/pacman.d/mirrorlist"
}

install_chaotic_aur() {
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
	for item in ${common_apps[@]}; do
		sudo pacman -S "$item" --noconfirm
	done

}

configDB() {
	if [ ! -e '/var/lib/postgres/' ]; then
		sudo -u postgres initdb --locale $LANG -E UTF8 -D '/var/lib/postgres/data'
		sudo systemctl enable --now postgresql.service
		sudo -u postgres createuser --interactive
		sudo -u postgres createdb "$USER" + "db"
	fi
}

moveDotfiles() {
	sudo cp -r "$HOME/.config/nvim/" "$HOME/.config/nvim.bak"
	sudo cp -r "./nvim/" "$HOME/.config/nvim/"

	if [ ! -e "$HOME/.zshrc" ]; then
		sudo cp -r "./zsh/zshrc" "$HOME/.zshrc"
	fi

	if [ ! -e "$HOME/.aliasrc" ]; then
		sudo cp -r "./zsh/aliasrc" "$HOME/.aliasrc"
	fi

	sudo cp "./services/x11-symlink.service" "/etc/systemd/system/"
	sudo systemctl enable x11-symlink
}

init() {
	install_chaotic_aur
	install_apps
	selectBestMirror

	if [ ! -e "$HOME/.tool-versions" ]; then
		cp -r "./.tool-versions" $HOME/.tool-versions
		asdf install
	else
		asdf install
	fi
	configDB
}

init
