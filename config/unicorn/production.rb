app_name = 'baseballbot.io'
app_user = 'baseballbot'

app_dir = "/home/#{app_user}/apps/#{app_name}"

# Set the working application directory
working_directory app_dir

# Unicorn PID file location
pid "#{app_dir}/shared/tmp/pids/unicorn.pid"

# Path to logs
stderr_path "#{app_dir}/shared/log/unicorn.error.log"
stdout_path "#{app_dir}/shared/log/unicorn.log"

# Unicorn writes to stderr by default
logger Logger.new($stdout)

# Unicorn socket
listen "#{app_dir}/shared/tmp/sockets/unicorn.sock"

# Number of processes
worker_processes 2

timeout 30
