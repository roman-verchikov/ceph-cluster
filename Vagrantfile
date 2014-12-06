# vi: ft=ruby:sw=2:ts=2:et

VAGRANTFILE_API_VERSION = "2"

vagrant_user = %x(id -un).strip
vagrant_uid = %x(id -u #{vagrant_user}).strip

nodes = {
  "controller" => {"ip" => "192.168.1.100"},
  "ceph_node1" => {"ip" => "192.168.1.200"},
  "ceph_node2" => {"ip" => "192.168.1.201"},
  "ceph_node3" => {"ip" => "192.168.1.202"}
}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "sincerely/trusty64"
  config.vm.synced_folder ENV["HOME"], "/home/#{vagrant_user}", :type => "nfs"
  config.vm.provision "shell",
                      :path => "provisioning/provision-user.sh",
                      :args => ["--user", vagrant_user, "--uid", vagrant_uid]
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "provisioning/playbook.yml"
    ansible.sudo = true
    ansible.groups = {
      "controllers" => ["controller"],
      "nodes" => nodes.each_key.select { |k| k != "controller" }
    }
  end

  nodes.each_key do |nodename|
    node_data = nodes[nodename]
    config.vm.define nodename do |current_node|
      current_node.vm.hostname = nodename
      config.vm.network "private_network", :ip => node_data["ip"]
      if nodename == 'controller'
        config.vm.provision "shell",
                            :path => "provisioning/ceph-controller.sh"
      else
        config.vm.provision "ansible",
                            :playbook => "provisioning/ceph-node.yaml",
                            :sudo => true
      end
    end
  end
end
