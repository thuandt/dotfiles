# zsh completion for awscli
if [[ $(command -v aws_zsh_completer.sh) ]]; then
    # shellcheck disable=SC1090
    source "$(command -v aws_zsh_completer.sh)"
fi
