SHELL := /bin/bash

secrets:
	@rm -f .env.example
	@mkdir -p secrets
	@touch secrets/db_root_password.txt secrets/db_password.txt secrets/wp_password.txt secrets/user_password.txt


	@cat /dev/urandom | base32 | head -c 32 > secrets/db_root_password.txt
	@cat /dev/urandom | base32 | head -c 32 > secrets/db_password.txt
	@cat /dev/urandom | base32 | head -c 32 > secrets/wp_password.txt
	@cat /dev/urandom | base32 | head -c 32 > secrets/user_password.txt

	@root_user="root"; \
	root_db_password=$$(cat secrets/db_root_password.txt); \
	wp_password=$$(cat secrets/wp_password.txt); \
	wp_admin_password=$$(cat secrets/user_password.txt); \
	wp_user_password=$$(cat secrets/user_password.txt); \
	read -p "Enter your config mode (0 = default, 1 = custom): " config_mode; \
	if [ "$$config_mode" -eq 0 ]; then \
		echo "Using default configuration."; \
		cp /home/mobenais/secrets/.default_conf.txt . ;\
		mapfile -t conf < .default_conf.txt; \
		rm .default_conf.txt; \
		wp_db_name="$${conf[0]}"; \
		wp_user="$${conf[1]}"; \
		wp_admin_user="$${conf[2]}"; \
		wp_admin_email="$${conf[3]}"; \
		wp_user_username="$${conf[4]}"; \
		wp_user_email="$${conf[5]}"; \
	else \
		echo "Using custom configuration."; \
		read -p "Enter WordPress database name: " wp_db_name; \
		read -p "Enter WordPress database user: " wp_user; \
		read -p "Enter WordPress admin username: " wp_admin_user; \
		read -p "Enter WordPress admin email: " wp_admin_email; \
		read -p "Enter WordPress regular user username: " wp_user_username; \
		read -p "Enter WordPress regular user email: " wp_user_email; \
	fi; \
	echo "DB_ROOT_USER=$$root_user" > srcs/.env; \
	echo "DB_ROOT_PASSWORD=$$root_db_password" >> srcs/.env; \
	echo "NAME_DATABASE=$$wp_db_name" >> srcs/.env; \
	echo "DB_USER=$$wp_user" >> srcs/.env; \
	echo "DB_PASSWORD=$$wp_password" >> srcs/.env; \
	echo "WP_ADMIN_USER=$$wp_admin_user" >> srcs/.env; \
	echo "WP_ADMIN_EMAIL=$$wp_admin_email" >> srcs/.env; \
	echo "WP_ADMIN_PASSWORD=$$wp_admin_password" >> srcs/.env; \
	echo "WP_USER_USERNAME=$$wp_user_username" >> srcs/.env; \
	echo "WP_USER_EMAIL=$$wp_user_email" >> srcs/.env; \
	echo "WP_USER_PASSWORD=$$wp_user_password" >> srcs/.env; \
	printf "[\033[32mmessage\033[0m] .env generated successfully."



secret_re:
	make clean && make secrets

clean:
	@rm -rf secrets
	@rm -f srcs/.env
	@rm -f .default_conf.txt
	@echo "DB_ROOT_USER=" > .env.example
	@echo "DB_ROOT_PASSWORD=" >> .env.example
	@echo "DB_DATABASE=" >> .env.example
	@echo "DB_USER=" >> .env.example
	@echo "DB_PASSWORD=" >> .env.example
	@echo "WP_ADMIN_USER=" >> .env.example
	@echo "WP_ADMIN_EMAIL=" >> .env.example
	@echo "WP_ADMIN_PASSWORD=" >> .env.example
	@echo "WP_USER_USERNAME=" >> .env.example
	@echo "WP_USER_EMAIL=" >> .env.example
	@echo "WP_USER_PASSWORD=" >> .env.example
	@printf "[\033[32mmessage\033[0m] Cleaned up secrets and .env file. .env.example has been reset.\n"