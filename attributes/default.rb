# encoding: utf-8
#
# Cookbook Name:: modcloth-hubot
# Attributes:: default
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

default['modcloth_hubot']['user'] = 'hubot'
default['modcloth_hubot']['group'] = 'hubot'
default['modcloth_hubot']['gid'] = 1499
default['modcloth_hubot']['home'] = '/home/hubot'
default['modcloth_hubot']['id_rsa'] = ''
default['modcloth_hubot']['id_rsa_pub'] = ''
default['modcloth_hubot']['bash_profile_template_file'] = 'bash_profile.sh.erb'
default['modcloth_hubot']['bash_profile_template_cookbook'] = 'modcloth-hubot'
default['modcloth_hubot']['bashrc_template_file'] = 'bashrc.sh.erb'
default['modcloth_hubot']['bashrc_template_cookbook'] = 'modcloth-hubot'
default['modcloth_hubot']['ssh_wrapper_template_file'] = 'ssh_wrapper.sh.erb'
default['modcloth_hubot']['ssh_wrapper_template_cookbook'] = 'modcloth-hubot'

default['modcloth_hubot']['name'] = 'hubot'
default['modcloth_hubot']['adapter'] = 'campfire'
default['modcloth_hubot']['http_port'] = 9425
default['modcloth_hubot']['repo'] = nil
default['modcloth_hubot']['revision'] = 'HEAD'
default['modcloth_hubot']['deploy_action'] = 'deploy'
default['modcloth_hubot']['rollback_on_error'] = true
default['modcloth_hubot']['service_name'] = 'hubot'
default['modcloth_hubot']['environment'] = {}

default['modcloth_hubot']['upstart_conf_template_file'] = 'hubot.conf.erb'
default['modcloth_hubot']['upstart_conf_cookbook'] = 'modcloth-hubot'
default['modcloth_hubot']['etc_default_hubot_template_file'] = 'etc-default-hubot.sh.erb'
default['modcloth_hubot']['etc_default_hubot_cookbook'] = 'modcloth-hubot'

default['modcloth_hubot']['nginx']['enabled'] = true
default['modcloth_hubot']['nginx']['install_nginx'] = true
default['modcloth_hubot']['nginx']['listen_port'] = 14_990
default['modcloth_hubot']['nginx']['server_name_aliases'] = []
default['modcloth_hubot']['nginx']['site_name'] = 'hubot'
default['modcloth_hubot']['nginx']['site_template_file'] = 'nginx-site.conf.erb'
default['modcloth_hubot']['nginx']['site_template_cookbook'] = 'modcloth-hubot'
default['modcloth_hubot']['nginx']['auth_basic']['enabled'] = false
default['modcloth_hubot']['nginx']['auth_basic']['realm'] = 'Hubot'
default['modcloth_hubot']['nginx']['auth_basic']['users'] = {}
default['modcloth_hubot']['nginx']['auth_basic']['user_file'] = "#{node['nginx']['dir']}/hubot.htpasswd"
default['modcloth_hubot']['nginx']['auth_basic']['user_file_template'] = 'htpasswd.erb'
default['modcloth_hubot']['nginx']['auth_basic']['user_file_cookbook'] = 'modcloth-hubot'
default['modcloth_hubot']['nginx']['ssl']['enabled'] = false
default['modcloth_hubot']['nginx']['ssl']['crt_file'] = nil
default['modcloth_hubot']['nginx']['ssl']['key_file'] = nil

default['modcloth_hubot']['redis']['enabled'] = true
default['modcloth_hubot']['redis']['packages'] = %w(redis-server)

default['modcloth_hubot']['install_git'] = true
default['modcloth_hubot']['install_nodejs'] = true

default['nodejs']['install_method'] = 'package'

case node['platform']
when 'ubuntu'
  require 'English'
  df = Mixlib::ShellOut.new('df -TP')
  df.run_command
  data_mount = df.stdout.chomp.split($RS).grep(/\/data$/).first
  if data_mount && data_mount.split[1] !~ /tmp/
    default['modcloth_hubot']['home'] = '/data/hubot'
  end
when 'smartos'
  default['modcloth_hubot']['redis']['packages'] = %w(redis)
end
