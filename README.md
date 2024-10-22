# Exhaust SSD

Writes zeroes from `/dev/zero` to `/opt/tmp` for 1 minute, in chunks of 1G.

Run via [cron](https://en.wikipedia.org/wiki/Cron):

```
* * * * * /bin/bash <ssd.sh>
```
