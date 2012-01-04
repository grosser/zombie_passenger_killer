require 'timeout'

class ZombiePassengerKiller
  VERSION = File.read( File.join(File.dirname(__FILE__),'..','VERSION') ).strip

  def initialize(options)
    @history = {}
    @history_entries = options[:history] || 5
    @max_high_cpu = options[:max]
    @high_cpu = options[:cpu] || 70
    @grace_time = options[:grace] || 10
    @pattern = options[:pattern] || 'Rails:'
  end

  def store_current_cpu(processes)
    keys_to_remove = @history.keys - processes.map{|x| x[:pid] }
    keys_to_remove.each{|k| !@history.delete k }

    processes.each do |process|
      @history[process[:pid]] ||= []
      @history[process[:pid]] << process[:cpu]
      @history[process[:pid]] = @history[process[:pid]].last(@history_entries)
    end
  end

  def get_strace(pid, time)
    `( strace -p #{pid} 2>&1 ) & sleep #{time} ; kill $!`
  end

  def hunt_zombies
    active_pids_in_passenger_status = passenger_pids
    active_processes_in_processlist = process_status
    zombies = active_processes_in_processlist.map{|x| x[:pid] } - active_pids_in_passenger_status

    # kill processes with high CPU if user wants it
    high_load = if @max_high_cpu
      store_current_cpu active_processes_in_processlist
      active_pids_in_passenger_status.select do |pid|
        @history[pid].count{|x| x > @high_cpu } >= @max_high_cpu
      end
    else
      []
    end

    (high_load + zombies).each do |pid|
      kill_zombie pid
    end
  end

  def passenger_pids
    %x(sudo passenger-status|grep PID).split("\n").map{|x| x.strip.match(/PID: \d*/).to_s.split[1]}.map(&:to_i)
  end

  def process_status
    %x(ps -eo pid,pcpu,args|grep -v grep|grep '#{@pattern}').split("\n").map do |line|
       values = line.strip.split[0..1]
       {:pid => values.first.to_i, :cpu => values.last.to_f}
    end
  end

  def kill_zombie(pid)
    log "Killing passenger process #{pid}"
    log get_strace(pid, 5)
    Process.kill('TERM', pid)
    sleep @grace_time
    Process.kill('KILL', pid) if Process.getpgid(pid) rescue nil
  end

  def log(s)
    puts "** [#{Time.now}] #$$: #{s}" unless s.empty?
  end

end
