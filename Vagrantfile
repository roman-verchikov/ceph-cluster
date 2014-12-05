# vi: ft=ruby:sw=2:ts=2:et

VAGRANTFILE_API_VERSION = "2"

vagrant_user = %x(id -un).strip
vagrant_uid = %x(id -u #{vagrant_user}).strip

nodes = {
  controller: {ip: '192.168.1.100'}
}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "sincerely/trusty64"
  config.vm.synced_folder ENV["HOME"], "/home/#{vagrant_user}", type: "nfs"
  config.vm.provision "shell",
                      path: "provision-user.sh",
                      args: ["--user", vagrant_user, "--uid", vagrant_uid]

  nodes.each_key do |nodename|
    node_data = nodes[nodename]
    config.vm.define nodename do |current_node|
      current_node.vm.hostname = nodename
      config.vm.network "private_network", ip: node_data[:ip]
    end
  end
end
