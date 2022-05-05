#!/bin/bash

# Script to scaffold out a Laravel API micro-service in docker driven by Open API

# TODO: Create a start.html file? No just add it to the readme

# 1. Get the variables
# TODO: ensure all variables are present
while getopts n:f:v:p: flag
do
    case "${flag}" in
        n) name=${OPTARG};;
        f) parent_folder=${OPTARG};;
        v) version=${OPTARG};;
        p) starting_port=${OPTARG};;
    esac
done

template_path=`pwd`

port_index=$starting_port
port_swagger=$(( $starting_port + 1 ))
port_mock=$(( $starting_port + 2 ))
port_api=$(( $starting_port + 3 ))
port_mysql=$(( $starting_port + 4 ))
open_api_file="${name}-v${version}.yaml"

echo "Creating new service for: $name v$version in $parent_folder";
echo "Port range: $starting_port onwards";

# 1. Create folder structure (removing old first if exists)
folder=${parent_folder}/${name}-service
rm -rf $folder || exit
mkdir -p $folder
mkdir -p $folder/docs
mkdir -p $folder/docs/features
mkdir -p $folder/docs/open-api
mkdir -p $folder/conf/php
mkdir -p $folder/conf/nginx

# Copy the template readme
cp ./templates/README.md $folder/README.md

# Copy and create the env file
cp ./templates/.env $folder/.env
echo " " >> $folder/.env
echo "MYSQL_HOST=${name}-mysql" >> $folder/.env
echo "MYSQL_DATABASE=${name}" >> $folder/.env
echo "PORT_SWAGGER=${port_swagger}" >> $folder/.env
echo "PORT_MOCK=${port_mock}" >> $folder/.env
echo "PORT_API=${port_api}" >> $folder/.env
echo "PORT_MYSQL=${port_mysql}" >> $folder/.env

# Copy the Open API file
cp ./templates/open-api/template.yaml $folder/docs/open-api/$name-v$version.yaml

# Copy the files required for docker
cp ./templates/docker/docker-compose.yaml $folder/docker-compose.yaml
cp ./templates/nginx/nginx-mock.conf $folder/conf/nginx/nginx-mock.local.conf
cp ./templates/nginx/nginx-api.conf $folder/conf/nginx/nginx-api.local.conf
cp ./templates/php/php.ini $folder/conf/php/php.local.ini

# Set-up base install of laravel, remove what's not needed & add in any starter files we've created
cd $folder/src
composer create-project laravel/laravel php
rm -rf $folder/src/php/resources/css
rm -rf $folder/src/php/resources/js
rm -rf $folder/src/php/package.json
cp ${template_path}/templates/laravel/.env.local $folder/src/php/.env
cp ${template_path}/templates/laravel/routes/api.php $folder/src/php/routes/api.php
cp ${template_path}/templates/laravel/routes/api-routes.php $folder/src/php/routes/api-v${version}.php
cp ${template_path}/templates/laravel/routes/api-transform.php $folder/src/php/routes/api-transform.php
cp ${template_path}/templates/laravel/app/Providers/RouteServiceProvider.php $folder/src/php/app/Providers/RouteServiceProvider.php
# TODO: create the scaffold of the API validation tests against example open api spec?

# Move the behat & feature files
cp ${template_path}/templates/behat/behat.yml $folder/src/php/behat.yml
cp ${template_path}/templates/behat/features/healthCheck.feature $folder/docs/features/${name}heathCheck.feature
mkdir -p $folder/src/php/features/bootstrap
cp ${template_path}/templates/behat/features/bootstrap/FeatureContext.php $folder/src/php/features/bootstrap/FeatureContext.php

# Search and replace the different variables in all files we've set up
export LC_CTYPE=C
export LANG=C
find $folder -type f -exec sed -i '' -e "s/{{name}}/$name/g" {} +
find $folder -type f -exec sed -i '' -e "s/{{version}}/$version/g" {} +
find $folder -type f -exec sed -i '' -e "s/{{open-api-file}}/$open_api_file/g" {} +
find $folder -type f -exec sed -i '' -e "s/{{port-swagger}}/$port_swagger/g" {} +
find $folder -type f -exec sed -i '' -e "s/{{port-mock}}/$port_mock/g" {} +
find $folder -type f -exec sed -i '' -e "s/{{port-api}}/$port_api/g" {} +
find $folder -type f -exec sed -i '' -e "s/{{port-mysql}}/$port_mysql/g" {} +


# Install the spectator OpenAPI test scaffold
cd $folder/src/php
composer require hotmeteor/spectator --dev
php artisan vendor:publish --provider="Spectator\SpectatorServiceProvider"

# Set-up behat
cd $folder/src/php
composer require --dev behat/behat imbo/behat-api-extension

# Initialise git
cd $folder
git init
cp ${template_path}/templates/.gitignore-template $folder/.gitignore # Copy a default git ignore in

# Start up the containers to ensure they work and run the initial migrations
echo "Starting php docker containers and running migrations"
docker-compose up -d
sleep 30; # Just to make sure everything is up and running
docker exec ${name}-php bash -c 'chown -R www-data:www-data storage/; php artisan migrate'
docker-compose down
echo "Done"