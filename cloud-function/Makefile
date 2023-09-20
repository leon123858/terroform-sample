all:

build:
	# rm cloudFunc.zip
	cd cloudFunc && zip -r -X "../cloudFunc.zip" .

start: 
	make build
	terraform init
	terraform plan
	terraform apply

format:
	terraform fmt -recursive 

init:
	terraform init

plan:
	terraform plan

destroy:
	terraform destroy