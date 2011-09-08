class ZombiePassengerKiller
  VERSION = File.read( File.join(File.dirname(__FILE__),'..','VERSION') ).strip

  def initialize(options)
    @CPU_HISTORY = {}
    @MAX_HISTORY = options[:history] || 5
    @MAX_FAILS = options[:max]
    @MAX_CPU = options[:cpu] || 70
    @GRACE_TIME = options[:grace] || 5
    @INTERVAL = options[:interval] || 5
    @PASSENGER_PROCESS_PATTERN = options[:pattern] || ' Rack: '
  end

  def store_current_cpu(processes)
    keys_to_remove = @CPU_HISTORY.keys - processes.map{|x| x[:pid] }
    keys_to_remove.each{|k| !@CPU_HISTORY.delete k }

    processes.each do |process|
      @CPU_HISTORY[process[:pid]] ||= []
      @CPU_HISTORY[process[:pid]] << process[:cpu]
      @CPU_HISTORY[process[:pid]] = @CPU_HISTORY[process[:pid]].last(@MAX_HISTORY)
    end
  end

  def get_strace(pid, time)
    %x(timeout #{time} strace -p #{pid} 2>&1) if system("which timeout > /dev/null")
  end

  def hunt_zombies
    active_pids_in_passenger_status = passenger_pids
    active_processes_in_processlist = process_status
    zombies = active_processes_in_processlist.map{|x| x[:pid] } - active_pids_in_passenger_status

    # kill processes with high CPU if user wants it
    high_load = if @MAX_FAILS
      store_current_cpu active_processes_in_processlist
      active_pids_in_passenger_status.select do |pid|
        @CPU_HISTORY[pid].count{|x| x > @MAX_CPU } >= @MAX_FAILS
      end
    else
      []
    end

    (high_load + zombies).each do |pid|
      kill_zombie pid
    end
  end

  def passenger_pids
    %x(passenger-status|grep PID).split("\n").map{|x| x.strip.match(/PID: \d*/).to_s.split[1]}.map(&:to_i)
  end

  def process_status
    %x(ps -eo pid,pcpu,args|grep -v grep|grep '#{@PASSENGER_PROCESS_PATTERN}').split("\n").map do |line|
       values = line.strip.split[0..1]
       {:pid => values.first.to_i, :cpu => values.last.to_f}
    end
  end

  def kill_zombie(pid)
    puts "Killing passenger process #{pid}"
    puts get_strace(pid, 5)
    puts %x(kill #{pid})
    sleep @GRACE_TIME
    %x(kill -9 #{pid})
  end
end
