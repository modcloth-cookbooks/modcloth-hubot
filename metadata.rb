# encoding: utf-8

name             'modcloth-hubot'
maintainer       'ModCloth, Inc.'
maintainer_email 'github+modcloth-hubot-cookbook@modcloth.com'
license          'MIT'
description      'Deploys a Hubot instance!'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.3.0'

supports 'smartos'
supports 'ubuntu', '>= 10.04'
supports 'centos', '>= 7.0'

depends 'git'
depends 'nginx'
depends 'nodejs'
depends 'smf'
