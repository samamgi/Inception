COMPOSE = docker compose -f srcs/docker-compose.yml

all: up

up:
	mkdir -p /home/$(USER)/data/mariadb
	mkdir -p /home/$(USER)/data/wordpress
	$(COMPOSE) up --build -d

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down --volumes --remove-orphans

fclean: clean
	docker system prune -af
	sudo rm -rf /home/$(USER)/data/mariadb
	sudo rm -rf /home/$(USER)/data/wordpress

re: fclean all

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

.PHONY: all up down clean fclean re logs ps
