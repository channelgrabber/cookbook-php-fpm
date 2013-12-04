node.overide['authorization']['sudo']['include_sudoers_d'] = true

sudo 'php5-fpm' do
    user node['php-fpm']['user']
    group node['php-fpm']['group']
    nopasswd true
    commands ['start php5-fpm', 'stop php5-fpm', 'restart php5-fpm']
end