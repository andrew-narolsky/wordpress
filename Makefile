up:
	docker-compose up -d
build:
	docker-compose build --no-cache --force-rm
	@make up
wp-install:
	wget https://wordpress.org/latest.tar.gz
	tar zxf latest.tar.gz
	mv wordpress html
	rm latest.tar.gz
	rm -rf .git
create-project:
	# cp .env-example .env
	cp nginx/sites/site.conf.example-dev nginx/sites/site.conf
	@make wp-install
	@make build
	@make up
install-theme:
	mkdir html/wp-content/themes/cleverr
	rm -rf html/wp-content/themes/twentynineteen
	rm -rf html/wp-content/themes/twentyseventeen
	git clone https://github.com/andrew-narolsky/cleverr-wp-theme.git html/wp-content/themes/cleverr
	chmod -R 777 html/wp-content/themes/cleverr/.git
	rm -rf html/wp-content/themes/cleverr/.git
install-recommend-plugins:
	rm -rf html/wp-content/plugins
	git clone  https://github.com/andrew-narolsky/wp-plugins.git html/wp-content/plugins
	chmod -R 777 html/wp-content/plugins/.git
	rm -rf html/wp-content/plugins/.git
stop:
	docker-compose stop
down:
	docker-compose down
restart:
	@make down
	@make up
destroy:
	docker-compose down --rmi all --volumes
destroy-volumes:
	docker-compose down --volumes
ps:
	docker-compose ps
logs:
	docker-compose logs
