sudo 'php5-fpm' do
    template 'permissions.erb'
    variables({
        :commands => ['start php5-fpm', 'stop php5-fpm', 'restart php5-fpm'],
        :host => 'ALL',
        :runas => 'root',
        :nopasswd => true
    })
end