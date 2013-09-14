# encoding: utf-8

# ModClothHubot defines a few helper-y things used in recipes and resources
module ModClothHubot
  def deployable?
    modcloth_hubot_attrs_present?('repo', 'revision')
  end

  def has_ssh_key?
    modcloth_hubot_attrs_present?('id_rsa', 'id_rsa_pub')
  end

  private

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
