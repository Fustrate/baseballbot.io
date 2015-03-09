app_name = 'baseballbot.io'
app_dir = "/home/steven/apps/#{app_name}"

# Set the working application directory
working_directory app_dir

# Unicorn PID file location
pid "#{app_dir}/pids/unicorn.pid"

# Path to logs
stderr_path "#{app_dir}/log/unicorn.log"
stdout_path "#{app_dir}/log/unicorn.log"

# Unicorn socket
listen "/tmp/unicorn.#{app_name}.sock"

# Number of processes
worker_processes 2

# Time-out
timeout 30
