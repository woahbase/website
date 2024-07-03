| CROND_ARGS | -f -S -l 5    | Customizable arguments passed to `cron` daemon.                                                                                    |
| CROND_CONF | /etc/crontabs | Default file to read configurations from. By default this file enables scripts from `/etc/periodic` to be executed. |
| SKIP_CRON  | unset         | Set to `true` to skip starting `cron` daemon.                                                                       |
