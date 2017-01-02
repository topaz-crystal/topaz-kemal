#!/usr/bin/ruby

require "net/http"
require "uri"
require "open3"
require "yaml"

makefile = <<-MAKEFILE

MODELS = src/models/*.cr

setup: $(wildcard MODELS)
\tcrystal deps
\tcrystal run src/utils/setup.cr

migration: $(wildcard MODELS)
\tcrystal run src/utils/migration.cr

build: src/$PROJNAME$.cr
\tcrystal build src/$PROJNAME$.cr --release -o bin/server

run: build
\tbin/server

clean:
\trm -rf shard.lock
\trm -rf lib
\trm -rf .shards

help:
\techo "HELP!"

MAKEFILE

LOG = "\e[32m[Topaz x Kemal]\e[0m "

def log msg
  puts "#{LOG}#{msg}"
end

def cursor
  print "> "
end

def tag t
  "$#{t}$"
end

def command_check
  log "Command check ..."
  log "Passed!"
end

def exec_cmd cmd
  res = Open3.capture3 cmd
  puts res[0]
end

def input description

  result = ""

  while result.empty?
    log description
    cursor
    result = gets.chop
  end

  result
end

def shard_yml_update
  shard_yml = YAML.load_file "shard.yml"
  shard_yml["dependencies"] = {}
  shard_yml["dependencies"]["kemal"] = {}
  shard_yml["dependencies"]["kemal"]["github"] = "kemalcr/kemal"
  shard_yml["dependencies"]["topaz"] = {}
  shard_yml["dependencies"]["topaz"]["github"] = "topaz-crystal/topaz"

  File.delete "shard.yml"
  YAML.dump shard_yml, File.open("shard.yml", "w")
end

command_check

install_dir  = input "Installed Dir" # Should default
project_name = input "Project Name"

Dir.chdir install_dir do
  
  exec_cmd "crystal init app #{project_name}"
  
  Dir.chdir project_name do
    
    log "Constructing project..."
    
    shard_yml_update
    
    Dir.mkdir "bin"
    Dir.mkdir "src/models"
    Dir.mkdir "src/utils"

    open "Makefile", "w" do |file|
      file.write(makefile.gsub(tag("PROJNAME"), project_name))
    end
  end
end









