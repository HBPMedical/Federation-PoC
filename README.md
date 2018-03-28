# Federation Proof-of-Concept

## Overview

In order to deploy the federation, we have to first create the master nodes, then add the worker nodes, add a couple of labels to the nodes to allow proper assignation of the different services, and finally we can start "services", which are described in docker-compose.yml files.

In the following we are going to use only one master node. More can be added for improved availability.

## Deployement

1. Create the master nodes
   ```
   ./createMaster.sh
   ```

2. On each worker node (a.k.a node of the federation)
   ```
   ./createWorker.sh <Swarm Token> <Master Node URL>
   ```

3. Add more informative labels for each worker node, on the swarm master
   ```
   docker node update --label-add name=<Alias> <node hostname>
   ```

   `<node hostname>` can be found with `docker node ls`
   `<Alias>` will be used when bringing up the services and should be a short descriptive name.
4. Bring up the services
   ```
   ./start.sh <Alias>
   ```
