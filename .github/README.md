# Steps for setup

Inspired by [Atlassian dotfiles suggestion](https://www.atlassian.com/git/tutorials/dotfiles).

1. [Install homebrew](https://docs.brew.sh/Installation)
1. [Install zsh](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH)
1. Install brew packages: `brew bundle install`
1. Install npm packages: `npm i -g $(cat $HOME/.dotfiles/npm_packages.txt)`
1. [Follow dotfiles setup for new machine](https://www.atlassian.com/git/tutorials/dotfiles)
1. Setup OS-specific things
1. Keep restarting shell and fixing errors. There should be comments above the script errors for what's missing.
1. Install [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono)

## Updating Installed Packages

- For homebrew: `brew bundle dump --force`
- For npm: `volta list --format plain | rg 'package ' | sed 's/package \([^@]*\)@.*/\1/' > $HOME/.dotfiles/npm_packages.txt`
