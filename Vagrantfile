# encoding: utf-8

Vagrant.configure('2') do |config|
  config.vm.hostname = 'modcloth-hubot-berkshelf'
  config.vm.box = 'canonical-ubuntu-12.04'
  config.vm.box_url = 'http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box'
  config.vm.network :private_network, ip: '33.33.33.10'

  config.ssh.max_tries = 40
  config.ssh.timeout   = 120

  config.berkshelf.berksfile_path = './Berksfile.vagrant'
  config.berkshelf.enabled = true

  config.omnibus.chef_version = :latest

  config.vm.provision :chef_solo do |chef|
    chef.json = {}
    chef.run_list = [
      'recipe[modcloth-hubot::default]'
    ]
  end
end
