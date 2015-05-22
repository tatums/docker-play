#!/usr/bin/env ruby

require 'docker'
Docker.url = 'tcp://10.0.1.13:2376'



## Setup the DB Container
if Docker::Container.all.flat_map {|c| c.info["Names"] }.include?("/db")
  puts "* The DB Container is already up and running"
  image = Docker::Image.create('fromImage' => 'postgres')
else
  puts "* Creating and Starting the DB container"
  container = Docker::Container.create({'name' => 'db', 'Image' => 'postgres', "ExposedPorts": { "5432/tcp": {} } })
  container.start({'PortBindings' => {'5432/tcp' => [{'HostIp' => '0.0.0.0', 'HostPort' => '5432'}]}})
end


## Setup the APP Image
puts "\nbuilding app"

image = Docker::Image.build_from_dir('./app')
image.tag('repo' => 'tatums/app', 'force' => true)



puts "\n == App Containers =="
## Setup the APP Containers
container = Docker::Container.create('Cmd' => ['rake', 'db:create'], 'Image' => 'tatums/app' )
container.start({'Links' => ['db:db']})

container = Docker::Container.create('Cmd' => ['rake', 'db:migrate'], 'Image' => 'tatums/app' )
container.start({'Links' => ['db:db']})

## 01
container1 = Docker::Container.create('Cmd' => ['rails', 'server', '-b', '0.0.0.0'], 'Image' => 'tatums/app', "ExposedPorts": { "3000/tcp": {} } )
container1.start({'Binds'=> [ "/app/log:/app/log" ], 'Links' => ['db:db'], 'PortBindings' => {'3000/tcp' => [{'HostIp' => '0.0.0.0', 'HostPort' => '3000'}]}})

