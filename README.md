Description
===========

This cookbook deploys and manages an instance of [Hubot](http://hubot.github.com/).  It is assumed that the Hubot
instance lives in its own repository and that it needs to be deployed as an application with the opportunity to overlay
things like environmental variables via Chef, much like the default Heroku-based deployment.  This differs from [Seth
Chisamore's hubot cookbook](https://github.com/schisamo-cookbooks/hubot), which generates the Hubot instance,
configuring many aspects via Chef attributes.  Both are valid approaches.  The reason why `modcloth-hubot` was created
was to play nicely with tools that want to manage deployments via git such as
[Dreadnot](https://github.com/racker/dreadnot) so that Hubot deployments could be done dogfood-style.

Requirements
============

Both git and nodejs should be installed, which is done automatically via the `modcloth-hubot::prereqs` cookbook.  See
the attributes section below for how to opt out of this.

## Platforms

Ubuntu > `10.04` (with Upstart) and SmartOS are supported.

Attributes
==========

- `node['modcloth_hubot']['user']` - user to create for the Hubot instance (default <q>hubot</q>)
- `node['modcloth_hubot']['group']` - group to create for the Hubot instance (default <q>hubot</q>)
- `node['modcloth_hubot']['gid']` - group id for the Hubot group (default `1499`)
- `node['modcloth_hubot']['home']` - home directory
- `node['modcloth_hubot']['id_rsa']` - private rsa ssh key string
- `node['modcloth_hubot']['id_rsa_pub']` - public rsa ssh key string
- `node['modcloth_hubot']['name']` - Hubot instance name (personality!)
- `node['modcloth_hubot']['adapter']` - adapter to use (e.g. `campfire`, `hipchat`, `irc`, etc.)
- `node['modcloth_hubot']['http_port']` - default HTTP port
- `node['modcloth_hubot']['repo']` - repository URL for Hubot instance
- `node['modcloth_hubot']['revision']` - revision of Hubot instance repo
- `node['modcloth_hubot']['deploy_action']` - passed to `deploy_revision`, e.g.  `deploy`, `nothing`.
- `node['modcloth_hubot']['rollback_on_error']` - passed to `deploy_revison`
- `node['modcloth_hubot']['service_name']` - name of upstart/smf service
- `node['modcloth_hubot']['environment']` - `Hash` of environment variables written to an `/etc/default` file which is
  sourced by the Hubot service.  This is the rough equivalent of configuring multiple env vars via the Heroku tool.
Environmental variables may also be set via file(s) that live in the Hubot instance repository.  See the `env_cascade`
attribute below.
- `node['modcloth_hubot']['env_cascade']` - `Array` of file names to source to prepare the Hubot environmental variable
  soup.  The working directory when the files are sourced is the clone of the Hubot instance repo.  The bash `set -a`
option is set prior to sourcing so that `export VAR` is not necessary.  If a given file does not exist, it will be
silently skipped. (default `%w(.env /etc/default/hubot)`)

## Nginx attributes

- `node['modcloth_hubot']['nginx']['enabled']` - whether to include the `modcloth-hubot::nginx` recipe from within the
  `modcloth-hubot::default` recipe (default `true`).
- `node['modcloth_hubot']['nginx']['install_nginx']` - whether to include the `nginx::default` recipe to install nginx
- `node['modcloth_hubot']['nginx']['listen_port']` - used in the Hubot-specific nginx config `server` section
- `node['modcloth_hubot']['nginx']['server_name_aliases']` - additional server names to set in `server_name`
- `node['modcloth_hubot']['nginx']['site_name']` - the file basename to use in `sites-available/`
- `node['modcloth_hubot']['nginx']['auth_basic']['enabled']` - whether to add `auth_basic` configuration to nginx site
  (default `false`).
- `node['modcloth_hubot']['nginx']['auth_basic']['realm']` - string realm for basic auth (default <q>Hubot</q>).
- `node['modcloth_hubot']['nginx']['auth_basic']['users']` - `Hash` of user + credentials to use for writing the
  `htpasswd` file.  If the credentials strings begin with `{(PLAIN|SHA|SSHA)}`, they are written unaltered, else the
strings will be `SSHA`-encoded. (default `{}`).
- `node['modcloth_hubot']['nginx']['auth_basic']['user_file']` - file path for `htpasswd` (default
  `$nginx_dir/hubot.htpasswd`).
- `node['modcloth_hubot']['nginx']['ssl']['enabled']` - whether to enable ssl on the Hubot site `server` (default
  `false`)
- `node['modcloth_hubot']['nginx']['ssl']['crt_file']` - `crt` file to use as `ssl_certificate`
- `node['modcloth_hubot']['nginx']['ssl']['key_file']` - `key` file to use as `ssl_certificate_key`.

## Redis attributes

- `node['modcloth_hubot']['redis']['enabled']` - whether or not to include redis, such as when the redis Hubot brain is
  used.
- `node['modcloth_hubot']['redis']['packages']` - the platform-dependant packages to install in order to get redis
  running

## Prerequisite install attributes

- `node['modcloth_hubot']['install_git']` - includes the `git::default` recipe
- `node['modcloth_hubot']['install_nodejs']` - includes the `nodejs::default` recipe

## Template attributes

The following attributes allow injection of custom templates via wrapper cookbooks:

- `node['modcloth_hubot']['upstart_conf_template_file']`
- `node['modcloth_hubot']['upstart_conf_cookbook']`
- `node['modcloth_hubot']['etc_default_hubot_template_file']`
- `node['modcloth_hubot']['etc_default_hubot_cookbook']`
- `node['modcloth_hubot']['bash_profile_template_file']`
- `node['modcloth_hubot']['bash_profile_template_cookbook']`
- `node['modcloth_hubot']['bashrc_template_file']`
- `node['modcloth_hubot']['bashrc_template_cookbook']`
- `node['modcloth_hubot']['ssh_wrapper_template_file']`
- `node['modcloth_hubot']['ssh_wrapper_template_cookbook']`
- `node['modcloth_hubot']['runner_template_file']`
- `node['modcloth_hubot']['runner_template_cookbook']`
- `node['modcloth_hubot']['nginx']['site_template_file']`
- `node['modcloth_hubot']['nginx']['site_template_cookbook']`
- `node['modcloth_hubot']['nginx']['auth_basic']['user_file_template']`
- `node['modcloth_hubot']['nginx']['auth_basic']['user_file_cookbook']`

Usage
=====

Include `recipe[modcloth-hubot]` in your `run_list`.  Set some attributes however you prefer so that at least the
following is present:

- `node['modcloth_hubot']['repo']`


If the repository includes a `.env` file at the top level that contains whatever environmental variables are needed by
your Hubot instance, no further configuration is necessary.  Alternatively, environmental variables may be injected into
the instance environment via the `modcloth_hubot.environment` attribute, e.g.:

    default_attributes(
      'modcloth_hubot' => {
        'environment' => {
          'HUBOT_CAMPFIRE_ACCOUNT' => 'foobar',
          'HUBOT_CAMPFIRE_TOKEN' => 'abcdefabcdefabcdefabcdefabcdefabcdef',
          'HUBOT_CAMPFIRE_ROOMS' => '123,456',
        }
      }
    )

## nginx support

If you'd like your Hubot to live behind nginx with some niceties like SSL and basic auth, you might configure
your `modcloth_hubot.nginx.*` attributes like so:

    default_attributes(
      'modcloth_hubot' => {
        # ...
        'nginx' => {
          'auth_basic' => {
            'enabled' => true,
            'users' => {
              'foo' => '{SSHA}eYiG23Clo7VBTNz3GSO5VarX5exrUnNiSFVzOXRDd1N0SG94VjdxZENUK00wOGFNV2J2MA==',
              'less-paranoid' => 'aoeu'
            }
          },
          'ssl' => {
            'enabled' => true,
            'crt_file' => '/etc/nginx/ssl/wildcard.example.com.crt',
            'key_file' => '/etc/nginx/ssl/wildcard.example.com.key'
          }
        }
      }
    )


See Also
========

- [Seth Chisamore's hubot cookbook](https://github.com/schisamo-cookbooks/hubot)
