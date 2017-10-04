# Google Cloud SDK
if [[ "$OSTYPE" = darwin* ]] ; then
    # shellcheck disable=1091
    source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
    # shellcheck disable=1091
    source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
else
    # shellcheck disable=1090
    source "${HOME}/Applications/google-cloud-sdk/path.zsh.inc"
    # shellcheck disable=1090
    source "${HOME}/Applications/google-cloud-sdk/completion.zsh.inc"
fi
