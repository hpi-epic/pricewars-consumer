role :www, %w(deployer@vm-mpws2016hp1-01.eaalab.hpi.uni-potsdam.de)
server "vm-mpws2016hp1-01.eaalab.hpi.uni-potsdam.de", user: "deployer", roles: %w(www)

# uncomment in case of travis, capistrano will have its own
set :ssh_options, keys: ["config/deploy_id_rsa"] if File.exist?("config/deploy_id_rsa")

set :deploy_to, "/var/www/consumer"

# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
