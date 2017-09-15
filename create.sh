#!/bin/bash

##################################
# 
#  Create the resources in Azure (VM's etcetc
#
##################################

if [ ! $# -eq 2 ]
then
  echo "please provide these params: resourcegroup  nrOfMachines"
  exit 1 
fi

resourcegroup=$1
nrofmachines=$2
username=vsts
region="westeurope"
pm2password="helloworld123"

vnetname="vnet-"$resourcegroup
snetname="subnet-"$resourcegroup
gethclientdir=/opt/ethereum/demo-eko-client


# change username for ansible
sed -in 's/X_USER_X/'$username'/' config-eth.yaml 

dnsname=$(echo $resourcegroup | sed 's/-//' )
rm -f hosts.txt

# Create resourcegroup
echo "creating resource group:"
az group create \
  --name $resourcegroup \
  --location $region

# Creating container instance with Eth Netstats server
az container create --name demo-eko-ethnetstats --image cvugrinec/demo-eko-ethnetstats --resource-group $resourcegroup --ip-address public  --port 3000

# Create network
echo "creating network:"
az group deployment create \
  --name "vnet-"$resourcegroup \
  --resource-group $resourcegroup \
  --template-file vnet.json


tmpkey=`echo $(cat ~/.ssh/id_rsa.pub)`
sshKey=$(echo "$tmpkey" | sed 's/\//\\\//g')
echo "Creating machines with key: "$sshKey


if [ ! -d output ] 
then
  echo "creating output directory"
  mkdir output
fi

# Generate Json parameters
for (( i=1; i <= $nrofmachines; i++ ))
do
   echo "creating arm template for machine: ./output/eth-machine-parameters"$i
   cat eth-machine-parameters.json | sed 's/X_USERNAME_X/'$username'/' > ./output/eth-machine-parameters$i.json
   sed -in 's/X_DNSNAME_X/'$dnsname'-'$i'/' ./output/eth-machine-parameters$i.json
   sed -in 's/X_VNET_X/vnet-'$resourcegroup'/' ./output/eth-machine-parameters$i.json
   sed -in 's/X_SUBNET_X/subnet-'$resourcegroup'-1/' ./output/eth-machine-parameters$i.json
   sed -in 's/X_RESOURCEGROUP_X/'$resourcegroup'/' ./output/eth-machine-parameters$i.json
   sed -in "s/X_SSH_X/\"$sshKey\"/g" ./output/eth-machine-parameters$i.json
   # Hosts file, needed later for the eth hack
   echo "$dnsname-$i.$region.cloudapp.azure.com">>hosts.txt
done

# ETH netstat stuff (visualization of eth mining)
# findout Address of eth netstat master
pm2server=$(az container list -o table | grep  demo-eko-ethnetstats  | awk '{print $5}' | tail -1)


# Create the VM's
for (( i=1; i <= $nrofmachines; i++ ))
do
   echo "creating azure machine:: ./output/eth-machine-parameters"$i
   az group deployment create \
     --name $resourcegroup \
     --resource-group $resourcegroup \
     --template-file eth-machine.json \
     --parameters @./output/eth-machine-parameters$i.json 
done

echo "PM2 server is: $pm2server"
# Generating eth netstat client config files
for (( i=1; i <= $nrofmachines; i++ ))
do
   cat pm2-template.json | sed 's/XXX_PM2NAME_XXX/'ethnode-$i'/' > ./output/pm2-template$i.json
   sed -in 's/XXX_PM2SERVER_XXX/'$pm2server'/' ./output/pm2-template$i.json
   sed -in 's/XXX_PM2SECRET_XXX/'$pm2password'/' ./output/pm2-template$i.json
   # Doing this, so the known_hosts file stuff does not occur anymore
   ssh -o StrictHostKeyChecking=no $username@$dnsname-$i.$region.cloudapp.azure.com 'hostname --ip-address'
   # copying the config file to each host
   scp ./output/pm2-template$i.json $username@$dnsname-$i.$region.cloudapp.azure.com:/tmp
done


##################################
#
# Ansible config
#
##################################

if [ ! -d /etc/ansible ]
then
  mkdir /etc/ansible
fi

echo "[eth-cluster]">/etc/ansible/hosts

echo "config ansible:"
for (( i=1; i <= $nrofmachines; i++ ))
do
  echo "adding host: "$dnsname-$i".$region.cloudapp.azure.com to ansible hostfile"
  echo "$dnsname-$i.$region.cloudapp.azure.com">>/etc/ansible/hosts
done

# Ansible Config
ansible-playbook config-eth.yaml


##################################
# Adding Peers hack

gethDir=/opt/ethereum/demo-eko

rm -f enodes.txt
# Getting the enode data locally on this machine
for host in $(cat hosts.txt )
do
  ssh $host 'cat /tmp/enodes' >>enodes.txt
done

firstHost=$(cat hosts.txt | head -1)

echo "host: $firstHost"

# Adding peers to network (reciprocative)
for enode in $(cat enodes.txt  | grep -v ANSIBLE | sed 's/"//g')
do
   echo "Adding enode $enode as peer to this private eth network"
   ssh $firstHost 'echo "admin.addPeer('\"$enode\"')" | geth attach ipc:/'$gethDir'/geth.ipc'
done


# done
echo "check your config and then go to : $pm2server with ur browser"

##################################
#
# Adding peers to eth network, == hack: couldn't fix it with ansible
#
##################################
