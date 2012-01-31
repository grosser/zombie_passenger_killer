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
        -h, --help                       Show this.
        -v, --version                    Show Version


### Bluepill script

    app.process("zombie_passenger_killer") do |process|
      process.start_command = "zombie_passenger_killer --max 5 --history 10 --cpu 30 --interval 10"
      process.stdout = process.stderr = "/var/log/autorotate/zombie_passenger_killer.log"
      process.pid_file = "/var/run/zombie_passenger_killer.pid"
      process.daemonize = true
    end


### God script

# TODO

 - merge stuff from kmullin without changing all the defaults
 - bundler (modularize)
  https://github.com/kmullin/zombie_passenger_killer/commit/892e2598c5c419df8302128ee5f8deda1f141b6c
  https://github.com/kmullin/zombie_passenger_killer/commit/8837677e14fbb80b6b6e7604c99da47c3090a2ec
  https://github.com/kmullin/zombie_passenger_killer/commit/225b856f1b8ba3d2a61a042c125c0e5d898e1ea6
 - status check https://github.com/kmullin/zombie_passenger_killer/commit/4533cc464f45147ed594608e50804ea60b9c3434

Author
======

###Contributors
 - [Roman Heinrich](https://github.com/mindreframer)
 - [Kevin Mullin](https://github.com/kmullin)

[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
Hereby placed under public domain, do what you want, just do not hold me accountable...
