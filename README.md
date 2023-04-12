# Delta Chat Mail Server Tester

This is a simple docker image setup that spins up a cyrus-imapd and postfix server in a single container for use with integration testing.

## Exposable ports
The docker exposes the following ports
 - 25 -- SMTP (with starttls)
 - 465 - SMTPS
 - 143 - IMAP (with starttls)
 - 993 - IMAPS
 - 4190 - SIEVE (with starttls)

## Configuration details

Postfix is configured to accept mail for anything @localhost
Cyrus Imapd is configured to accept any password.  So to login via imap simply pick your email (test@localhost) and choose any password to log in.
Cyrus imapd is also configured to auto create mailboxes on receiving email via postfix.

## Health check

The dockerfile is configured with a health check that checks that both cyrus and postfix are running and listening on their ports.  This can be useful for services such as Github actions to ensure that the service is fully ready.

## GitHub Action

Example usage in GitHub actions:

```yaml
name: Test

on:
  push:
    branches: [ "master" ]
  pull_request:
    branches: [ "master" ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run tests
        run: |
          # run tests here

    services:
      mail_server:
        image: ghcr.io/deltachat/mail-server-tester:release
        ports:
          - 3025:25
          - 3143:143
          - 3465:465
          - 3993:993
```
