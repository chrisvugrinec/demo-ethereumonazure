#!/bin/bash
#docker build -t cvugrinec/demo-eko-ethnetstats .
az container create --name demo-eko-ethnetstats --image cvugrinec/demo-eko-ethnetstats --resource-group myResourceGroup --ip-address public  --port 3000
