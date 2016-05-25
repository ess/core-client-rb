require 'spec_helper'
require 'ey-core/cli'
require 'ey-core/cli/ssh'

describe Ey::Core::Cli::Ssh do
  let(:argv) {[]}
  let(:ssh) {described_class.new(argv)}

  let(:app_master_server) {Object.new}
  let(:app_slave_server) {Object.new}
  let(:solo_server) {Object.new}
  let(:db_master_server) {Object.new}
  let(:db_slave_server) {Object.new}
  let(:util_frank_server) {Object.new}
  let(:util_johnny_server) {Object.new}

  let(:all_apps) {[app_master_server, app_slave_server, solo_server]}
  let(:all_db_master) {[db_master_server, solo_server]}
  let(:all_dbs) {[db_master_server, db_slave_server, solo_server]}
  let(:all_utils) {[util_frank_server, util_johnny_server]}
  let(:all_servers) {all_apps + all_dbs + all_utils}

  let(:servers_api) {Object.new}
  let(:environment) {Object.new}

  before(:each) do
    allow(ssh).to receive(:switch_active?).and_return(nil)
    allow(environment).to receive(:servers).and_return(servers_api)
    allow(servers_api).to receive(:all).with(no_args).and_return(all_servers)

    allow(servers_api).
      to receive(:all).
      with(role: 'app_master').
      and_return([app_master_server])

    allow(servers_api).
      to receive(:all).
      with(role: 'solo').
      and_return([solo_server])

    allow(servers_api).
      to receive(:all).
      with(role: 'app').
      and_return([app_slave_server])

    allow(servers_api).
      to receive(:all).
      with(role: 'db_master').
      and_return([db_master_server])

    allow(servers_api).
      to receive(:all).
      with(role: 'solo').
      and_return([solo_server])

    allow(servers_api).
      to receive(:all).
      with(role: 'db_slave').
      and_return([db_slave_server])

    allow(servers_api).
      to receive(:all).
      with(role: 'db_master').
      and_return([db_master_server])

    allow(servers_api).
      to receive(:all).
      with(role: 'solo').
      and_return([solo_server])

    allow(servers_api).
      to receive(:all).
      with(role: 'db_slave').
      and_return([db_slave_server])

    allow(servers_api).
      to receive(:all).
      with(role: 'util').
      and_return(all_utils)

    allow(servers_api).
      to receive(:all).
      with(role: 'util', name: 'frank').
      and_return([util_frank_server])

  end

  describe '#filtered_servers' do
    let(:filtered_servers) {ssh.filtered_servers(environment)}

    context 'when all servers are requested' do
      before(:each) do
        allow(ssh).to receive(:switch_active?).with(:all).and_return(true)
      end

      it 'is all of the servers for the environment' do
        all_servers.each do |server|
          expect(filtered_servers).to include(server)
        end
      end
    end

    context 'when app servers are requested' do
      before(:each) do
        allow(ssh).
          to receive(:switch_active?).
          with(:app_servers).
          and_return(true)
      end

      it 'includes app_master servers' do
        expect(filtered_servers).to include(app_master_server)
      end

      it 'includes app (slave) servers' do
        expect(filtered_servers).to include(app_slave_server)
      end

      it 'includes solo servers' do
        expect(filtered_servers).to include(solo_server)
      end
    end

    context 'when db servers are requested' do
      before(:each) do
        allow(ssh).
          to receive(:switch_active?).
          with(:db_servers).
          and_return(true)

      end

      it 'includes db_master servers' do
        expect(filtered_servers).to include(db_master_server)
      end

      it 'includes db_slave servers' do
        expect(filtered_servers).to include(db_slave_server)
      end

      it 'includes solo servers' do
        expect(filtered_servers).to include(solo_server)
      end
    end

    context 'when db master is requested' do
      before(:each) do
        allow(ssh).
          to receive(:switch_active?).
          with(:db_master).
          and_return(true)

      end

      it 'includes db_master servers' do
        expect(filtered_servers).to include(db_master_server)
      end

      it 'includes solo servers' do
        expect(filtered_servers).to include(solo_server)
      end

      it 'excludes db_slave servers' do
        expect(filtered_servers).not_to include(db_slave_server)
      end
    end

    context 'when all utils are requested' do
      before(:each) do
        allow(ssh).
          to receive(:option).
          with(:utilities).
          and_return('all')

      end

      it 'includes all utility servers' do
        all_utils.each do |server|
          expect(filtered_servers).to include(server)
        end
      end
    end

    context 'when a specific util is requested' do
      before(:each) do
        allow(ssh).
          to receive(:option).
          with(:utilities).
          and_return('frank')

      end

      it 'includes the requested util' do
        expect(filtered_servers).to include(util_frank_server)
      end

      it 'excludes all other utils' do
        expect(filtered_servers).not_to include(util_johnny_server)
      end
    end

    context 'when multiple filters are active' do
      
      # Release the Kraken!
      before(:each) do
        allow(ssh).to receive(:switch_active?).with(:all).and_return(true)
        allow(ssh).to receive(:switch_active?).with(:app_servers).and_return(true)
        allow(ssh).to receive(:switch_active?).with(:db_servers).and_return(true)
        allow(ssh).to receive(:switch_active?).with(:db_master).and_return(true)
        allow(ssh).to receive(:option).with(:utilities).and_return('all')
      end

      it 'contains no duplicates' do
        all_servers.each do |server|
          count = filtered_servers.select {|item| item == server}.length
          expect(count).to eql(1)
        end
      end
    end

    context 'when no filters are provided' do
      it 'is empty' do
        expect(filtered_servers).to be_empty
      end
    end
  end

  #describe '#all' do
    #let(:all) {ssh.all(environment)}

    #it 'is an array' do
      #expect(all).to be_a(Array)
    #end

    #it 'is all of the servers in the environment' do
      #all_servers.each do |server|
        #expect(all).to include(server)
      #end
    #end
  #end

  #describe '#app_servers' do
    #let(:app_servers) {ssh.app_servers(environment)}

    #before(:each) do
      #allow(servers_api).
        #to receive(:all).
        #with(role: 'app_master').
        #and_return([app_master_server])

      #allow(servers_api).
        #to receive(:all).
        #with(role: 'solo').
        #and_return([solo_server])

      #allow(servers_api).
        #to receive(:all).
        #with(role: 'app').
        #and_return([app_slave_server])
    #end

    #it 'is an array' do
      #expect(app_servers).to be_a(Array)
    #end

    #it 'includes app_master servers' do
      #expect(app_servers).to include(app_master_server)
    #end

    #it 'includes app (slave) servers' do
      #expect(app_servers).to include(app_slave_server)
    #end

    #it 'includes solo servers' do
      #expect(app_servers).to include(solo_server)
    #end
  #end

  #describe '#db_master' do
    #let(:db_master) {ssh.db_master(environment)}

    #before(:each) do
      #allow(servers_api).
        #to receive(:all).
        #with(role: 'db_master').
        #and_return([db_master_server])

      #allow(servers_api).
        #to receive(:all).
        #with(role: 'solo').
        #and_return([solo_server])

      #allow(servers_api).
        #to receive(:all).
        #with(role: 'db_slave').
        #and_return([db_slave_server])
    #end

    #it 'is an array' do
      #expect(db_master).to be_a(Array)
    #end

    #it 'includes db_master servers' do
      #expect(db_master).to include(db_master_server)
    #end

    #it 'excludes db_slave servers' do
      #expect(db_master).not_to include(db_slave_server)
    #end

    #it 'includes solo servers' do
      #expect(db_master).to include(solo_server)
    #end
  #end


  #describe '#db_servers' do
    #let(:db_servers) {ssh.db_servers(environment)}

    #before(:each) do
      #allow(servers_api).
        #to receive(:all).
        #with(role: 'db_master').
        #and_return([db_master_server])

      #allow(servers_api).
        #to receive(:all).
        #with(role: 'solo').
        #and_return([solo_server])

      #allow(servers_api).
        #to receive(:all).
        #with(role: 'db_slave').
        #and_return([db_slave_server])
    #end

    #it 'is an array' do
      #expect(db_servers).to be_a(Array)
    #end

    #it 'includes db_master servers' do
      #expect(db_servers).to include(db_master_server)
    #end

    #it 'includes db_slave servers' do
      #expect(db_servers).to include(db_slave_server)
    #end

    #it 'includes solo servers' do
      #expect(db_servers).to include(solo_server)
    #end
  #end

  #describe '#utils_named' do
    #let(:name) {''}
    #let(:utils_named) {ssh.utils_named(environment, name)}

    #it 'is an array' do
      #expect(utils_named).to be_a(Array)
    #end

    #context 'when all utils are requested' do
      #let(:name) {'all'}

      #before(:each) do
        #allow(servers_api).
          #to receive(:all).
          #with(role: 'util').
          #and_return(all_utils)
      #end

      #it 'is all of the util servers from the environment' do
        #expect(utils_named).to eql(all_utils)
      #end
    #end

    #context 'when a specific util name is given' do
      #let(:frank) {[util_frank_server]}
      #let(:name) {'frank'}

      #before(:each) do
        #allow(servers_api).
          #to receive(:all).
          #with(role: 'util', name: 'frank').
          #and_return(frank)
      #end

      #it 'only the requested util is included' do
        #expect(utils_named).to eql(frank)
      #end
    #end
  #end
end
