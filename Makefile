SCHEMASPY_BASE_DIR			= ~/Development/vendor/schemaspy
SCHEMASPY_JAR				= schemaspy-6.2.4.jar
SCHEMASPY_JDBC_DRIVER		= sqlite-jdbc-3.46.0.0.jar
SCHEMASPY_CONFIG_FILE 		= ./config/schemaspy.properties

all:
	@echo "\nThe following targets are available:\n"
	@echo
	@echo "	check				Run all code analysis and testing tools"
	@echo "	test				Run all tests on codebase"
	@echo "	stest				Run tests only on newly modified code"
	@echo
	@echo "	coverage-report			Produce detailed test coverage report, in ./cover/excoveralls.html"
	@echo "	coverage-console		Print test coverage report to console"
	@echo "	coverage-console-detailed	Print detailed test coverage report to console"
	@echo
	@echo "	dependency-graph		Produce detailed code dependency graph"
	@echo
	@echo "	security-scan			Run code and license scans"
	@echo
	@echo "	clean				Cleand up generated files and dependencies"
	@echo "	setup				Set up application production environment"
	@echo "	deploy				Deploy application to production"
	@echo
	@echo "	get-dependencies 		Download project dependencies"
	@echo "	update-dependencies 		Update project dependencies"
	@echo "	clean-dependencies 		Update project dependencies"
	@echo "	unlock-dependencies 		Unlock project dependencies"
	@echo
	@echo "	compile-project			Compile project codebase"
	@echo "	compile-assets			Compile static application assets"
	@echo "	deploy-assets			Alias for tailwind default --minify, esbuild default --minify, phx.digest"
	@echo "	get-lucide-icons		Clone the latest Lucide icons from the upstream repository," 
	@echo "					and run generator task."
	@echo
	@echo "	db-migrations 			Show database migrations status"
	@echo "	db-migration 			Migrate database"
	@echo "	db-doc 				Generate database schema documentation"
	@echo

setup: get-production-dependencies tls-certificate compile-project db-migration setup-assets

deploy: update-production-dependencies compile-project db-migration compile-assets

clean: clean-app clean-dependencies

clean-app:
	@echo "==> Cleaning generated application files"
	mix clean
	@echo "--> Successfully cleaned generated application files"


# Run the application
start: run

run:
	@echo "==> Starting application"
	source .env && PORT=4003 MIX_ENV=prod mix phx.server


# SSL/TLS certificates
ssl-certificate: tls-certificate

tls-certificate:
	@echo "==> Generating self-signed TLS certificate..."
	mix phx.gen.cert
	@echo "--> Successfully generated self-signed TLS certificate"


# Dependencies
get-dependencies: get-production-dependencies

get-production-dependencies:
	@echo "==> Getting and updating dependencies"
	mix deps.get --only prod
	@echo "--> Successfully downloaded all dependencies"

update-dependencies: update-production-dependencies

update-development-dependencies:
	@echo "==> Updating dependencies"
	mix deps.update --all
	@echo "--> Successfully updated all depedencies"

update-production-dependencies:
	@echo "==> Updating dependencies"
	mix deps.update --all --only prod
	@echo "--> Successfully updated all depedencies"

clean-dependencies:
	@echo "==> Cleaning application dependencies"
	mix deps.clean --all
	@echo "--> Successfully cleaned application dependencies"

unlock-dependencies:
	@echo "==> Unlock dependencies"
	mix deps.unlock --all
	@echo "--> Successfully unlocked dependencies"


# Compiling
compile-project:
	@echo "==> Compiling project"
	MIX_ENV=prod mix compile
	@echo "--> Successfully compiled project"


# Static assets
setup-assets:
	@echo "==> Initialising static application assets"
	MIX_ENV=prod mix assets.setup
	@echo "--> Successfully Initialised application assets"

compile-assets: build-assets

build-assets:
	@echo "==> Building static application assets"
	MIX_ENV=prod mix assets.build
	@echo "--> Successfully built  application assets"

deploy-assets:
	@echo "==> Preparing static application assets for deployment"
	MIX_ENV=prod mix assets.deploy
	@echo "--> Successfully prepared application assets for deployment"

get-lucide-icons:
	@echo "==> Getting latest Lucide icons from upstream repository..."
	git clone https://github.com/lucide-icons/lucide.git priv/lucide && \
	MIX_ENV=prod mix lucide.gen
	@echo "--> Successfully updated Lucide icon set from upstream repository"

# Database
db-migrations:
	@echo "==> Getting database migration status"
	MIX_ENV=prod mix ecto.migrations

db-migration:
	@echo "==> Completing database migrations"
	MIX_ENV=prod mix ecto.migrate
	@echo "--> Database successfully migrated"

db-doc:
	@echo "==> Generating database schema documentation"
	java -jar $(SCHEMASPY_BASE_DIR)/$(SCHEMASPY_JAR) -dp $(SCHEMASPY_BASE_DIR)/ -configFile $(SCHEMASPY_CONFIG_FILE) 
	@echo "--> Database successfully generated"


# Quality control
check:
	@echo "==> Running all code analysis & testing tools"
	mix check --config .check.exs || mix check --config .check.exs --retry || mix check --config .check.exs --retry
	@echo "--> Successfully ran all code analysis & testing tools"

test:
	@echo "==> Running all code tests"
	mix test 
	@echo "--> Successfully ran all code tests"

stest:
	@echo "==> Running tests on code updated since last full codebase test"
	mix test --stale
	@echo "--> Successfully ran code tests"


# Test coverage
coverage-report:
	@echo "==> Generating test coverage report"
	MIX_ENV=test mix coveralls.html
	@echo "--> Test coverage report generated, in ./cover/excoveralls.html"

coverage-console:
	@echo "==> Generating test coverage report"
	MIX_ENV=test mix coveralls
	@echo "--> Test coverage summary printed to console"

coverage-console-detailed:
	@echo "==> Generating detailed test coverage report"
	MIX_ENV=test mix coveralls.detail
	@echo "--> Detailed test coverage summary printed to console"


# Code dependency analysis
dependency-graph:
	@echo "==> Generating detailed code dependency graph"
	mix xref graph --format dot --output code_analysis/xref_graph.dot
	dot -Grankdir=LR -Epenwidth=2 -Ecolor=#a0a0a0 -Tpng ./code_analysis/xref_graph.dot -o ./code_analysis/xref_graph.png
	@echo "--> Detailed code dependency graph generated, in ./code_analysis/xref_graph.png"


# Site and code vulnerability scan
security-scan:
	@echo "==> Generating detailed Paraxial codebase scan"
	source ./.env && mix paraxial.scan
	@echo "--> Detailed Paraxial codebase scan complete. Run the application server to upload scan results"
