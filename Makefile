help: ## Show this help
	@echo "Makefile directives:\n"
	@grep '\#\#' Makefile | sed -e 's/\#\#/->/g'
	@echo ""

up: ## Runs the application in the foreground for development
	bundle exec mailcatcher --foreground

daemon: ## Runs the application in daemon (use kill to stop it, gl)
	bundle exec mailcatcher

assets: ## Compiles the assets 
	rake assets

dependencies: ## Install application dependencies
	bundle install
