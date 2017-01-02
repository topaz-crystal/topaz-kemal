@makefile = <<-MAKEFILE

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
