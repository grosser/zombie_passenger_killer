require File.expand_path('spec/spec_helper')

describe ZombiePassengerKiller do
  let(:killer){
    k = ZombiePassengerKiller::Reaper.new(@options || {})
    k.stub!(:passenger_pids).and_return([111])
    k
  }

  it "has a VERSION" do
    ZombiePassengerKiller::VERSION.should =~ /^\d+\.\d+\.\d+$/
  end

  it "does not kill anything by default" do
    killer.should_not_receive(:kill_zombie)
    killer.hunt_zombies
  end

  it "kill zombies" do
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

  it "prints its version" do
    `./bin/zombie_passenger_killer -v`.should =~ /^\d+\.\d+\.\d+$/m
  end

  it "prints help" do
    `./bin/zombie_passenger_killer -h`.should include('Usage')
  end
end
