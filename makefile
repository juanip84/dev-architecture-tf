PLAN_FILE := pending.tfplan

TF_COMMAND_CHECK=$(shell which terraform > /dev/null 2>&1 ; echo $$? )

requirements_check:
ifeq ($(TF_COMMAND_CHECK), 1)
	$(error The command 'terraform' cannot be found in your path. Please correct your path or install 'terraform')
endif

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

init: requirements_check ## Initialization (typically only needed for fresh working copies)
	@export AWS_PROFILE=OUTSIDE; \echo "You are Working in "$$AWS_PROFILE; \terraform init

clean: ## Removes temporal files
	@rm -f $(PLAN_FILE)

unlock: requirements_check ## Forces remote lock into an unlocked state
	@export AWS_PROFILE=OUTSIDE; \echo $$AWS_PROFILE; \terraform force-unlock

state-list: ## List all objects in the infraestructure
	@export AWS_PROFILE=OUTSIDE; \echo "You are Working in "$$AWS_PROFILE; \terraform state list

apply: ## Applies the pending plan against production infrastructure
	@export AWS_PROFILE=OUTSIDE; \echo "Workspaces Available"; \terraform workspace list; \echo "You are Working in "$$AWS_PROFILE; \terraform apply -lock=true "$(PLAN_FILE)"
	@rm -f $(PLAN_FILE)

plan-all: ## Execute plan to ALL MODULES
	@export AWS_PROFILE=OUTSIDE; \echo "Workspaces Available"; \terraform workspace list; \echo "You are Working in "$$AWS_PROFILE; \terraform plan \
		-out=$(PLAN_FILE) 

plan-destroy: ## Execute plan to ALL MODULES
	@export AWS_PROFILE=OUTSIDE; \echo "Workspaces Available"; \terraform workspace list; \echo "You are Working in "$$AWS_PROFILE; \terraform plan -destroy \
		-out=$(PLAN_FILE) 

show: ## Show terraform state
	@export AWS_PROFILE=OUTSIDE; \echo "You are Working in "$$AWS_PROFILE; \terraform show

get: ## Show terraform state
	@export AWS_PROFILE=OUTSIDE; \echo "You are Working in "$$AWS_PROFILE; \terraform get

graph: ## Create a visual graph of Terraform resources
	@export AWS_PROFILE=OUTSIDE; \echo "You are Working in "$$AWS_PROFILE; \terraform graph

set-version: ## Set TF version for this project
	@tfenv use 0.12.19;
