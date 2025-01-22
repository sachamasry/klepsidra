# Klepsidra: Justfile v0.1 2025-01-22
#

SCHEMASPY_BASE_DIR			:= '~/Development/vendor/schemaspy'
SCHEMASPY_JAR				:= 'schemaspy-6.2.4.jar'
SCHEMASPY_JDBC_DRIVER		:= 'sqlite-jdbc-3.46.0.0.jar'
SCHEMASPY_CONFIG_FILE 		:= './config/schemaspy.properties'

# Klepsidra project justfile
[private]
@help:
    just --list

alias s := run
alias r := run
alias start := run

# Start the Klepsidra web server
run:
	@echo "==> Starting Klepsidra"
	source .env && PORT=4003 MIX_ENV=prod mix phx.server
