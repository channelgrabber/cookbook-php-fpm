sudo 'php5-fpm' do
    template 'permissions.erb'
    variables({
        :commands => ['/sbin/start php5-fpm', '/sbin/stop php5-fpm', '/sbin/restart php5-fpm'],
        :user => node['php-fpm']['user'],
        :group => "%#{node['php-fpm']['group']}",
        :host => 'ALL',
        :runas => 'root',
        :nopasswd => true
    })
end