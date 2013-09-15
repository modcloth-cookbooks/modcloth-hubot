# encoding: utf-8

UBUNTU_PROVISION_SCRIPT = <<-EOF
if [ ! -d /vagrant/test/robby/.git ] ; then
  apt-get update -y -qq
  apt-get install -y -qq git git-core
  pushd /vagrant/test/robby
  git init .
  git add .
  git commit -m 'Initial commit'
fi
EOF

Vagrant.configure('2') do |config|
  config.vm.hostname = 'modcloth-hubot-berkshelf'
  config.vm.box = 'canonical-ubuntu-12.04'
  config.vm.box_url =
    'http://cloud-images.ubuntu.com/vagrant/precise/current/' <<
      'precise-server-cloudimg-amd64-vagrant-disk1.box'
  config.vm.network :private_network, ip: '33.33.33.10'

  config.ssh.max_tries = 40
  config.ssh.timeout   = 120

  config.berkshelf.berksfile_path = './Berksfile.vagrant'
  config.berkshelf.enabled = true

  config.omnibus.chef_version = :latest

  config.vm.provision :shell, inline: UBUNTU_PROVISION_SCRIPT
  config.vm.provision :chef_solo do |chef|
    chef.json = {
      'modcloth_hubot' => {
        'id_rsa' => <<-EOKEY.gsub(/^ {8}/, ''),
        -----BEGIN RSA PRIVATE KEY-----
        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
        -----END RSA PRIVATE KEY-----
        EOKEY
        'id_rsa_pub' =>
          'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDlB8mXfix3KMMK59zW1k8+L' <<
          'p/TIs8nRf7OiPmO0hwJyiPEABCnMckTloWCeU3gkxmneKENn2T255W4YEMz0R' <<
          'pF2rJ/kS/W3K0f5Ba/qUW9FlsqvVOz7+VQETRY+nqh34YYFBqwXuKflbuFzi1' <<
          'Pvur8mBePf70ax7reEWYtK9iy6Har5ZY/2mfcf3pKtKgcxF209r3XvV3ZYCet' <<
          'Kflu8Uy1cwFieUydHR4c+z+fGr0V2MPqJQMrNd1+uVRGv+Q3Mp+oNk1oFihD2' <<
          '3JgiavGLEpiwSYWlHIiRae2hxyOuw/Z0vqQz7aS0mEFAz7mslifw9PGbCvpvH' <<
          'a9uqkj/WsnPplFu4FnxNSUPz3FZ7+ljf9Dxa7sf8X3GtKHjKFLOpfbhvCRvvQ' <<
          'bycD0jQoyW9diwVqfEp3OFbUe/2m85SuTjHyy3QGvu+FFTwHvu8xSknzpt4bm' <<
          'R5l+ASPKKSqUoLdEv2owyPdL2jRbJai5IU2rQqMNk7U3xwp+2dC5Mw6bZEIcf' <<
          'iC9JDIyNc/6FRV0f1qH4K6FLRnMMcurhEB5puJj/oM+Lv20o73hX+yRQw8X+J' <<
          'yKBk+h7g+4kNQmP5X1ZHrlNHsfQUjJtgLPmC5BsfL5+UiCbQpOYPxWrGUDF32' <<
          'gxbANlSI2mNPEffB70I1vn1bQregjTo/0dM8JjPXD4zBe9BQGAw== ' <<
          'd.buch@failb0wl',
        'repo' => '/vagrant/test/robby',
        'environment' => {
          'PORT' => '9420'
        },
        'adapter' => 'shell',
        'nginx' => {
          'enabled' => true,
          'auth_basic' => {
            'enabled' => true,
            'users' => {
              'herp' => '{PLAIN}derp',
              'spaghattanadle' =>
                '{SSHA}8+WLSB8HEvx0s8bNIrghuvOhp+xkcTRhN1l6QmROd2RsK1ZhS' <<
                'nlUWENxVzlPbFFpUVVzQQ=='
            },
          },
          'ssl' => {
            'enabled' => true,
            'crt_file' => '/vagrant/test/ssl/modcloth-hubot-berkshelf.crt',
            'key_file' => '/vagrant/test/ssl/modcloth-hubot-berkshelf.key',
          }
        }
      }
    }
    chef.run_list = [
      'recipe[modcloth-hubot::default]',
      'minitest-handler',
    ]
  end
end
