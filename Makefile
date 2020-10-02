TOP_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
VENV_DIR := ${TOP_DIR}/venv/
TARGET_DIR := ${TOP_DIR}/target/
SRC_DIR := ${TOP_DIR}/src/
SHELL := /bin/bash
SCOPE := ${USERNAME}-
PIP_FLAGS := "--use-feature=2020-resolver"

init_venv:
	@cd ${TOP_DIR} && \
	if [ ! -d "${VENV_DIR}" ]; then \
		echo "Creating virtualenv..." && \
		virtualenv ${VENV_DIR} -p $(shell which python3.8); \
	fi

install_requirements:	init_venv
	@echo "Checking requirements..." && \
	cd ${TOP_DIR} && \
	source ${VENV_DIR}/bin/activate && \
	pip install ${PIP_FLAGS} -r requirements.txt

build:	install_requirements

package:	build
	@echo "Packaging..." && \
	cd ${TOP_DIR} && \
	rm -rf ${TARGET_DIR} && \
	mkdir -p ${TARGET_DIR}/lambda && \
	source ${VENV_DIR}/bin/activate && \
	pip install ${PIP_FLAGS} --upgrade -r requirements.txt --target=${TARGET_DIR}/lambda/ && \
	cd ${SRC_DIR} && \
	tar c --exclude='__pycache__' * | tar xv -C ${TARGET_DIR}/lambda/ && \
	cd ${TARGET_DIR}/lambda && \
	echo "Precompiling..." && \
	python3 -m compileall . && \
	echo "Zipping..." && \
	zip --recurse-paths ${TARGET_DIR}/lambda.zip *

deploy:	deploy_resources deploy_service

deploy_resources:	init_venv
	@echo "Deploying resources..." && \
	cd ${TOP_DIR}/infra/resources && \
	terraform init && \
	terraform apply -auto-approve -var="scope=${SCOPE}"

deploy_service:	 package
	@echo "Deploying service..." && \
	cd ${TOP_DIR}/infra/service && \
	terraform init && \
	terraform apply -auto-approve -var="scope=${SCOPE}"

destroy_all:	destroy_service destroy_resources

destroy_resources:
	@echo "DESTROYING resources..." && \
	cd ${TOP_DIR}/infra/resources && \
	terraform destroy -auto-approve -var="scope=${SCOPE}"

destroy_service:
	@echo "DESTROYING service..." && \
	cd ${TOP_DIR}/infra/service && \
	terraform destroy -auto-approve -var="scope=${SCOPE}"

clean:
	@echo "Cleaning up..." && \
	rm -rf ${TARGET_DIR} && \
	find . -name 'terraform.tfstate*' -print | grep devel | xargs -I FILE rm 'FILE'

invoke_single:
	aws lambda invoke --function-name "${SCOPE}-lambda" --log-type Tail --invocation-type RequestResponse --payload '{"op":"single"}' log

invoke_serial:
	aws lambda invoke --function-name "${SCOPE}-lambda" --log-type Tail --invocation-type RequestResponse --payload '{"op":"serial"}' log

invoke_parallel:
	aws lambda invoke --function-name "${SCOPE}-lambda" --log-type Tail --invocation-type RequestResponse --payload '{"op":"parallel"}' log
