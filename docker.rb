#!/usr/bin/env ruby

require 'docker'

Docker.url = 'tcp://10.0.1.11:2376'

image = Docker::Image.create('fromImage' => 'ruby:2.2.0')
image.run("apt-get update -qq")
image.run("apt-get install -y build-essential libpq-dev")

puts Docker.version
