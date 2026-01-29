.PHONY: fmt validate

fmt:
	terraform fmt -recursive

validate:
	@for d in examples/*; do \
		if [ -d "$$d" ]; then \
			echo "Validating $$d"; \
			(cd "$$d" && terraform init -backend=false && terraform validate); \
		fi; \
	done
