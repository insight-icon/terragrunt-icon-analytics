SHELL := /bin/bash -euo pipefail
.PHONY: all test clean

help: 								## Show help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

clear-cache:						## Clear the terragrunt and terraform caches
	@find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \; && \
	find . -type d -name ".terraform" -prune -exec rm -rf {} \; && \
	find . -type f -name "*.tfstate*" -prune -exec rm -rf {} \; && echo "cleared cache"

test:								## Run tests
	go test ./test -v -timeout 15m

test-init:							## Initialize the repo for tests
	go mod init test && go mod tidy

## ---------------------------------------------------------------------------------
## Makefile to run terragrunt commands to setup P-Rep nodes for the ICON Blockchain.
## ---------------------------------------------------------------------------------

install-deps-ubuntu:  				## Install basics to run node on ubuntu - developers should do it manually
	./scripts/install-deps-ubuntu.sh

install-deps-mac:					## Install basics to run node on mac - developers should do it manually
	./scripts/install-deps-brew.sh

tg_cmd = terragrunt $(1) --terragrunt-source-update --auto-approve --terragrunt-non-interactive --terragrunt-working-dir $(2)
##########
# Register
##########
aws-register:						## Register the node by creating a static website with the appropriate information and elastic IP.  Idempotent
	$(call tg_cmd,apply,icon/prep/aws/registration)

aws-destroy-ip:						## De-register the IP address and take down website.  Does not deregister the node
	$(call tg_cmd,destroy,icon/prep/aws/registration)

gcp-register:						## Register the node by creating a static website with the appropriate information and elastic IP.  Idempotent
	$(call tg_cmd,apply,icon/prep/gcp/registration)

gcp-destroy-ip:						## De-register the IP address and take down website.  Does not deregister the node
	$(call tg_cmd,destroy,icon/prep/gcp/registration)


#############
# Single node
#############
apply-prep-aws: 				 	## Apply P-Rep node in custom VPC
	$(call tg_cmd,apply-all,icon/prep/aws)

destroy-prep-aws:					## Destroy P-Rep node in custom VPC
	$(call tg_cmd,destroy-all,icon/prep/aws) ;

