SHELL := /bin/bash


secrets:
	@mkdir -p secrets; \
	sudo docker swarm init 2>/dev/null || true; \
	credentials=$$(openssl rand -hex 16); \
	db_password=$$(openssl rand -hex 16); \
	db_root_password=$$(openssl rand -hex 16); \
	echo -n "$$credentials" > secrets/credentials.txt; \
	echo -n "$$db_password" > secrets/db_password.txt; \
	echo -n "$$db_root_password" > secrets/db_root_password.txt; \
	i=1; \
	for file in secrets/*; do \
		name=$$(basename $$file); \
		printf "[\033[32mSecret\033[0m $$i] Creating secret $$name... \n"; \
		sudo docker secret create $$name $$file > /dev/null || echo "secret $$name already exists, skipping"; \
		i=$$((i + 1)); \
	done; \
	sudo docker swarm leave --force; \
	passwords=("$$credentials" "$$db_password" "$$db_root_password"); \
	index=0; \
	while read -r line; do \
		if [[ -z "$$line" || "$$line" == \#* ]]; then \
			echo "$$line"; \
			continue; \
		fi; \
		key="$${line%%=*}"; \
		echo "$${key}=$${passwords[$$index]}"; \
		index=$$((index + 1)); \
	done < .env.example > .env; \
	rm .env.example

clean:
	@rm -rf secrets
	@rm -f .env
	@echo "CREDENTIALS=CREDENTIALS_EXAMPLE" > .env.example
	@echo "DB_PASSWORD=DB_PASSWORD_EXAMPLE" >> .env.example
	@echo "DB_ROOT_PASSWORD=DB_ROOT_PASSWORD_EXAMPLE" >> .env.example
	@echo "Secrets cleaned up."


# 	sudo docker secret rm credentials.txt db_password.txt db_root_password.txt