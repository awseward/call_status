### Notes

- `*.service` files in `/etc/systemctl/system`
- Start @ boot: `systemctl enable <…>.service`
- `*.sh` files in `/usr/bin` (currently symlinked from my user's home), like so:
    ```
    $ ls -lah /usr/bin
    … root root … call_status_heartbeat_consumer.sh -> $HOME/call_status_heartbeat_consumer.sh
    … root root … call_status_poll.sh -> $HOME/call_status_poll.sh
    ```
- Tail logs: `journalctl -f -t call_status_poll -t call_status_heartbeat_consumer`
