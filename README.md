# Exhaust SSD

Writes zeroes from `/dev/zero` to `/opt/tmp` for 1 minute, in chunks of 1G.

Run via [cron](https://en.wikipedia.org/wiki/Cron):

```
* * * * * /bin/bash <ssd.sh>
```

## Auto mode
Run the script in auto mode to automatically add the aforementioned cron job to the crontab:

```
# ./ssd.sh -auto
```

Tested on MacOS.
