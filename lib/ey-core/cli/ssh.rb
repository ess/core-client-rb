require 'ey-core/util/server_sieve'

class Ey::Core::Cli::Ssh < Ey::Core::Cli::Subcommand
  title "ssh"
  summary "Open an SSH session to the environment's application master"
  option :account, short: "c", long: "account", description: "Name or id of account", argument: "account"
  option :environment, short: "e", long: "environment", description: "Name or id of environment", argument: "environment"
  option :server, short: 's', long: "server", description: "Specific server to ssh into. Id or amazon id (i-12345)", argument: "server"
  option :utilities, long: "utilities", description: "Run command on the utility servers with the given names. Specify all to run the command on all utility servers.", argument: "'all,resque,redis,etc'"
  option :command, long: "command", description: "Command to run", argument: "'command with args'"
  option :shell, short: 's', long: "shell", description: "Run command in a shell other than bash", argument: "shell"
  option :bind_address, long: "bind_address", description: "When no command is specified, pass -L to ssh", argument: "bind address"

  switch :all,         long: "all",         description: "Run command on all servers"
  switch :app_servers, long: "app_servers", description: "Run command on all application servers"
  switch :db_servers,  long: "db_servers",  description: "Run command on all database servers"
  switch :db_master,   long: "db_master",   description: "Run command on database master"
  switch :db_slaves,   long: "db_slaves",   description: "Run command on database slaves"
  switch :tty, short: 't', long: "tty",     description: "Allocated a tty for the command"

  def handle
    operator, environment = core_operator_and_environment_for(options)
    abort "Unable to find matching environment".red unless environment

    cmd      = option(:command)
    ssh_opts = []
    ssh_cmd  = ["ssh"]
    exits    = []
    user     = environment.username
    servers  = []



    if cmd
      if shell = option(:shell)
        cmd = Escape.shell_command([shell,'-lc',cmd])
      end

      if switch_active?(:tty)
        ssh_opts << "-t"
      elsif cmd.match(/sudo/)
        puts "sudo commands often need a tty to run correctly. Use -t option to spawn a tty.".yellow
      end

      servers += filtered_servers(environment)
    else
      if option(:bind_address)
        ssh_opts += ["-L", option(:bind_address)]
      end

      if option(:server)
        servers += [core_server_for(server: option[:server], operator: environment)]
      else
        servers += (environment.servers.all(role: "app_master") + environment.servers.all(role: "solo")).to_a
      end
    end

    if servers.empty?
      abort "Unable to find any matching servers. Aborting.".red
    end

    servers.each do |server|
      host = server.public_hostname
      name = server.name ? "#{server.role} (#{server.name})" : server.role
      puts "\nConnecting to #{name} #{host}".green
      sshcmd = Escape.shell_command((ssh_cmd + ["#{user}@#{host}"] + [cmd]).compact)
      puts "Running command: #{sshcmd}".green
      system sshcmd
      exits << $?.exitstatus
    end

    exit exits.detect {|status| status != 0 } || 0
  end

  def filtered_servers(environment)
    Ey::Core::Util::ServerSieve.filter(
        environment.servers,
        all: switch_active?(:all),
        app_servers: switch_active?(:app_servers),
        db_servers: switch_active?(:db_servers),
        db_master: switch_active?(:db_master),
        utilities: option(:utilities)
      )
  end

  #class ServerSieve
    #ROLES = [
      #:app_servers,
      #:db_servers,
      #:db_master,
      #:utilities
    #]

    #attr_reader :environment, :options

    #def self.filter(environment, options = {})
      #new(environment, options).filtered
    #end

    #def initialize(environment, options = {})
      #@environment = environment
      #@options = options
    #end

    #def filtered
      #return all_servers if requested?(:all)

      #requested_roles.map {|role|
        #role == :utilities ? utils_named(option(:utilities)) : send(role)
      #}.flatten.uniq
    #end

    #def requested_roles
      ##self.class::
      #ROLES.select {|role| requested?(role)}
    #end

    #def option(name)
      #options[name]
    #end

    #def requested?(name)
      #option(name)
    #end

    #def all_servers
      #environment.servers.all.to_a.uniq
    #end

    #def app_servers
      #['app_master', 'app', 'solo'].
        #map {|role| environment.servers.all(role: role).to_a}.
        #flatten
    #end

    #def db_servers
      #db_master + environment.servers.all(role: 'db_slave').to_a
    #end

    #def db_master
      #['db_master', 'solo'].
        #map {|role| environment.servers.all(role: role).to_a}.
        #flatten
    #end

    #def utils_named(name)
      #filter = {role: 'util'}
      #filter[:name] = name unless name.downcase == 'all'

      #environment.servers.all(filter).to_a
    #end

  #end
end
