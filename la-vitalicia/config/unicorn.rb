# Set the working application directory
# # working_directory "/path/to/your/app"
 working_directory "/home/adminweb/www/vitalicia"
#
# # Unicorn PID file location
# # pid "/path/to/pids/unicorn.pid"
 pid "/home/adminweb/www/vitalicia/pids/unicorn.pid"
#
# # Path to logs
# # stderr_path "/path/to/log/unicorn.log"
# # stdout_path "/path/to/log/unicorn.log"
 stderr_path "/home/adminweb/www/vitalicia/log/unicorn.log"
 stdout_path "/home/adminweb/www/vitalicia/log/unicorn.log"
#
# # Unicorn socket
 # listen "/tmp/unicorn.[app name].sock"
 # listen "/tmp/unicorn.vitalicia.sock"
#
# # Number of processes
# # worker_processes 4
 worker_processes 4
#
# # Time-out
 timeout 30
