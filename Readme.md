![Zombies on a train](http://dl.dropbox.com/u/2670385/Web/zombie.jpeg)

Guaranteed zombie passengers death.

 - passenger process no longer listed in passenger-status ? => Death
 - high CPU load over long period (Optional) ? => Death

strace of killed zombies is printed, so debugging is easier.

(god/bluepill are not suited to monitor passenger apps because of ever-changing pids)

Add passenger-status to `/etc/sudoers` or run with sudo.

Install
=======
    sudo gem install zombie_passenger_killer

Usage
=====

    zombie_passenger_killer [options]

    Options:
        -m, --max [SIZE]                 Max high CPU entries in history before killing (default: off)
            --history [SIZE]             History size (default: 5)
        -c, --cpu [PERCENT]              Mark as high CPU when above PERCENT (default: 70)
        -g, --grace [SECONDS]            Wait SECONDS before hard-killing (-9) a process (default: 5)
        -i, --interval [SECONDS]         Check every SECONDS (default: 10)
        -p, --pattern [PATTERN]          Find processes with this pattern (default: ' Rack: ')
        -1, --once                       Check once and exit
        --rvmsudo                        Use `rvmsudo` to see passenger-status
        -h, --help                       Show this
        -v, --version                    Show Version
        -t, --time                       Show time in output


### Bluepill script

    app.process("zombie_passenger_killer") do |process|
      process.start_command = "zombie_passenger_killer --max 5 --history 10 --cpu 30 --interval 10"
      process.stdout = process.stderr = "/var/log/autorotate/zombie_passenger_killer.log"
      process.pid_file = "/var/run/zombie_passenger_killer.pid"
      process.daemonize = true
    end

### Monit script

    check process zombie_killer
      with pidfile "/var/run/zombie_passenger_killer.pid"
      start program = "/bin/bash -c 'export PATH=$PATH:/usr/local/bin HOME=/home;zombie_passenger_killer --max 5 --history 10 --cpu 30 --interval 10 &>/var/log/zombie_passenger_killer.log & &>/dev/null;echo $! > /var/run/zombie_passenger_killer.pid'"
      stop program = "/bin/bash -c 'PIDF=/var/run/zombie_passenger_killer.pid;/bin/kill `cat $PIDF` && rm -f $PIDF'"
      group zombie_killer

### God script

# TODO

Author
======

###Contributors
 - [Roman Heinrich](https://github.com/mindreframer)
 - [Kevin Mullin](https://github.com/kmullin)
 - [Valery Vishnyakov](https://github.com/balepc)

[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
Hereby placed under public domain, do what you want, just do not hold me accountable...
