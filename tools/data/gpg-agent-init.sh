export GNUPGHOME="$HOME"/.gnupg

SSH_ENV="$HOME/.ssh/agent-environment"
function start_ssh_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add
}

if [[ -f "${SSH_ENV}" ]]; then
    . "${SSH_ENV}"
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_ssh_agent;
    }
else
    start_agent;
fi

if [ -f "${HOME}/.gnupg/gpg-agent.env" ]; then
    source "${HOME}/.gnupg/gpg-agent.env"
    export GPG_AGENT_INFO
    export SSH_AUTH_SOCK
fi
export GPG_TTY=$(tty)
export GNUPGCONFIG=$"$HOME/.gnupg/gpg-agent.conf"
if grep -q enable-ssh-support "$GNUPGCONFIG"; then
  unset SSH_AGENT_PID
  export SSH_AUTH_SOCK=$GPG_AGENT_SOCKET
fi

if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

# set up a consistent SSH agent socket symlink
export SSH_AUTH_SOCK_LINK="/tmp/ssh-$USER/agent"
if [ ! -r $(readlink -m $SSH_AUTH_SOCK_LINK) ] && [ -r $SSH_AUTH_SOCK ]; then
      mkdir -p "$(dirname $SSH_AUTH_SOCK_LINK)" &&
      chmod go= "$(dirname $SSH_AUTH_SOCK_LINK)" &&
      ln -sfn $SSH_AUTH_SOCK $SSH_AUTH_SOCK_LINK
fi
