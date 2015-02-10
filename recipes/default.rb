#
# Author::  Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: php-fpm
# Recipe:: default
#
# Copyright 2011, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node['platform']
when 'ubuntu'
  if node['platform_version'].to_f <= 10.04
    # Configure Brian's PPA
    # We'll install php5-fpm from the Brian's PPA backports
    apt_repository "brianmercer-php" do
      uri "http://ppa.launchpad.net/brianmercer/php5/ubuntu"
      distribution node['lsb']['codename']
      components ["main"]
      keyserver "keyserver.ubuntu.com"
      key "8D0DC64F"
      action :add
    end
    # FIXME: apt-get update didn't trigger in above
    execute "apt-get update"
  end
when 'debian'
  # Configure Dotdeb repos
  # TODO: move this to it's own 'dotdeb' cookbook?
  # http://www.dotdeb.org/instructions/
  if node.lsb.codename == 'squeeze'
    apt_repository "dotdeb" do
      uri "http://packages.dotdeb.org"
      distribution "squeeze"
      components ['all']
      key "http://www.dotdeb.org/dotdeb.gpg"
      action :add
    end
  elsif node.platform_version.to_f >= 7.0
    apt_repository "dotdeb" do
      uri "http://packages.dotdeb.org"
      distribution "stable"
      components ['all']
      key "http://www.dotdeb.org/dotdeb.gpg"
      action :add
    end
  else
    apt_repository "dotdeb" do
      uri "http://packages.dotdeb.org"
      distribution "oldstable"
      components ['all']
      key "http://www.dotdeb.org/dotdeb.gpg"
      action :add
    end
    apt_repository "dotdeb-php53" do
      uri "http://php53.dotdeb.org"
      distribution "oldstable"
      components ['all']
      key "http://www.dotdeb.org/dotdeb.gpg"
      action :add
    end
  end

when 'amazon', 'fedora', 'centos', 'redhat'
  unless platform?('centos', 'redhat') && node['platform_version'].to_f >= 6.4
    yum_key 'RPM-GPG-KEY-remi' do
      url 'http://rpms.famillecollet.com/RPM-GPG-KEY-remi'
    end

    yum_repository 'remi' do
      description 'Remi'
      url 'http://rpms.famillecollet.com/enterprise/$releasever/remi/$basearch/'
      mirrorlist 'http://rpms.famillecollet.com/enterprise/$releasever/remi/mirror'
      key 'RPM-GPG-KEY-remi'
      action :add
    end
  end
end

if platform_family?("rhel")
  php_fpm_service_name = "php-fpm"
else
  php_fpm_service_name = "php5-fpm"
end

directory "/var/run/php-fpm" do
  owner 'www-data'
  group 'www-data'
  mode '0775'
  action :create
end

package php_fpm_service_name do
  options "-o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\""
  action :upgrade
end

template node['php-fpm']['conf_file'] do
  source "php-fpm.conf.erb"
  mode 00644
  owner "root"
  group "root"
end

template "/etc/php5/fpm/php.ini" do
  cookbook "php"
  source "php.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :error_reporting => node['php-fpm']['options']['error_reporting'],
    :display_errors => node['php-fpm']['options']['display_errors'],
    :date_timezone => node['php-fpm']['options']['date_timezone'],
    :directives => node['php-fpm']['directives']
  )
end

node['configure_sites']['sites'].each do |siteName, site|
  if(!site.has_key?('enabled') || !site.enabled)
    next
  end
  
  if node.default['php-fpm']['pool'].has_key?(siteName)
    node['php-fpm']['pool']['default_pool'].each do |key, value|
      if !node.default['php-fpm']['pool'][siteName].has_key?(key) 
        node.default['php-fpm']['pool'][siteName][key] = value
      end
    end
  else
    node.default['php-fpm']['pool'][siteName] = node['php-fpm']['pool']['default_pool']
  end

  fpm_pool siteName do 
    php_fpm_service_name php_fpm_service_name
  end
end

service "php-fpm" do
  service_name php_fpm_service_name
  supports :start => true, :stop => true, :restart => true, :reload => true
  action [ :enable, :restart ]
  provider Chef::Provider::Service::Upstart
end
