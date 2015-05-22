
## Ansible
```
ansible-playbook -i hosts playbooks/init.yml
```


## Docker over http
```
sudo docker -d -H tcp://0.0.0.0:2376 -H unix:///var/run/docker.sock
```



## Start Postgres
docker run -p 5432:5432 -d postgres
-- with a name of db
docker run -p 5432:5432 -d --name db postgres

## Start Rails app
docker run -p 3000:3000 -d test rails server -b 0.0.0.0






## with link
docker run -p 3000:3000 -d --link db:db app rails server -b 0.0.0.0
docker run -p 3000:3000 -d --link db:db test rails server -b 0.0.0.0

## share hosts file system with containers.. so it can share logs
docker run -p 3000:3000 -d --link db:db -v /app/log:/app/log app2 rails server -b 0.0.0.0


docker run --link db:db app rake db:create
docker run --link db:db app rake db:migrate

## build image
docker -H 0.0.0.0:2376 build -t tatums/app .

docker -H 0.0.0.0:2376 run --link db:db -i tatums/app rake db:create
docker -H 0.0.0.0:2376 run --link db:db -i tatums/app rake db:migrate








## DB
image = Docker::Image.create('fromImage' => 'postgres')
container = Docker::Container.create({'name' => 'db', 'Image' => 'postgres', "ExposedPorts": { "5432/tcp": {} } })
container.start({'PortBindings' => {'5432/tcp' => [{'HostIp' => '0.0.0.0', 'HostPort' => '5432'}]}})


## App
image = Docker::Image.build_from_dir('app')
image.tag('repo' => 'tatums/app', 'force' => true)

container0 = Docker::Container.create('Cmd' => ['rake', 'db:create'], 'Image' => 'tatums/app' )
container0.start({'Links' => ['db:db']})

container0 = Docker::Container.create('Cmd' => ['rake', 'db:migrate'], 'Image' => 'tatums/app' )
container0.start({'Links' => ['db:db']})

container1 = Docker::Container.create('Cmd' => ['rails', 'server', '-b', '0.0.0.0'], 'Image' => 'tatums/app', "ExposedPorts": { "3000/tcp": {} } )
container1.start({'Binds'=> [ "/app/log:/app/log" ], 'Links' => ['db:db'], 'PortBindings' => {'3000/tcp' => [{'HostIp' => '0.0.0.0', 'HostPort' => '3000'}]}})

container2 = Docker::Container.create('Cmd' => ['rails', 'server', '-b', '0.0.0.0'], 'Image' => 'tatums/app', "ExposedPorts": { "3000/tcp": {} } )
container2.start({'Binds'=> [ "/app/log:/app/log" ], 'Links' => ['db:db'], 'PortBindings' => {'3000/tcp' => [{'HostIp' => '0.0.0.0', 'HostPort' => '3001'}]}})





