app_dir = "/home/openfoodnetwork/apps/katuma_reports"
shared_dir = "#{app_dir}/shared"
working_directory "#{app_dir}/current"

worker_processes 2
preload_app true
timeout 30

listen "#{shared_dir}/sockets/unicorn.sock", backlog: 64

stderr_path "#{shared_dir}/log/unicorn.stderr.log"
stdout_path "#{shared_dir}/log/unicorn.stdout.log"

pid "#{shared_dir}/pids/unicorn.pid"
