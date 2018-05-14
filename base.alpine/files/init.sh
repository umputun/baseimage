#!/sbin/dinit /bin/sh
echo "init"

if [ -f "/srv/init.sh" ]; then
    echo "execute /srv/init.sh"
    chmod +x /srv/init.sh
    /srv/init.sh
    if [ "$?" -ne "0" ]; then
      echo "/srv/init.sh failed"
      exit 1
    fi
fi

echo "execute $@"
$@
