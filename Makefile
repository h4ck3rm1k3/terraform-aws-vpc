.PHONY: all plan apply destroy

all: plan apply

plan:
	~/experiments/ccore/bin/terraform plan -var-file terraform.tfvars -out terraform.tfplan

apply:
	~/experiments/ccore/bin/terraform apply -var-file terraform.tfvars

destroy:
	~/experiments/ccore/bin/terraform plan -destroy -var-file terraform.tfvars -out terraform.tfplan
	~/experiments/ccore/bin/terraform apply terraform.tfplan
