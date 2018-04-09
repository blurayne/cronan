# Cronan the ELKhunter

Cronan is a cron wrapper written as standalone bash script to solve some problems around either you are using Ubuntu Vixie cron (ISC) or Red Hat fork of Vixie (Cronie)that behave differently.

Please refer [Wikipedia cron](https://en.wikipedia.org/wiki/Cron), [Ubuntu Cron](https://wiki.ubuntuusers.de/Cron/) or [Red Hat Cronie](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/deployment_guide/ch-automating_system_tasks) for history and differences. 

## Status

Work in progres - alpha quality! Do not yet use in production!


## Features

- Integration with syslog (and therefore with rsyslog and the ELK stack)
- Run as shell within crontab
- Run as command line wrapper
- Better error emails (Exit code in subject)
- Better handling of exit codes, stdout and stderr (only get emails if errors occured)
- Tests

## Future 

- Semaphores
 
## Replacement

### As shell replacement
```
SHELL=/usr/local/bin/cronan
CRONAN_FLAGS="-a"
MAILTO=user@example.com

00 06 * * * /usr/local/bin/dosomething
```

### As wrapper

**Usage**
```
cronan [options] -- <command> [[arg0], [arg1], ..]
cronan [options] "<command> [[arg0], [arg1], ..]"
```
    
**Either with speration by "--"**
```
00 06 * * * cronan -m --to user1@example.com -- /usr/local/bin/generate-report daily "my name"
00 06 * * * cronan -m --to user2@example.com -- /usr/local/bin/cleanup
```

**Or with quoting**
```
00 06 * * * cronan -m --to user1@example.com "/usr/local/bin/generate-report daily \"my name\""
00 06 * * * cronan -m --to user2@example.com "/usr/local/bin/cleanup"
```

