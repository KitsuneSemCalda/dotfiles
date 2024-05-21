#!/usr/bin/env bash

program_install_list=(
	"fastfetch"
	"zsh"
	"vhs"
	"asdf"
	"git"
	"curl"
)

asdf_install_list=(
	"neovim"
	"golang"
	"erlang"
	"elixir"
	"nodejs"
	"hugo"
)

# Function to move dotfiles
createDotfiles() {
	if [ ! -d "$HOME/.config/myDotfiles/" ]; then
		printf "%s\n" "$HOME/.config/myDotfiles/ not found, create the directory"
		mkdir -p "$HOME/.config/myDotfiles"
	else
		printf "%s\n" "$HOME/.config/myDotfiles/ founded, delete him and recreate with updates"
		rm -rf "$HOME/.config/myDotfiles/"
		rm "$HOME/.zshrc"
		rm "$HOME/.aliasrc"
		mkdir -p "$HOME/.config/myDotfiles"
	fi
	printf "%s\n" "copying values of ../wsl from $HOME/.config/myDotfiles"
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

	yay -S --noconfirm "base-devel" >/dev/null 2>&1
}

# Function to install all programs in program_install_list
RunInstall() {
	for name in "${program_install_list[@]}"; do
		printf "Install the app %s\n" "$name"
		install_program "$name"
	done
}

# Unify all function to get plugin, install latest and set global
RunAsdf() {
	adding_asdf_plugin
	install_asdf_plugin >/dev/null 2>&1
	set_global_asdf_plugin >/dev/null 2>&1
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

start() {
	# Check if we run the command in WSL
	if [ ! "$WSL_DISTRO_NAME" == "Arch" ]; then
		printf "This script is builded to run in WSL\n"
		exit 1
	fi

	CheckInstaller
	createDotfiles
	RunInstall
	RunAsdf

	if [ ! "$SHELL" == "/bin/zsh" ]; then
		printf "The default shell isn't zsh but the %s instead\n" "$SHELL"
		chsh -s /bin/zsh
	fi

	printf "WSL installed with sucess"
}

start
