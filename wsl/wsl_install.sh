#!/usr/bin/env bash

program_install_list=(
	"fastfetch"
	"zsh"
	"exa"
	"duf"
	"fzf"
	"vhs"
	"asdf"
	"git"
	"curl"
	"bat"
)

asdf_install_list=(
	"rust"
	"neovim"
	"golang"
	"erlang"
	"elixir"
	"nodejs"
	"hugo"
)

ifExistsCopy() {
	src=$1
	dest=$2

	if [ -e "$dest" ]; then
		cp -r "$src" "$dest"
	fi
}

ifExistsDelete() {
	if [ -e "$1" ]; then
		printf "%s exists delete him\n" "$1"
		rm -rf "$1"
	fi
}

ifExistsCreateBackup() {
	if [ -e "$1" ]; then
		printf "%s exists create a backup\n" "$1"
		mv "$1" "$1.bak"
	fi
}

# Function to move dotfiles
CreateDotfiles() {
	ifExistsDelete "$HOME/.config/myDotfiles/"
	ifExistsDelete "$HOME/.config/nvim.bak/"
	ifExistsCreateBackup "$HOME/.config/nvim"

	printf "%s\n" "copying values of ../wsl from $HOME/.config/myDotfiles"

	mkdir -p "$HOME/.config/myDotfiles/"
	cp -r "../wsl/zsh/" "$HOME/.config/myDotfiles"
	cp -r "../wsl/nvim/" "$HOME/.config/nvim"

	ln -sf "$HOME/.config/myDotfiles/zsh/zshrc" "$HOME/.zshrc"
	ln -sf "$HOME/.config/myDotfiles/zsh/aliasrc" "$HOME/.aliasrc"
}

# Function to adding plugin's in asdf
adding_asdf_plugin() {
	for plugin in "${asdf_install_list[@]}"; do
		printf "adding asdf plugin: %s\n" "$plugin"
		asdf plugin add "$plugin" >/dev/null 2>&1
	done
}

# Function to install the latest language version
install_asdf_plugin() {
	plugins=$(asdf plugin list)

	for plugin in "${plugins[@]}"; do
		printf "install asdf plugin: %s\n" "$plugin"
		asdf install "$plugin" latest >/dev/null 2>&1
	done
}

# Function to set latest version global
set_global_asdf_plugin() {
	plugins=$(asdf plugin list)

	for plugin in "${plugins[@]}"; do
		printf "set %s plugin in latest version globally\n" "$plugin"
		asdf global "$plugin" latest >/dev/null 2>&1
	done
}

# Generic function to check if programs are installed
are_installed() {
	local program="$1"

	if command -v "$program" >/dev/null 2>&1; then
		return 0
	fi

	return 1
}

# Generic function to install a program if not installed
install_program() {
	local program="$1"

	if ! are_installed "$program"; then
		printf "the program %s is not found install him\n" "$program"
		yay -S --noconfirm "$program" >/dev/null 2>&1
	fi
}

# Function to install all programs in program_install_list
RunInstall() {
	for name in "${program_install_list[@]}"; do
		printf "Install the app %s\n" "$name"
		install_program "$name"
	done

	printf "Install the app %s\n" "base-devel"
	sudo pacman -S --noconfirm "base-devel"
}

# Unify all function to get plugin, install latest and set global
RunAsdf() {
	adding_asdf_plugin
	install_asdf_plugin
	set_global_asdf_plugin
}

# Function to check if has yay and install him
CheckInstaller() {
	# Running a forced update in ArchWSL
	printf "Running a forced update may take a while\n"
	sudo pacman -Syyuu --noconfirm >/dev/null

	# Install default installer from yay
	if are_installed "pacman" && ! are_installed "yay"; then
		printf "Yay dont founded, install Yay\n"
		pacman -S --needed --noconfirm git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && rm -rf "../yay"
	fi

	printf "Everything is OK, continue the install\n"
}

AddingServices() {
	if [ -e "/etc/systemd/system/x11-symlink.service" ]; then
		ifExistsDelete "/etc/systemd/system/x11-symlink.service"
		ifExistsCopy "./services/x11-symlink.service" "/etc/systemd/system/x11-symlink.service"
		sudo systemctl enable x11-symlink
		sudo systemctl start x11-symlink
	fi
}

start() {
	# Check if we run the command in WSL
	if [ ! "$WSL_DISTRO_NAME" == "Arch" ]; then
		printf "This script is builded to run in WSL\n"
		exit 1
	fi

	# Enable the service to fix bug in WSLg

	CheckInstaller
	AddingServices
	RunInstall
	RunAsdf >/dev/null 2>&1

	if [ ! "$SHELL" == "/bin/zsh" ]; then
		printf "The default shell isn't zsh but the %s instead\n" "$SHELL"
		chsh -s /bin/zsh
	fi

	CreateDotfiles
	printf "WSL installed with sucess\n"
}

start
