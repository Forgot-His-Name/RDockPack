#!/usr/bin/env ruby

require 'net/http'
require 'yaml'
require 'json'
require 'base64'

require_relative 'rdp'
require_relative 'rdp_init'
require_relative 'rdp_api'
require_relative 'rdp_sup'
require_relative 'rdp_fetch'

images = []
#images << 'python:3.9-buster'
#images << 'alpine:3.12'
#images << 'docker.elastic.co/elasticsearch/elasticsearch:8.1.2'
images << 'docker.elastic.co/kibana/kibana:8.1.2'

rdp = RDockPack.new

rdp.arch = 'amd64'
rdp.variant = nil
rdp.debug = false

rdp.run images
