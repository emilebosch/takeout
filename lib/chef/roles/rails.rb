name 'rails'
description 'This role configures a Rails stack using Unicorn'
run_list "recipe[apt]", "recipe[build-essential]", "recipe[percona_mysql]", "recipe[packages]", "recipe[ruby_build]", "recipe[bundler]", "recipe[bluepill]", "recipe[nginx]", "recipe[rails]", "recipe[rbenv::user]", "recipe[backup]", "recipe[rails::databases]", "recipe[git]", "recipe[ssh_deploy_keys]", "recipe[postfix]"
