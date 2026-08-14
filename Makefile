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
		
		wp_db_name=""; \
		wp_user=""; \
		wp_admin_user=""; \
		wp_admin_email=""; \
		wp_user_username=""; \
		wp_user_email=""; \
	else \
		echo "Using custom configuration."; \
		read -p "Enter WordPress database name: " wp_db_name; \
		read -p "Enter WordPress database user: " wp_user; \
		read -p "Enter WordPress admin username: " wp_admin_user; \
		read -p "Enter WordPress admin email: " wp_admin_email; \
		read -p "Enter WordPress regular user username: " wp_user_username; \
		read -p "Enter WordPress regular user email: " wp_user_email; \
	fi; \
	echo "MYSQL_ROOT_USER=$$root_user" > .env; \
	echo "MYSQL_ROOT_PASSWORD=$$root_db_password" >> .env; \
	echo "MYSQL_DATABASE=$$wp_db_name" >> .env; \
	echo "MYSQL_USER=$$wp_user" >> .env; \
	echo "MYSQL_PASSWORD=$$wp_password" >> .env; \
	echo "WP_ADMIN_USER=$$wp_admin_user" >> .env; \
	echo "WP_ADMIN_EMAIL=$$wp_admin_email" >> .env; \
	echo "WP_ADMIN_PASSWORD=$$wp_admin_password" >> .env; \
	echo "WP_USER_USERNAME=$$wp_user_username" >> .env; \
	echo "WP_USER_EMAIL=$$wp_user_email" >> .env; \
	echo "WP_USER_PASSWORD=$$wp_user_password" >> .env; \
	echo ".env generated successfully."

clean:
	@rm -rf secrets
	@rm -f .env
	@echo "MYSQL_ROOT_USER=" > .env.example
	@echo "MYSQL_ROOT_PASSWORD=" >> .env.example
	@echo "MYSQL_DATABASE=" >> .env.example
	@echo "MYSQL_USER=" >> .env.example
	@echo "MYSQL_PASSWORD=" >> .env.example
	@echo "WP_ADMIN_USER=" >> .env.example
	@echo "WP_ADMIN_EMAIL=" >> .env.example
	@echo "WP_ADMIN_PASSWORD=" >> .env.example
	@echo "WP_USER_USERNAME=" >> .env.example
	@echo "WP_USER_EMAIL=" >> .env.example
	@echo "WP_USER_PASSWORD=" >> .env.example
	@printf "\033[32mCleaned up secrets and .env file. .env.example has been reset.\033[0m\n"