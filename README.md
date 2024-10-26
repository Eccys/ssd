# Exhaust SSD

Writes data from `/dev/zero` to `/opt` with [dd](https://man7.org/linux/man-pages/man1/dd.1.html) to exhaust the [TBW](https://embeddedcomputing.com/technology/software-and-os/ides-application-programming/an-introduction-to-tbw-terabytes-written) of a solid state drive.

Run via [cron](https://en.wikipedia.org/wiki/Cron) (every minute):

```
* * * * * /bin/bash <ssd.sh>
```

## Auto mode
Run the script in auto mode to automatically add aforementioned cron job to the crontab:

```
# ./ssd.sh -auto
```

Tested on MacOS.
