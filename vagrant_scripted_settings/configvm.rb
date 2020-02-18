# Main Customboxclass Class
require 'json'

def functionname(config)

    dir = File.dirname(File.expand_path(__FILE__))
    path = "#{File.dirname(__FILE__)}"

    $homesteadJsonPath ="#{File.dirname(__FILE__)}/config.json"
    $settings = {}
    $settings = JSON::parse(File.read($homesteadJsonPath))

    #add plugins
    config.vagrant.plugins = ["vagrant-vbguest", "vagrant-hostmanager"] # ["vagrant-winnfsd", "vagrant-vbguest"]

    ENV["VAGRANT_DEFAULT_PROVIDER"] = $settings['provider']

    config.vm.box = $settings['name']
    config.vm.box_url =  $settings['url']
    
    config.vm.network :forwarded_port, guest: $settings['ports']['guest'], host: $settings['ports']['host']

    config.vm.network "private_network", ip: $settings['private_network']

    config.vm.synced_folder $settings['folders']['from'], $settings['folders']['to'], auto_correct: true

    vhost = ""

    $settings['sites'].each do |maphost|
        vhost +="<VirtualHost *:80>
                    DocumentRoot "+maphost['svfolder']+"
                    ServerName "+maphost['customalias']+"
                    ServerAlias "+maphost['customalias']+"
                </VirtualHost>
                "
    end
    
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

        config.vm.define $settings['machine_name'] do |node|

            node.vm.network :private_network, ip: $settings['public_network']
            node.hostmanager.aliases =  $settings['sites'].map{ |items| items['customalias'] }
            node.hostmanager.aliases.join(' ')

        end

       
    end

    config.trigger.after :up do |trigger|
        trigger.name = "updatevhostsmanual"
        trigger.run_remote = {inline: "sudo echo '"+vhost+"' > ./serverconfig/vhosts.conf"}
        trigger.info = "updated /serverconfig/vhosts at vagrant up!!"
    end
    config.trigger.after :up do |triggertwo|
        triggertwo.name = "secondrestart"
        triggertwo.run_remote = {inline: "sudo service apache2 restart"}
        triggertwo.info = "restart apache2 server vagrant up!!"
    end
    if  ($settings['provision']  != '')
        config.vm.provision :shell,  :path =>  $settings['provision']
    end

end