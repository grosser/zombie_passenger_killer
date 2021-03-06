module ZombiePassengerKiller
  class Reaper

    attr_accessor :out # overwriteable for tests

    def initialize(options)
      @history = {}
      @history_entries = options[:history] || 5
      @max_high_cpu = options[:max]
      @high_cpu = options[:cpu] || 70
      @grace_time = options[:grace] || 5
      @pattern = options[:pattern] || ' Rack: '
      @show_times = options[:show_times] || false
      @interval = options[:interval] || 10
      @verbose = options[:verbose]
      @strace_time = 5
      @out = STDOUT
      @rvmsudo = options[:rvmsudo]
    end

    def lurk
      loop do
        hunt_zombies
        sleep @interval
      end
    rescue Interrupt
      log "Exiting..."
      raise $!
    end

    def hunt_zombies
      return unless active_pids_in_passenger_status = passenger_pids
      puts "Active pids in status: #{active_pids_in_passenger_status.inspect}" if @verbose

      active_processes_in_processlist = process_status
      puts "Active pids in processlist: #{active_processes_in_processlist.inspect}" if @verbose

      zombies = active_processes_in_processlist.map{|x| x[:pid] } - active_pids_in_passenger_status rescue Array.new
      puts "Zombies: #{zombies.inspect}" if @verbose

      # kill processes with high CPU if user wants it
      high_load = if @max_high_cpu
        store_current_cpu active_processes_in_processlist
        active_pids_in_passenger_status.select do |pid|
          (@history[pid] || []).count{|x| x > @high_cpu } >= @max_high_cpu
        end
      else
        []
      end

      (high_load + zombies).each do |pid|
        kill_zombie pid
      end
    end

    private

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
      Process.getpgid(pid) rescue return 'No such process'
      `( strace -p #{pid} 2>&1 ) & sleep #{time} ; kill $! 2>&1`
    end

    # return array of pids reported from passenger-status command, nil if passenger doesn't run
    def passenger_pids
      pids = %x(#{'rvmsudo ' if @rvmsudo}passenger-status).split("\n").map { |l| l[/PID: (\d+)/, 1] }.compact.map(&:to_i)
      if $?.success?
        pids
      else
        warn "passenger-status returned a #{$?.exitstatus} exit code. Please check if passenger-status is working properly."
        nil
      end
    end

    def process_status
      %x(ps -eo pid,pcpu,args|grep -v grep|grep -v zombie_passenger_killer|egrep '#{@pattern}').split("\n").map do |line|
        values = line.strip.split[0..1]
        {:pid => values.first.to_i, :cpu => values.last.to_f}
      end
    end

    def kill_zombie(pid)
      log "Killing passenger process #{pid}"
      log get_strace(pid, @strace_time)
      Process.kill('TERM', pid) rescue nil
      sleep @grace_time # wait for it to die
      Process.kill('KILL', pid) rescue nil
    end

    def log(msg)
      @out.puts "#{@show_times ? "** [#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] #$$: " : ''}#{msg}"
    end
  end
end
