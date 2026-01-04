# kops completion
if [ $commands[kops] ]; then
  source <(kops completion zsh)
fi

# kubectl aliases
if [ $commands[kubectl] ]; then
  alias k="kubectl"
  alias kg="k get"
  alias ke="k edit"
  alias kecm="k edit configmap"

  alias kn="k get nodes"
  alias ks="k get svc"
  alias kd="k get deployment"
  alias kp="k get pods"
  alias kpa="k get pods --all-namespaces"

  alias dsn="k describe node"
  alias dss="k describe svc"
  alias dsd="k describe deployment"
  alias dsr="k describe rs"
  alias dsp="k describe pod"

  alias kl="k logs --tail=50 --follow"
  alias kx="k exec"
  alias xx="k exec -ti"
  alias kcf="k create -f"
  alias kaf="k apply -f"
  alias kdf="k delete -f"
  alias ddd="k delete deployment"
  alias dds="k delete svc"
  alias ddp="k delete pod"
  alias kcm="k create configmap"
  alias kdm="k delete configmap"
  alias khpa="k get hpa"
fi

if [ $commands[helm] ]; then
  hi () {
    helm install --name "${SVC}-${ENV}" "charts/saas/${SVC}" -f "values/saas/${SVC}/${ENV}.yaml"
  }

  hu () {
    helm upgrade "${SVC}-${ENV}" "charts/saas/${SVC}" -f "values/saas/${SVC}/${ENV}.yaml"
  }
fi
