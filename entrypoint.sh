#!/bin/sh

if [ ! -f /etc/pki/cyrus-imapd/cyrus-imapd.pem ]; then
  echo "--- Generating Cyrus Certificates (in /etc/pki/cyrus-imapd)"
  sscg --package cyrus-imapd \
    --cert-file /etc/pki/cyrus-imapd/cyrus-imapd.pem \
    --cert-key-file /etc/pki/cyrus-imapd/cyrus-imapd-key.pem \
    --ca-file /etc/pki/cyrus-imapd/cyrus-imapd-ca.pem \
    --cert-key-mode=0640

  chown cyrus: /etc/pki/cyrus-imapd/*
  echo "--- Finished generating certificates"
fi

if [ ! -f /etc/pki/postfix/postfix.pem ]; then
  mkdir -p /etc/pki/postfix
  echo "--- Generating Postfix Certificates (in /etc/pki/postfix)"
  sscg --package postfix \
    --cert-file /etc/pki/postfix/postfix.pem \
    --cert-key-file /etc/pki/postfix/postfix-key.pem \
    --ca-file /etc/pki/postfix/postfix-ca.pem \
    --cert-key-mode=0640
  echo "--- Finished generating certificates"
fi

/usr/libexec/postfix/aliasesdb
/usr/libexec/postfix/chroot-update

/usr/sbin/postfix start-fg &
/usr/libexec/cyrus-imapd/cyrus-master &

wait -n

echo "Aborted"

kill %1 2>/dev/null
kill %2 2>/dev/null

