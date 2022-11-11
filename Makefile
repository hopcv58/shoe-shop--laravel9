dir=${CURDIR}
project=-p laravel
service=laravel:latest
project_name=laravel
laravel_user=-u www-data

build:
	@docker-compose -f docker-compose.yml build

build-no-cache:
	@docker-compose -f docker-compose.yml build --no-cache

start:
	@docker-compose -f docker-compose.yml $(project) up -d

stop:
	@docker-compose -f docker-compose.yml $(project) down

restart: stop start

ssh:
	@docker-compose $(project) exec $(laravel_user) laravel bash

ssh-root:
	@docker-compose $(project) exec laravel bash

ssh-nginx:
	@docker-compose $(project) exec nginx /bin/sh

ssh-mysql:
	@docker-compose $(project) exec mysql bash

exec:
	@docker-compose $(project) exec $(laravel_user) laravel $$cmd

exec-bash:
	@docker-compose $(project) exec $(laravel_user) laravel bash -c "$(cmd)"

exec-by-root:
	@docker-compose $(project) exec laravel $$cmd

composer-install:
	@make exec-bash cmd="COMPOSER_MEMORY_LIMIT=-1 composer install --optimize-autoloader"

composer-update:
	@make exec-bash cmd="COMPOSER_MEMORY_LIMIT=-1 composer update"

key-generate:
	@make exec cmd="php artisan key:generate"

info:
	@make exec-bash cmd="php artisan --version"
	@make exec-bash cmd="php artisan env"
	@make exec-bash cmd="php --version"

logs:
	@docker logs -f $(project_name)_laravel

logs-nginx:
	@docker logs -f $(project_name)_nginx

logs-mysql:
	@docker logs -f $(project_name)_mysql

drop-migrate:
	@make exec-bash cmd="php artisan migrate:fresh"

migrate:
	@make exec-bash cmd="php artisan migrate --force"

seed:
	@make exec-bash cmd="php artisan db:seed --force"

all:
	@make build
	@make start
	@make composer-install
	@make migrate
	@make seed
