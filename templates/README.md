## {{name}} service

### TODO:
* Insert diagram HERE
* Follow micro-service checklist

### Running the containers:

```
docker-compose up
```

### Check the service works:

* Check swagger spec is running: http://localhost:{{port-swagger}}
* Check mock server is running: http://localhost:{{port-mock}}/v{{version}}/{{name}}/health
* Check api server is running: 
  * Health end point - http://localhost:{{port-api}}/v{{version}}/{{name}}/health
  * Example legacy transform - http://localhost:{{port-api}}/mobile/example

### Connect to the service DB

Use the following credentials to connect to MySQL:

* Database: {{name}}
* Host: localhost
* Port: {{port-mysql}}
* User: root
* Pass: root

### Run the unit tests
Always run the following commands after ssh into the PHP container:

* Unit tests (Laravel PHP Unit - inc OpenAPI validation - /tests)

```docker exec -it {{name}}-php php artisan test``` 

* API tests (Behat - Gherkin - /features)

```docker exec -it {{name}}-php vendor/bin/behat```

### Where can I find things?

* src/php - install of Laravel
* src/php/routes/api-v{{version}}.php - all the routes for this version of the API
* src/php/tests - laravel unit tests - with example Open API validation test
* docs/open-api - Open API spec file
* docs/features - feature files for behat tests - written in Gherkin language
* data - persistent data from docker files - mysql data & logs
* conf - php and nginx configuration files
