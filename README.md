# demo-ethereumonazure

This demo helps you to setup a private Ethereum Network on Azure VM's. In order to run this demo you need the following installed on your PC or buildagent (if you are planning to use VSTS):
  - ansible
  - az cli (with connection to your subscription)
  - a linux (bash) shell
 
## What does it do:
  - it deploys a container instance that runs a preconfigured version of the netstat eth server (visualization), sourcecode for this is in the container folder
  - it creates Azure VM's, using POAT (plain on ARM templates :)  
  - with ansible it configures the VM's:
    - per VM install the required packages (for eg golang and npm)
    - per VM install geth and config
      - initialize private network with genesis block
      - start geth with proper params
      - create geth account
      - start mining 
      - in the end it will add the eth nodes by doing admin.addPeer for all enodes
    - per VM install the netstat eth clients
    - per VM install the solidity browser

## This demo contains:
  - solidity browser; on each VM the solidity IDE is installed so you can develop your own ETH contracts (https://github.com/ethereum/browser-solidity)
  - geth; the eth engine that starts your eth nodes in the go-lang language
  - eth-netstat; a client that visualizes your Ethereum mining  (client: https://github.com/cubedro/eth-net-intelligence-api, server: https://github.com/cubedro/eth-netstats
 )

## How

./create.sh NAME_OF_YOUR_RG NR_OF_NODES

Props to Matt Thomas and his excellent youtube channel: https://www.youtube.com/channel/UCbXiy1W_1HSMawmBDfo_TOA ...inspired me to automate this on Azure.
