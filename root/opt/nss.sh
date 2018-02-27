export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

envsubst < /opt/passwd.template > /tmp/passwd

export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/etc/group

PS1="\${debian_chroot:+(\$debian_chroot)}$(whoami)@\h:\w\\$ "

