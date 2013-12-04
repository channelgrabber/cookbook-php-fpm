node.force_default['authorization']['sudo']['include_sudoers_d'] = true

include_recipie 'sudo'

sudo 'php5-fpm' do
    user node['php-fpm']['user']
    group node['php-fpm']['group']
    nopasswd true
    commands ['start php5-fpm', 'stop php5-fpm', 'restart php5-fpm']
end