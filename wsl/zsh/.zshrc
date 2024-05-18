# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
#

export PATH=$HOME/.local/bin:$HOME/go/bin:$HOME/.cargo/bin:$HOME/.yarn/bin/:$PATH

# Create a temporary learning directory in tmp/ from directory about repositories privated
if [ ! -d "/tmp/learning" ]; then
  mkdir -p "/tmp/learning" 
fi

# Create a directory project if not exists or change from her
if [ -d $HOME/Project ]; then
	cd $HOME/Project
else 
  mkdir -p $HOME/Project
  cd $HOME/Project
fi

# Load my .alias list in .aliasrc
if [ -f $HOME/.aliasrc ]; then
	source $HOME/.aliasrc
fi

# Load the cache about powerlevel10k with my configure 
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load the powerlevel10k theme
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# Load the asdf
source /opt/asdf-vm/asdf.sh


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

