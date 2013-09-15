# encoding: utf-8
#
# Cookbook Name:: modcloth-hubot
# Recipe:: nginx
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

if node['modcloth_hubot']['nginx']['install_nginx']
  Chef::Log.info('Including recipe[nginx::default]')
  include_recipe 'nginx::default'
end

if node['modcloth_hubot']['nginx']['auth_basic']['enabled'] &&
   node['modcloth_hubot']['nginx']['auth_basic']['users'].empty?
  Chef::Log.warn(
    'ModCloth Hubot nginx auth basic is enabled, but the users hash is empty!'
  )
end

template "#{node['nginx']['dir']}/sites-available/" <<
         node['modcloth_hubot']['nginx']['site_name'] do
  source node['modcloth_hubot']['nginx']['site_template_file']
  cookbook node['modcloth_hubot']['nginx']['site_template_cookbook']
  owner 'root'
  group 'root'
  mode 0644
  variables(ssl_enabled: node['modcloth_hubot']['nginx']['ssl']['enabled'] &&
                         node['modcloth_hubot']['nginx']['ssl']['crt_file'] &&
                         node['modcloth_hubot']['nginx']['ssl']['key_file'])
  notifies :reload, 'service[nginx]'
end

template node['modcloth_hubot']['nginx']['auth_basic']['user_file'] do
  source node['modcloth_hubot']['nginx']['auth_basic']['user_file_template']
  cookbook node['modcloth_hubot']['nginx']['auth_basic']['user_file_cookbook']
  owner 'root'
  group node['nginx']['group']
  mode 0640
  only_if { node['modcloth_hubot']['nginx']['auth_basic']['enabled'] }
end

nginx_site node['modcloth_hubot']['nginx']['site_name'] do
  enable true
end
