# Klepsidra: Justfile v0.1 2025-01-22
#

set dotenv-load true

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

setup: get-production-dependencies tls-certificate compile-project db-migrations setup-assets

deploy: update-production-dependencies compile-project db-migrations build-assets


# Clean dependencies and project files
clean: clean-app clean-dependencies

# Clean project files only
clean-app:
	@echo "==> Cleaning generated application files"
	mix clean
	@echo "--> Successfully cleaned generated application files"


alias ssl-certificate := tls-certificate

# Generate self-signed SSL/TLS certificates, for local use only
tls-certificate:
	@echo "==> Generating self-signed TLS certificate..."
	mix phx.gen.cert
	@echo "--> Successfully generated self-signed TLS certificate"


alias get-dependencies := get-production-dependencies

# Get production dependencies
get-production-dependencies:
	@echo "==> Getting and updating dependencies"
	mix deps.get --only prod
	@echo "--> Successfully downloaded all dependencies"

alias update-dependencies := update-production-dependencies

# Update development dependencies
update-development-dependencies:
	@echo "==> Updating development dependencies"
	mix deps.update --all
	@echo "--> Successfully updated all development depedencies"

# Update production dependencies
update-production-dependencies:
	@echo "==> Updating production dependencies"
	mix deps.update --all --only prod
	@echo "--> Successfully updated all production depedencies"

# Clean all dependencies as well as the project's files
clean-dependencies:
	@echo "==> Cleaning application dependencies"
	mix deps.clean --all
	@echo "--> Successfully cleaned application dependencies"

# Unlocks all dependecies
unlock-dependencies:
	@echo "==> Unlock dependencies"
	mix deps.unlock --all
	@echo "--> Successfully unlocked dependencies"


# Compile project in production environment
compile-project:
	@echo "==> Compiling project"
	MIX_ENV=prod mix compile
	@echo "--> Successfully compiled project"


# Install static assets in production environment
setup-assets:
	@echo "==> Initialising static application assets"
	MIX_ENV=prod mix assets.setup
	@echo "--> Successfully Initialised application assets"

alias compile-assets := build-assets

# Build all static assets in production environment
build-assets:
	@echo "==> Building static application assets"
	MIX_ENV=prod mix assets.build
	@echo "--> Successfully built  application assets"

# Deploy all static assets in production environment
deploy-assets:
	@echo "==> Preparing static application assets for deployment"
	MIX_ENV=prod mix assets.deploy
	@echo "--> Successfully prepared application assets for deployment"

# Gets Lucide icon set for local use. NOTE: Possibly deprecated
get-lucide-icons:
	@echo "==> Getting latest Lucide icons from upstream repository..."
	git clone https://github.com/lucide-icons/lucide.git priv/lucide && \
	MIX_ENV=prod mix lucide.gen
	@echo "--> Successfully updated Lucide icon set from upstream repository"


# Display repository migration status for production environment
db-migrations:
	@echo "==> Getting database migration status"
	MIX_ENV=prod mix ecto.migrations

# Run database migrations in production environment
db-migrate:
	@echo "==> Completing database migrations"
	MIX_ENV=prod mix ecto.migrate
	@echo "--> Database successfully migrated"

# Generate database schema documentation
db-doc:
	@echo "==> Generating database schema documentation"
	java -jar $(SCHEMASPY_BASE_DIR)/$(SCHEMASPY_JAR) -dp $(SCHEMASPY_BASE_DIR)/ -configFile $(SCHEMASPY_CONFIG_FILE)
	@echo "--> Database successfully generated"


# Run all predefined quality control checks on project
check:
	@echo "==> Running all code analysis & testing tools"
	mix check --config .check.exs || mix check --config .check.exs --retry || mix check --config .check.exs --retry
	@echo "--> Successfully ran all code analysis & testing tools"

# Run all code tests
test:
	@echo "==> Running all code tests"
	mix test
	@echo "--> Successfully ran all code tests"

# Run all code tests on code updated since last test
stest:
	@echo "==> Running tests on code updated since last full codebase test"
	mix test --stale
	@echo "--> Successfully ran code tests"


# Geaerate HTML test coverage report
coverage-report:
	@echo "==> Generating test coverage report"
	MIX_ENV=test mix coveralls.html
	@echo "--> Test coverage report generated, in ./cover/excoveralls.html"

# Generate test coverage report, printing to console
coverage-console:
	@echo "==> Generating test coverage report"
	MIX_ENV=test mix coveralls
	@echo "--> Test coverage summary printed to console"

# Generate detailed test coverage report
coverage-console-detailed:
	@echo "==> Generating detailed test coverage report"
	MIX_ENV=test mix coveralls.detail
	@echo "--> Detailed test coverage summary printed to console"


# Generate detailed code dependency graph
dependency-graph:
	@echo "==> Generating detailed code dependency graph"
	mix xref graph --format dot --output code_analysis/xref_graph.dot
	dot -Grankdir=LR -Epenwidth=2 -Ecolor=#a0a0a0 -Tpng ./code_analysis/xref_graph.dot -o ./code_analysis/xref_graph.png
	@echo "--> Detailed code dependency graph generated, in ./code_analysis/xref_graph.png"


# Generate Paraxial site and code vulnerability scan
security-scan:
	@echo "==> Generating detailed Paraxial codebase scan"
	source ./.env && mix paraxial.scan
	@echo "--> Detailed Paraxial codebase scan complete. Run the application server to upload scan results"


# Rebuild database full-text search index
rebuild-fts-index:
	@echo "==> Building new full-text search (FTS) index"
	MIX_ENV=prod mix rebuild_fts_index
	@echo "--> Successfully built new full-text search (FTS) index"
