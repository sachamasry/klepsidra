SCHEMASPY_BASE_DIR			= ~/Development/vendor/schemaspy
SCHEMASPY_JAR				= schemaspy-6.2.4.jar
SCHEMASPY_JDBC_DRIVER		= sqlite-jdbc-3.46.0.0.jar
SCHEMASPY_CONFIG_FILE 		= ./config/schemaspy.properties

all:
	@echo "\nThe following targets are available:\n"
	@echo "	deploy					Complete application production deployment"
	@echo "	get-dependencies 		Download project dependencies"
	@echo "	compile-project			Compile project codebase"
	@echo "	compile-assets			Compile static application assets"
	@echo "	db-migration 			Migrate database"
	@echo "	db-doc 					Generate database schema documentation"
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
