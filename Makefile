up:
	sudo docker-compose up -d
build:
	sudo docker-compose build --no-cache --force-rm
	@make up
wp-install:
	wget https://wordpress.org/latest.tar.gz
	tar zxf latest.tar.gz
	mv wordpress html
	rm latest.tar.gz
	mkdir html/wp-content/themes/cleverr
	rm -rf html/wp-content/themes/twentynineteen
	rm -rf html/wp-content/themes/twentyseventeen
	git clone https://github.com/andrew-narolsky/cleverr-wp-theme.git html/wp-content/themes/cleverr
	chmod -R 777 html/wp-content/themes/cleverr/.git
	rm -rf html/wp-content/themes/cleverr/.git
create-project:
	cp .env-example .env
	cp nginx/sites/site.conf.example-dev nginx/sites/site.conf
	@make wp-install
	@make build
	@make up
install-recommend-plugins:
	rm -rf html/wp-content/plugins
	git clone  https://github.com/andrew-narolsky/wp-plugins.git html/wp-content/plugins
	chmod -R 777 html/wp-content/plugins/.git
	rm -rf html/wp-content/plugins/.git
stop:
	sudo docker-compose stop
down:
	sudo docker-compose down
restart:
	@make down
	@make up
destroy:
	sudo docker-compose down --rmi all --volumes
destroy-volumes:
	sudo docker-compose down --volumes
ps:
	sudo docker-compose ps
logs:
	sudo docker-compose logs