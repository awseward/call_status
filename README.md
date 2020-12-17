# call-status ![CI](https://github.com/awseward/call_status/workflows/CI/badge.svg)

### Installation & Usage

```sh
brew install awseward/homebrew-tap/call_status_checker
```

To follow the launchd service log:

```sh
tail -f /tmp/log/call_status_checker/watch.log
```

There's some potential for permissions issues-- in such cases, can run:

```sh
mkdir -p /tmp/log/call_status_checker
touch /usr/local/var/log/call_status_checker/watch.log
chown -R "${USER}" /usr/local/var/log/call_status_checker
```
