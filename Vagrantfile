# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "luxhaven"
  config.vm.box_url = "https://storage.cloud.google.com/luxhaven%2Fvagrant%2Fluxhaven.box?response-content-disposition=attachment;%20filename=luxhaven.box"
  config.vm.network :forwarded_port, guest: 3000, host: 3000
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end
  config.vm.provision :shell, path: 'https://gist.github.com/saiko-chriskun/49d702d3d16cb33f50a9/raw/b282356cdabf7c5dd75b2085e2986ca04a2918f4/gistfile1.txt'
  config.vm.provision :docker do |d|
    d.pull_images 'docker.luxhaven.com:5000/luxhaven'
    d.run 'docker.luxhaven.com:5000/luxhaven:latest',
      cmd: '/luxhaven/docker-server.sh',
      args: "-dns 8.8.8.8 -p 3000:3000 -v /vagrant:/luxhaven -v /var/lib/postgres/data:/postgres"
  end
  config.vm.provision :shell, path: 'https://gist.github.com/saiko-chriskun/8f2f13fc09436698bb56/raw/bd7be85b26e47ff261cabb14fc56df14a050ea94/gistfile1.txt'
end
