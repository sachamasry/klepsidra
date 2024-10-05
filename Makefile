SCHEMASPY_BASE_DIR			= ~/Development/vendor/schemaspy
SCHEMASPY_JAR				= schemaspy-6.2.4.jar
SCHEMASPY_JDBC_DRIVER		= sqlite-jdbc-3.46.0.0.jar
SCHEMASPY_CONFIG_FILE 		= ./config/schemaspy.properties

all:
	@echo "\nThe following targets are available:\n"
	@echo 
	@echo "	check				Run all code analysis and testing tools"
	@echo 
	@echo "	coverage			Produce detailed test coverage report, in ./cover/excoveralls.html"
	@echo "	coverage-console		Print test coverage report to console"
	@echo "	coverage-console-detailed"
	@echo "					Print detailed test coverage report to console"
	@echo 
	@echo "	dependency-graph		Produce detailed code dependency graph"
	@echo 
	@echo "	security-scan			Run code and license scans"
	@echo 
	@echo "	deploy				Complete application production deployment"
	@echo "	get-dependencies 		Download project dependencies"
	@echo "	compile-project			Compile project codebase"
	@echo "	compile-assets			Compile static application assets"
	@echo "	db-migration 			Migrate database"
	@echo "	db-doc 				Generate database schema documentation"
	@echo "	"

deploy: get-production-dependencies compile-project db-migration compile-assets

get-production-dependencies:
	@echo "==> Getting and updating dependencies"
	mix deps.get --only prod
	@echo ""
	
compile-project:
	@echo "==> Compiling project"
	MIX_ENV=prod mix compile
	@echo ""

compile-assets:
	@echo "==> Compiling static application assets"
	MIX_ENV=prod mix assets.deploy
	@echo ""

db-migration:
	@echo "==> Completing database migrations"
	MIX_ENV=prod mix ecto.migrate
	@echo ""

db-doc:
	@echo "==> Generating database schema documentation"
	java -jar $(SCHEMASPY_BASE_DIR)/$(SCHEMASPY_JAR) -dp $(SCHEMASPY_BASE_DIR)/ -configFile $(SCHEMASPY_CONFIG_FILE) 
	@echo ""

check:
	mix check --config .check.exs

# Test coverage
coverage:
	@echo "==> Generating test coverage report"
	MIX_ENV=test mix coveralls.html
	@echo "==> Test coverage report generated, in ./cover/excoveralls.html"

coverage-console:
	@echo "==> Generating test coverage report"
	MIX_ENV=test mix coveralls
	@echo "==> Test coverage summary printed to console"

coverage-console-detailed:
	@echo "==> Generating detailed test coverage report"
	MIX_ENV=test mix coveralls
	@echo "==> Detailed test coverage summary printed to console"

# Code dependency analysis

dependency-graph:
	@echo "==> Generating detailed code dependency graph"
	mix xref graph --format dot --output code_analysis/xref_graph.dot
	dot -Grankdir=LR -Epenwidth=2 -Ecolor=#a0a0a0 -Tpng ./code_analysis/xref_graph.dot -o ./code_analysis/xref_graph.png
	@echo "==> Detailed code dependency graph generated, in ./code_analysis/xref_graph.png"

# Site and code vulnerability scan
security-scan:
	@echo "==> Generating detailed Paraxial codebase scan"
	source ./.env && mix paraxial.scan
	@echo "==> Detailed Paraxial codebase scan complete. Run the application server to upload scan results"
