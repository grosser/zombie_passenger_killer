![Zombies on a train](http://www.motifake.com/image/demotivational-poster/1002/zombies-on-a-train-zombies-oh-shi-demotivational-poster-1265174018.jpg)

Guaranteed zombie passengers death.

 - who are no longer in passenger-status
 - with high CPU load (Optional)

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
        -m, --max [SIZE]                 Max high CPU entries in history before killing
            --history [SIZE]             History size
        -c, --cpu [PERCENT]              Mark as high CPU when above PERCENT
        -g, --grace [SECONDS]            Wait SECONDS before hard-killing (-9) a process
        -i, --interval [SECONDS]         Check every SECONDS
        -p, --pattern [PATTERN]          Find processes with this pattern
        -h, --help                       Show this.
        -v, --version                    Show Version


Author
======

###Contributors
 - [mindreframer](https://github.com/mindreframer)

[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
Hereby placed under public domain, do what you want, just do not hold me accountable...
