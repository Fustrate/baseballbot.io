server '173.255.247.137', user: 'baseballbot', roles: %w(web app db)

set :stage, :production

set :nginx_server_name, 'baseballbot.io'

set :ssh_options,
    user: 'baseballbot',
    keys: %w(/Users/steven/.ssh/id_rsa.pub),
    forward_agent: true
