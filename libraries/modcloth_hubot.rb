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

  def ensure_hashed_password(password)
    return password if password =~ /^\{(SSHA|PLAIN|SHA)\}/
    salt = SecureRandom.base64(24)
    base64_encoded = Base64.encode64(
      "#{Digest::SHA1.digest("#{password}#{salt}")}#{salt}"
    )
    "{SSHA}#{base64_encoded.chomp.gsub(/\n/, '')}"
  end

  module_function :ensure_hashed_password

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
