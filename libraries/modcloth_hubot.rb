# encoding: utf-8

require 'base64'
require 'digest/sha1'
require 'securerandom'

# ModClothHubot defines a few helper-y things used in recipes and resources
module ModClothHubot
  def deployable?
    modcloth_hubot_attrs_present?('repo', 'revision')
  end

  def has_ssh_key?
    modcloth_hubot_attrs_present?('id_rsa', 'id_rsa_pub')
  end

  def restart_hubot
    restart, start = send("restart_start_#{node['platform']}")
    restart.run_command
    restart.error!
  rescue => e
    Chef::Log.warn("Failed to restart, so just starting: #{e}")
    start.run_command
    start.error!
  end

  def needs_to_be_disabled?
    svcs = Mixlib::ShellOut.new(
      "svcs -H -o STA #{node['modcloth_hubot']['service_name']}"
    )
    svcs.run_command
    svcs.stdout.chomp =~ /^(MNT|DGD|OFF)/
  end

  def ensure_hashed_password(password)
    return password if password =~ /^\{(SSHA|PLAIN|SHA)\}/
    salt = SecureRandom.base64(24)
    base64_encoded = Base64.encode64(
      "#{Digest::SHA1.digest("#{password}#{salt}")}#{salt}"
    )
    "{SSHA}#{base64_encoded.chomp.gsub(/\n/, '')}"
  end

  module_function :ensure_hashed_password

  def npm_install
    Mixlib::ShellOut.new(
      "su - #{node['modcloth_hubot']['user']} -c 'cd #{node['modcloth_hubot']['home']}/current && npm install --production'" # rubocop:disable LineLength
    )
  end

  private

  def restart_start_ubuntu
    [
      Mixlib::ShellOut.new(
        "initctl restart #{node['modcloth_hubot']['service_name']}"
      ),
      Mixlib::ShellOut.new(
        "initctl start #{node['modcloth_hubot']['service_name']}"
      )
    ]
  end

  def restart_start_smartos
    [
      Mixlib::ShellOut.new(
        "svcadm restart #{node['modcloth_hubot']['service_name']}"
      ),
      Mixlib::ShellOut.new(
        "svcadm enable -s #{node['modcloth_hubot']['service_name']}"
      )
    ]
  end

  def restart_start_centos
    restart_start_systemd
  end

  def restart_start_systemd
    [
      Mixlib::ShellOut.new(
        "systemctl restart #{node['modcloth_hubot']['service_name']}"
      ),
      Mixlib::ShellOut.new(
        "systemctl enable #{node['modcloth_hubot']['service_name']}"
      )
    ]
  end

  def modcloth_hubot_attrs_present?(*attrs)
    attrs.each do |attr|
      return false if node['modcloth_hubot'][attr].nil?
      return false if node['modcloth_hubot'][attr].empty?
    end
    true
  end
end

Chef::Recipe.send(:include, ModClothHubot)
Chef::Resource.send(:include, ModClothHubot)
