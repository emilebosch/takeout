require 'json'
require 'securerandom'
require './lib/server_builder.rb'

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :scm, :git
set :use_sudo, false

before "deploy:finalize_update" do
  run "rm -f #{release_path}/config/database.yml; ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  run "mkdir -p #{release_path}/tmp"
  run "ln -nfs #{shared_path}/sockets #{release_path}/tmp/sockets"
end

def template(source, destination, replace={})
    contents = File.read("./lib/templates/#{source}.template")
    replace.each { | k,v | contents = contents.gsub k.to_s, v.to_s }
    File.write destination, contents
    puts "  Template: -> File written to: #{destination}"
    destination
end

namespace :takeout do

  desc "Write a config/server.rb file"
  task :init do
    `mkdir -p ./config/apps`

    if !self[:serverip] || !self[:serveruser]
      puts "Usage: bundle exec cap takout:init -s serverip=<ip-address> -s serveruser=<username>"
      exit
    end

    template "server.rb", "./config/server.rb", {
      SERVERIP: self[:serverip],
      SERVERUSER: self[:serveruser],
      DBPASSWORD: SecureRandom.hex
    }

    template "server_config.rb", "./config/server_config.rb"
    puts "run 'bundle exec cap takeout:bootstrap' to prep your server.."
  end

  desc "Copies your id.pub, performs password-less magic, installs chef"
  task :bootstrap do
    find_servers_for_task(current_task).each do |current_server|
      system "cat ~/.ssh/id_rsa.pub | ssh #{user}@#{current_server} 'mkdir -p ~/.ssh/ && cat >> ~/.ssh/authorized_keys'"
      run "#{sudo} sh -c \"echo '#{user} ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers\""
      run "#{sudo} passwd -l #{user}"
      system "bundle exec knife solo prepare #{user}@#{current_server}"
    end
  end

  task :addapp do
    `mkdir -p ./config/apps` #FIXME: Error when not exists

    if not self[:appname]
     puts 'Usage: bundle exec cap takeout:addapp -s appname=<name>'
     exit
    end

    template "app.rb", "config/apps/#{self[:appname]}.rb", {
      NAME: self[:appname],
      ENV:  self[:env] || 'production',
      PASSWORD: self[:dbpass] || SecureRandom.hex
    }
  end

  task :build do
    ServerBuilder.capistrano = self

    require "./config/server_config.rb"
    Dir.foreach('./config/apps/') { |a| require "./config/apps/#{a}" if a.match /.rb/ }

    File.write('./server.json', JSON.pretty_generate(ServerBuilder.build))
    puts "Written to node.json"
  end

  desc 'Update your server via knife solo cook'
  task :apply do
    build
    find_servers_for_task(current_task).each do |current_server|
      system "bundle exec knife solo cook #{user}@#{current_server} ./server.json -c ./lib/chef/knife.rb"
    end
  end
end