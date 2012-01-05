require File.expand_path('spec/spec_helper')

describe ZombiePassengerKiller do
  let(:killer){
    k = ZombiePassengerKiller.new(@options || {})
    k.stub!(:passenger_pids).and_return([111])
    k
  }

  it "has a VERSION" do
    ZombiePassengerKiller::VERSION.should =~ /^\d+\.\d+\.\d+$/
  end

  describe "#hunt_zombies" do
    it "does not kill anything by default" do
      killer.should_not_receive(:kill_zombie)
      killer.hunt_zombies
    end

    it "finds the right zombies" do
      killer.stub!(:passenger_pids).and_return([123])
      killer.stub!(:process_status).and_return([{:pid => 124, :cpu => 0}])
      killer.should_receive(:kill_zombie).with(124)
      killer.hunt_zombies
    end

    it "kills zombies with high cpu over max" do
      @options = {:max => 1}
      killer.stub!(:process_status).and_return([{:pid => 111, :cpu => 100}])
      killer.should_receive(:kill_zombie).with(111)
      killer.hunt_zombies
    end

    it "does not kills zombies with high cpu under max" do
      @options = {:max => 2}
      killer.stub!(:process_status).and_return([{:pid => 111, :cpu => 100}])
      killer.should_not_receive(:kill_zombie).with(111)
      killer.hunt_zombies
    end

    it "ignores high cpu levels in old history" do
      @options = {:max => 2, :history => 2}
      killer.should_not_receive(:kill_zombie).with(111)
      killer.stub!(:process_status).and_return([{:pid => 111, :cpu => 100}])
      killer.hunt_zombies
      killer.stub!(:process_status).and_return([{:pid => 111, :cpu => 0}])
      killer.hunt_zombies
      killer.stub!(:process_status).and_return([{:pid => 111, :cpu => 100}])
      killer.hunt_zombies
    end

    it "kills on high cpu levels in recent history" do
      @options = {:max => 2, :history => 2}
      killer.stub!(:process_status).and_return([{:pid => 111, :cpu => 100}])
      killer.hunt_zombies
      killer.should_receive(:kill_zombie).with(111)
      killer.hunt_zombies
    end
  end

  describe "#kill_zombies" do
    before do
      killer.out = StringIO.new
      killer.instance_eval{
        @grace_time = 0.1
        @strace_time = 0.1
      }
    end

    def pid_of(marker)
      processes = `ps -ef | grep '#{marker}' | grep -v grep`
      processes.strip.split("\n").last.split(/\s+/)[1].to_i
    end

    def start_bogus_process(options={})
      marker = "TEST---#{rand(999999999999)}"
      Thread.new do
        `ruby -e 'at_exit{ puts "proper exit"; #{'sleep 10' if options[:hang]}}; sleep 10; puts "#{marker}"' 2>&1`
      end
      sleep 1 # give process time to spin up
      pid_of(marker)
    end

    def process_alive?(pid)
      Process.getpgid(pid)
    rescue Errno::ESRCH
      false
    end

    def output
      killer.out.rewind
      killer.out.read
    end

    it "kills normal processes" do
      pid = start_bogus_process
      lambda{
        killer.kill_zombie(pid)
        sleep 0.1
      }.should change{ process_alive?(pid) }
    end

    it "kills hanging processes" do
      pid = start_bogus_process :hang => true
      lambda{
        killer.kill_zombie(pid)
        sleep 0.1
      }.should change{ process_alive?(pid) }
    end

    it "prints an strace of the process" do
      pid = start_bogus_process
      killer.kill_zombie(pid)
      output.should include('attach:')
    end

    it "does not take a strace of a dead process" do
      killer.kill_zombie(111)
      output.should_not include('attach:')
    end

    it "does not fail with an unknown pid" do
      killer.kill_zombie(111)
      output.should include('No such process')
    end
  end

  describe "cli" do
    it "prints its version" do
      `./bin/zombie_passenger_killer -v`.should =~ /^\d+\.\d+\.\d+$/m
    end

    it "prints help" do
      `./bin/zombie_passenger_killer -h`.should include('Usage')
    end
  end
end
