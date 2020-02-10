#!/bin/sh

if [ -e /var/run/secrets/kubernetes.io/serviceaccount/token ]; then
    token=`cat /var/run/secrets/kubernetes.io/serviceaccount/token`
    cat > /etc/nginx/token.conf << EOF
map \$host \$token {
    default "$token";
}
EOF
else
    cat > /etc/nginx/token.conf << EOF
map \$host \$token {
    default letmein;
}
EOF
fi

nginx -g 'daemon off;'