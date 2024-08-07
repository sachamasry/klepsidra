SCHEMASPY_BASE_DIR			= ~/Development/vendor/schemaspy
SCHEMASPY_JAR				= schemaspy-6.2.4.jar
SCHEMASPY_JDBC_DRIVER		= sqlite-jdbc-3.46.0.0.jar
SCHEMASPY_CONFIG_FILE 		= ./config/schemaspy.properties

all:
	@echo "\nThe following targets are available:\n"
	@echo "	compile-asset			Compile static application assets"
	@echo "	db-doc 					Generate database schema documentation"

compile-assets:
	MIX_ENV=prod mix assets.deploy

db-doc:
	java -jar $(SCHEMASPY_BASE_DIR)/$(SCHEMASPY_JAR) -dp $(SCHEMASPY_BASE_DIR)/ -configFile $(SCHEMASPY_CONFIG_FILE) 
