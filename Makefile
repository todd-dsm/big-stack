SHELL += -xeu

# SETUP
BLUE    := \033[0;34m
GREEN   := \033[0;32m
RED     := \033[0;31m
NC      := \033[0m

#------------------------------------------------------------------------------
# AWS Details
#------------------------------------------------------------------------------
#export SUPPORT_EMAIL        ?= your.email@here.com
#export DOMAINAME            ?= *.example.com
#export PROVIDER             ?= aws
#export REGION               ?= us-west-2
#export CLUSTER_NAME         ?= cluster-name
#export COREOS_CHANNEL       ?= stable
#export COREOS_VM_TYPE       ?= hvm
#
#export HYPERKUBE_IMAGE      ?= quay.io/coreos/hyperkube
#export HYPERKUBE_TAG        ?= v1.7.2_coreos.0
#
#export CIDR_VPC             ?= 10.0.0.0/16
#export CIDR_PODS            ?= 10.2.0.0/16
#export CIDR_SERVICE_CLUSTER ?= 10.3.0.0/24
#
#export K8S_SERVICE_IP       ?= 10.3.0.1
#export K8S_DNS_IP           ?= 10.3.0.10
#
#export ETCD_IPS             ?= 10.0.10.10,10.0.11.11,10.0.12.12
#
#export PKI_IP               ?= 10.0.10.9

#------------------------------------------------------------------------------
# Terraform
#------------------------------------------------------------------------------
tf-init:
	echo "Initializing Terraform"
	if [ ! -d '.terraform' ]; then \
		terraform init -get=true; \
	else \
		echo '  initialized!'; \
	fi

tf-update: tf-init
	echo "Updating Terraform modules..."
	terraform get -update

tf-plan: tf-init
	terraform plan -out /tmp/tf-plan.out

tf-apply:
	terraform apply '/tmp/tf-plan.out'



#${PROVIDER}: tf-init tf-update
	#terraform plan -out=/tmp/tf.plan
	#terraform -var domaiName=${DOMAINAME}
