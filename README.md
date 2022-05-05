# Laravel / Docker Micro-service Template

Commands to scaffold out an OpenAPI based micro-service running locally on Laravel / MySQL / Docker, along with example code and tests.

## Commands

Run from the root of this project (not yet made it relative).

``./scripts/scaffold-service.sh -n [name] -f [parent-folder] -v [version] -p [starting-port-number]``

* name = name of the service eg example
* parent-folder = absolute path of the folder to create the new project in eg ~/workspace/services
* version = integer: your version for the API you are creating eg 4
* starting-port = integer: start of the port range to use for local docker containers eg 8090

Once these have been run, look at the readme in your generated service for how to run the service.

## Scaffold service 

This script currently creates the following:

* New folder for service
* conf, src/php & docs folders
* ReadMe with:
  * links to the local hosts
  * checklist of what needs to be available per service?
* OpenAPI file
* Docker file with
  * Hosted swagger
  * Mock server using Stoplight Prism based on the OpenAPI file
  * API server
  * MySQL server
* Install of Laravel
* Initialisation of git & .gitignore
* Example OpenAPI endpoints in file
* Healthcheck and example get implemented in Laravel
* Example OpenApi validation laravel test
* Example behat feature test for healthcheck endpoint

