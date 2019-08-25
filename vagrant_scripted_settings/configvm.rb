# Main Customboxclass Class
require 'json'

def functionname(config)

    dir = File.dirname(File.expand_path(__FILE__))
    path = "#{File.dirname(__FILE__)}"

    $homesteadJsonPath ="#{File.dirname(__FILE__)}/config.json"
    $settings = {}
    $settings = JSON::parse(File.read($homesteadJsonPath))

    #add plugins
    config.vagrant.plugins = ["vagrant-hostmanager"] # ["vagrant-winnfsd", "vagrant-vbguest"]

    ENV["VAGRANT_DEFAULT_PROVIDER"] = $settings['provider']

    config.vm.box = $settings['name']

    config.vm.network :forwarded_port, guest: $settings['ports']['guest'], host: $settings['ports']['host']

    config.vm.network "private_network", ip: $settings['private_network']

    config.vm.synced_folder $settings['folders']['from'], $settings['folders']['to']

    
    # config.vm.hostname = 'example-box-guest'
    
    config.vm.provider $settings['provider'] do |prvder, override|
		prvder.memory = $settings['memory']
    end
    
    #setting up hosts
    if Vagrant.has_plugin?('vagrant-hostmanager')
        config.hostmanager.enabled = true
        config.hostmanager.manage_host = true
        config.hostmanager.manage_guest = true
        config.hostmanager.include_offline = true
        config.hostmanager.ignore_private_ip = false

        config.vm.define 'example-box' do |node|
            node.vm.network :private_network, ip: $settings['public_network']
            # node.hostmanager.aliases = %w(example-box.localdomain example-box-alias)
        end
    end

    #config.vm.provision :shell,  :path =>  $settings['provision']

end