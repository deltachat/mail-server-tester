FROM rockylinux:8-minimal

RUN microdnf install -y sscg postfix cyrus-imapd cyrus-sasl-plain net-tools \
    && microdnf clean all \
    && rm -f /etc/pki/tls/private/postfix.key /etc/pki/tls/certs/postfix.pem \
    && rm -rf /usr/share/{doc,man}

RUN sed -ri \
    -e 's!sasl_pwcheck_method: saslauthd!sasl_pwcheck_method: alwaystrue!g' \
    -e 's!virtdomains: off!virtdomains: on!g' \
    /etc/imapd.conf \
    && printf 'autocreate_quota: 1000\nautocreate_post: 1\n' >> /etc/imapd.conf \
    && sed -ri \
    -e 's!^  pop3!#  pop3!g' \
    -e 's!^  http!#  http!g' \
    -e 's!^#  idled!  idled!g' \
    /etc/cyrus.conf

RUN postconf \
        inet_protocols=all \
        inet_interfaces=all \
        smtp_tls_CAfile=/etc/pki/postfix/postfix-ca.pem \
        smtpd_tls_key_file=/etc/pki/postfix/postfix-key.pem \
        smtpd_tls_cert_file=/etc/pki/postfix/postfix.pem \
        smtpd_sasl_auth_enable=yes \
        maillog_file=/dev/stdout \
        mydestination= \
        virtual_transport=lmtp:unix:/run/cyrus/socket/lmtp \
        virtual_mailbox_domains=localhost \
        virtual_mailbox_maps=hash:/etc/postfix/virtual_maps \
    && postconf -M smtps/inet="smtps inet n - n - - smtpd" \
    && postconf -F smtps/inet/command="smtpd -o syslog_name=postfix/smtps -o smtpd_tls_wrappermode=yes" \
    && echo "@localhost allow" > /etc/postfix/virtual_maps \
    && postmap hash:/etc/postfix/virtual_maps \
    && sed -ri -e 's!saslauthd!alwaystrue!g' /etc/sasl2/smtpd.conf

COPY --chmod=755 entrypoint.sh /usr/local/sbin/

EXPOSE 25 143 465 993 4190

HEALTHCHECK --interval=5s --retries=10 CMD netstat -ltn | grep -c :143 || exit 1

CMD /usr/local/sbin/entrypoint.sh

LABEL org.opencontainers.image.source https://github.com/deltachat/mail-server-tester
LABEL org.opencontainers.image.description "Spins up a cyrus-imapd and postfix server in a container for use with integration testing."
