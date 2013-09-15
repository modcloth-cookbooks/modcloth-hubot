# encoding: utf-8
#
# Cookbook Name:: modcloth-hubot
# Recipe:: user
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

group node['modcloth_hubot']['group'] do
  gid node['modcloth_hubot']['gid']
end

user node['modcloth_hubot']['user'] do
  gid node['modcloth_hubot']['group']
  comment 'Hubot User'
  shell '/bin/bash'
  home node['modcloth_hubot']['home']
end

directory node['modcloth_hubot']['home'] do
  owner node['modcloth_hubot']['user']
  group node['modcloth_hubot']['group']
  recursive true
  mode 0755
end

template "#{node['modcloth_hubot']['home']}/.bash_profile" do
  source node['modcloth_hubot']['bash_profile_template_file']
  cookbook node['modcloth_hubot']['bash_profile_template_cookbook']
  owner node['modcloth_hubot']['user']
  group node['modcloth_hubot']['group']
  mode 0600
end

template "#{node['modcloth_hubot']['home']}/.bashrc" do
  source node['modcloth_hubot']['bashrc_template_file']
  cookbook node['modcloth_hubot']['bashrc_template_cookbook']
  owner node['modcloth_hubot']['user']
  group node['modcloth_hubot']['group']
  mode 0600
end

template "#{node['modcloth_hubot']['home']}/deploy-ssh-wrapper" do
  source node['modcloth_hubot']['ssh_wrapper_template_file']
  cookbook node['modcloth_hubot']['ssh_wrapper_template_cookbook']
  owner node['modcloth_hubot']['user']
  group node['modcloth_hubot']['group']
  mode 0700
  only_if { has_ssh_key? }
end

directory "#{node['modcloth_hubot']['home']}/.ssh" do
  owner node['modcloth_hubot']['user']
  group node['modcloth_hubot']['group']
  mode 0700
  only_if { has_ssh_key? }
end

file "#{node['modcloth_hubot']['home']}/.ssh/known_hosts" do
  owner node['modcloth_hubot']['user']
  group node['modcloth_hubot']['group']
  mode 0600
  action :touch
end

known_hosts = "#{node['modcloth_hubot']['home']}/.ssh/known_hosts"
ssh_keyscan_command = value_for_platform(
  'ubuntu' => {
    'default' => 'ssh-keyscan -H github.com'
  },
  'smartos' => {
    'default' => 'ssh-keyscan -t rsa github.com'
  }
)

bash 'add github.com to known hosts' do
  code "#{ssh_keyscan_command} >> #{known_hosts}"
  user node['modcloth_hubot']['user']
  group node['modcloth_hubot']['group']
  not_if "ssh-keygen -f #{known_hosts} -H -F github.com | grep 'github.com'"
end

file "#{node['modcloth_hubot']['home']}/.ssh/id_rsa" do
  content node['modcloth_hubot']['id_rsa']
  owner node['modcloth_hubot']['user']
  group node['modcloth_hubot']['group']
  mode 0600
  only_if { has_ssh_key? }
end

file "#{node['modcloth_hubot']['home']}/.ssh/id_rsa.pub" do
  content node['modcloth_hubot']['id_rsa_pub']
  owner node['modcloth_hubot']['user']
  group node['modcloth_hubot']['group']
  mode 0600
  only_if { has_ssh_key? }
end
