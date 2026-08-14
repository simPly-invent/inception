SHELL := /bin/bash

# DB
# root_user=root // default
# root_password=
#
# wp_user=wordpress
# wp_db_name=wp_database
# wp_user_password=
#
# WORDPRES
# wp_user=wordpress
# wp_db_name=wp_database
# wp_user_password=
#
# root_username=mobenais
# root_email=mobenais@email.fr
# root_password=
#
# user_username=user
# user_email=user@email.fr
# user_password=
#
#
# NGINX

secrets:	
	mkdir -p secrets
	touch secrets/credentials.txt secrets/db_password.txt secrets/db_root_password.txt

	cat /dev/urandom | base32 | head -c 32 > secrets/credentials.txt
	cat /dev/urandom | base32 | head -c 32 > secrets/db_password.txt
	cat /dev/urandom | base32 | head -c 32 > secrets/db_root_password.txt
	rm .env.example

	

	read -p "Enter root database username: " answer; \
	read -p "Enter root database password: " password; \
	read -p "Enter database name: " dbname; \
	read -p "Enter database username: " dbuser; \

	for file in secrets/*; do \
	    line=$$(cat "$$file"); \
	    if [[ "$$file" == *"credentials.txt" ]]; then \
	        echo "CREDENTIALS=$$line" >> .env; \
	    elif [[ "$$file" == *"db_password.txt" ]]; then \
	        echo "DB_PASSWORD=$$line" >> .env; \
	    elif [[ "$$file" == *"db_root_password.txt" ]]; then \
	        echo "DB_ROOT_PASSWORD=$$line" >> .env; \
		fi \
	done


clean:
	@rm -rf secrets
	@rm -f .env
	@echo "CREDENTIALS=CREDENTIALS_EXAMPLE" > .env.example
	@echo "DB_PASSWORD=DB_PASSWORD_EXAMPLE" >> .env.example
	@echo "DB_ROOT_PASSWORD=DB_ROOT_PASSWORD_EXAMPLE" >> .env.example
	@echo "Secrets cleaned up."


# 	sudo docker secret rm credentials.txt db_password.txt db_root_password.txt