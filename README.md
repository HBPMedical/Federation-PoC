# Federation Proof-of-Concept

## Overview

In order to deploy the federation, we have to first create the master nodes, then add the worker nodes, add a couple of labels to the nodes to allow proper assignation of the different services, and finally we can start "services", which are described in docker-compose.yml files.

In the following we are going to use only one master node. More can be added for improved availability.

## Deployement

1. Create the master nodes

   ```sh
   $ ./createMaster.sh
   ```

   The command to execute on the worker node can be obtained at any time, as follows:

   ```sh
   $ docker swarm join-token worker
   To add a worker to this swarm, run the following command:

   docker swarm join --token SWMTKN-1-11jmbp9n3rbwyw23m2q51h4jo4o1nus4oqxf3rk7s7lwf7b537-9xakyj8dxmvb0p3ffhpv5y6g3 10.2.1.1:2377
   ```


2. On each worker node (a.k.a node of the federation)

   ```sh
   $ docker swarm join --token <Swarm Token> <Master Node URL>
   ```

   For example, assuming the result above of `docker swarm join-token worker`:

   ```sh
   $ docker swarm join --token SWMTKN-1-11jmbp9n3rbwyw23m2q51h4jo4o1nus4oqxf3rk7s7lwf7b537-9xakyj8dxmvb0p3ffhpv5y6g3 10.2.1.1:2377
   ```

3. Add more informative labels for each worker node, on the swarm master

   ```sh
   $ docker node update --label-add name=<Alias> <node hostname>
   ```

   * `<node hostname>` can be found with `docker node ls`
   * `<Alias>` will be used when bringing up the services and should be a short descriptive name.

4. Deploy the Federation service

   ```sh
   $ ./start.sh <Role> <Alias>
   ```

   * `<Role>` is either `manager` or `worker`.
   * `<Alias>` will be used when bringing up the services and should be a short descriptive name.
