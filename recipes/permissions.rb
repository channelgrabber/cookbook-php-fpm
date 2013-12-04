sudo 'php5-fpm' do
    template 'permissions.erb'
    variables({
        :commands => ['start php5-fpm', 'stop php5-fpm', 'restart php5-fpm'],
        :user => node['php-fpm']['user'],
        :group => "%#{node['php-fpm']['group']}",
        :host => 'ALL',
        :runas => 'root',
        :nopasswd => true
    })
end