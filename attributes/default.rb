if node.platform_family == "rhel"
  user = "apache"
  group = "apache"
  conf_dir = "/etc/php-fpm.d"
  conf_file = "/etc/php-fpm.conf"
  error_log = "/var/log/php-fpm/error.log"
  pid = "/var/run/php-fpm/php-fpm.pid"
else
  user = "www-data"
  group = "www-data"
  conf_dir = "/etc/php5/fpm"
  conf_file = "/etc/php5/fpm/php-fpm.conf"
  error_log = "/var/log/php5-fpm.log"
  pid ="/var/run/php5-fpm.pid"
end

pool_dir = "/var/run/php-fpm/"

default['php-fpm']['user'] = user
default['php-fpm']['group'] = group
force_default['authorization']['sudo']['include_sudoers_d'] = true

default['php-fpm']['options']['error_reporting'] = 'E_ALL & ~E_NOTICE'
default['php-fpm']['options']['display_errors'] = 'Off'
default['php-fpm']['options']['date_timezone'] = 'Europe/London'
default['php-fpm']['directives'] = {}

default['php-fpm']['conf_dir'] = conf_dir
default['php-fpm']['conf_file'] = conf_file
default['php-fpm']['pid'] = pid
default['php-fpm']['error_log'] =  error_log
default['php-fpm']['log_level'] = "notice"

default["php-fpm"]["pool_dir"] = pool_dir

default['php-fpm']['pool']['default_pool']['listen'] = "#{pool_dir}$pool.sock"
default['php-fpm']['pool']['default_pool']['allowed_clients'] = "all"
default['php-fpm']['pool']['default_pool']['user'] = user
default['php-fpm']['pool']['default_pool']['group'] = group
default['php-fpm']['pool']['default_pool']['process_manager'] = "dynamic"
default['php-fpm']['pool']['default_pool']['max_children'] = 5
default['php-fpm']['pool']['default_pool']['start_servers'] = 2
default['php-fpm']['pool']['default_pool']['min_spare_servers'] = 1
default['php-fpm']['pool']['default_pool']['max_spare_servers'] = 2
default['php-fpm']['pool']['default_pool']['max_requests'] = 200
default['php-fpm']['pool']['default_pool']['status_path'] = '/fpmstatus/$pool'
