# encoding: utf-8

# ModClothHubot defines a few helper-y things used in recipes and resources
module ModClothHubot
  def deployable?
    modcloth_hubot_attrs_present?('repo', 'revision')
  end

  def has_ssh_key?
    modcloth_hubot_attrs_present?('id_rsa', 'id_rsa_pub')
  end

  def restart_hubot
    start, restart = send("start_restart_#{node['platform']}")
    restart.run_command
    restart.error!
  rescue => e
    Chef::Log.warn("Failed to restart, so just starting: #{e}")
    start.run_command
    start.error!
  end

  private

  def start_restart_ubuntu
    [
      Mixlib::ShellOut.new(
        "initctl restart #{node['modcloth_hubot']['service_name']}"
      ),
      Mixlib::ShellOut.new(
        "initctl start #{node['modcloth_hubot']['service_name']}"
      )
    ]
  end

  def start_restart_smartos
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
