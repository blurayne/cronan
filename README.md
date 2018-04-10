# Cronan the ELKhunter

Cronan is a cron wrapper written as standalone bash script to solve some problems around either you are using Ubuntu Vixie cron (ISC) or Red Hat fork of Vixie (Cronie)that behave differently.

Please refer [Wikipedia cron](https://en.wikipedia.org/wiki/Cron), [Ubuntu Cron](https://wiki.ubuntuusers.de/Cron/) or [Red Hat Cronie](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/deployment_guide/ch-automating_system_tasks) for history and differences. 

## Status

**Work in progres - alpha quality! Do not yet use in production!**

## Features

- Integration with syslog (and therefore with rsyslog and the ELK stack)
- Run as shell within crontab
- Run as command line wrapper
- Better error emails (e.g. exit code in subject)
- Better handling of exit codes, stdout and stderr (only get emails if errors occured)
- Tests

## Planned 

- Merge output of STDOUT and STDERR together (-m). If you only specify stdout for log this occurs automaticaly<br/>
  (Note: sorting might not be possible if you only rely on timestamp in log lines)
- Rely more on environment vars (CRONAN_OPTS)
- Allow config files to overwrite environment
- Mutex locks
- Templates for E-Mail
- Templates for Logging (syslog, logfile, default), e.g. CRONAN_TPL_(FILE|SYSLOG|MAIL|EXT)_(OUT|ERR|CMD)
- Named Templates (like default, short, notime)
- Mutex locks
- Better control over output
- Pipe to external program (e.g. for HipChat)
- Template files (?)


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


## Usage

```
usage: cronan [options] [--] <command> [[arg0], [arg1], ..]

  -h, --help      show help
  -e, --stderr    log path for stderr
  -o, --stdout    log path for stdout
  -d, --debug     trace is done by bash's 
  -l, --label     label for syslog
  -s, --syslog    use syslog (respective rsyslog)
  -m, --email     Send email by cronan
  -a, --always    always send mail even if no error occurred
  --always        always do send error mails
  -x              don't prevail exit code and always exit with code 0
  --to            set email to-address (default: MAILTO)
  --from          set email from-address;
  --cc            set email cc-address;
  --bcc           set email bcc-address;
  -q, --quiet     no ouptut at all
```

Cronan output to cron only occurs on errors.

If you specify a logger like syslog or email output if not errors occur is suppressed (unless you specify the -a flag). 
Also, if logging to specified logger fails (e.g. sendmail) an output to stdout occurs.