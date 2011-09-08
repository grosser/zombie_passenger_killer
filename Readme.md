Guaranteed zombie passengers death.

 - who are no longer in passenger-status
 - with high CPU load (Optional)

strace of killed zombies is printed, so debugging is easier.

(god/bluepill are not suited to monitor passenger apps because of ever-changing pids)

Add passenger-status to `/etc/sudoers` or run with sudo.

![Zombies on a train](http://www.motifake.com/image/demotivational-poster/1002/zombies-on-a-train-zombies-oh-shi-demotivational-poster-1265174018.jpg)

Install
=======
    sudo gem install zombie_passenger_killer
Or

    rails plugin install git://github.com/grosser/zombie_passenger_killer.git


Usage
=====
    CODE_EXAMPLE

Author
======
[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
Hereby placed under public domain, do what you want, just do not hold me accountable...
