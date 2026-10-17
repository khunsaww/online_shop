lock "~> 3.20.1"

set :application, "online_shop"
set :repo_url, "git@github.com:example/online_shop.git"
set :branch, "main"

set :rbenv_type, :user
set :rbenv_ruby, "3.2.0"

append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "vendor/bundle", "storage"
append :linked_files, "config/master.key"

set :unicorn_pid, -> { "#{shared_path}/tmp/pids/unicorn.pid" }
set :unicorn_config_path, -> { "#{current_path}/config/unicorn.rb" }
set :keep_releases, 5

after "deploy:publishing", "deploy:restart"
namespace :deploy do
  task :restart do
    invoke "unicorn:restart"
  end
end
