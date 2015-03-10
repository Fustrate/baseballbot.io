app_name = 'baseballbot.io'
app_user = 'baseballbot'

app_dir = "/home/#{app_user}/apps/#{app_name}"

# Set the working application directory
working_directory app_dir

# Unicorn PID file location
pid "#{app_dir}/tmp/pids/unicorn.pid"

# Path to logs
stderr_path "#{app_dir}/log/unicorn.log"
stdout_path "#{app_dir}/log/unicorn.log"

# Unicorn socket
listen "#{app_dir}/tmp/sockets/unicorn.sock"

# Number of processes
worker_processes 2

# Time-out
timeout 30
