SCHEMASPY_JAR				= ~/Development/vendor/schemaspy/schemaspy-6.2.4.jar
SCHEMASPY_JDBC_DRIVER		= ~/Development/vendor/schemaspy/sqlite-jdbc-3.46.0.0.jar
SCHEMASPY_CONFIG_FILE 		= ./config/schemaspy.properties

all:
	@echo "\nThe following targets are available:\n"
	@echo "	db-doc 					Generate database schema documentation"

db-doc:
	java -jar $(SCHEMASPY_JAR) -dp $(SCHEMASPY_JDBC_DRIVER) -configFile $(SCHEMASPY_CONFIG_FILE) 
