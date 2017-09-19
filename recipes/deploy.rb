# encoding: utf-8
#
# Cookbook Name:: modcloth-hubot
# Recipe:: deploy
#
# Copyright 2013, ModCloth, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

hubot_runner = "#{node['modcloth_hubot']['home']}/shared/hubot-runner"

template "/etc/default/#{node['modcloth_hubot']['service_name']}" do
  source node['modcloth_hubot']['etc_default_hubot_template_file']
  cookbook node['modcloth_hubot']['etc_default_hubot_cookbook']
  owner node['modcloth_hubot']['user']
  group node['modcloth_hubot']['group']
  mode 0400
end

template "/etc/init/#{node['modcloth_hubot']['service_name']}.conf" do
  source node['modcloth_hubot']['upstart_conf_template_file']
  cookbook node['modcloth_hubot']['upstart_conf_cookbook']
  owner 'root'
  group 'root'
  mode 0644
  only_if { platform?('ubuntu') }
end

smf node['modcloth_hubot']['service_name'] do
  user node['modcloth_hubot']['user']
  group node['modcloth_hubot']['group']
  start_command hubot_runner
  stop_command ':kill'
  working_directory "#{node['modcloth_hubot']['home']}/current"
  environment 'HOME' => node['modcloth_hubot']['home'],
              'PATH' => '/opt/local/bin:/opt/local/sbin:/usr/bin:/usr/sbin'
  duration 'child'
  notifies :enable, "service[#{node['modcloth_hubot']['service_name']}]"
  only_if { platform?('smartos') }
end

execute 'systemctl daemon-reload' do
  action :nothing
end

template "/etc/systemd/system/#{node['modcloth_hubot']['service_name']}.service" do
  source 'systemd.service.erb'
  user 'root'
  group 'root'
  mode 0o0640

  variables(
    user: node['modcloth_hubot']['user'],
    group: node['modcloth_hubot']['group'],
    exec_start: node['modcloth_hubot']['systemd']['exec_start'],
    working_directory: "#{node['modcloth_hubot']['home']}/current",
    environment: Mash.new({
        HOME: node['modcloth_hubot']['home'],
        PATH: '/opt/local/bin:/opt/local/sbin:/usr/bin:/usr/sbin'
      }).merge(node['modcloth_hubot']['environment'] || Mash.new({})),
    description: node['modcloth_hubot']['service_name']
  )

  action :create

  only_if { platform?('centos') }

  notifies :run, 'execute[systemctl daemon-reload]', :immediately
  notifies :restart, "service[#{node['modcloth_hubot']['service_name']}]"
end

service_provider = value_for_platform(
  'ubuntu' => {
    'default' => Chef::Provider::Service::Upstart
  },
  'smartos' => {
    'default' => Chef::Provider::Service::Solaris
  },
  'default' => {
    'default' => nil
  }
)

service node['modcloth_hubot']['service_name'] do
  provider service_provider if service_provider['default']
  supports start: true, restart: true, stop: true
  action :enable
end

%W(
  #{node['modcloth_hubot']['home']}/shared
  #{node['modcloth_hubot']['home']}/shared/node_modules
).each do |dirname|
  directory dirname do
    owner node['modcloth_hubot']['user']
    group node['modcloth_hubot']['group']
    mode 0750
  end
end

template hubot_runner do
  source node['modcloth_hubot']['runner_template_file']
  cookbook node['modcloth_hubot']['runner_template_cookbook']
  owner node['modcloth_hubot']['user']
  group node['modcloth_hubot']['group']
  mode 0700
end

bash 'disable service' do
  code "svcadm disable -s #{node['modcloth_hubot']['service_name']}"
  only_if { platform?('smartos') && needs_to_be_disabled? }
end

deploy_revision node['modcloth_hubot']['home'] do
  user node['modcloth_hubot']['user']
  repo node['modcloth_hubot']['repo']
  revision node['modcloth_hubot']['revision']

  symlink_before_migrate.clear
  create_dirs_before_symlink.clear
  purge_before_symlink.clear

  migrate false
  rollback_on_error node['modcloth_hubot']['rollback_on_error']
  symlinks 'node_modules' => 'node_modules'

  before_restart do
    ruby_block 'npm install' do
      # make sure we install all the npm dependencies
      block { npm_install.run_command }
    end
  end

  restart_command do
    ruby_block "restart #{node['modcloth_hubot']['service_name']}" do
      # For some reason I'm unable to notify the service[hubot] resource from
      # inside here, as the restart_command proc appears to be getting executed
      # before the resource collection is fully built (???)  Hence the ugliness
      # in ./libraries/modcloth_hubot.rb seen here as #restart_hook.
      block { restart_hubot }
    end
  end

  action node['modcloth_hubot']['deploy_action'].to_sym
  only_if { deployable? }
end
