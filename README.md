# Federation Proof-of-Concept

## Overview

In order to deploy the federation, we have to first create the master nodes, then add the worker nodes, add a couple of labels to the nodes to allow proper assignation of the different services, and finally we can start "services", which are described in docker-compose.yml files.

In the following we are going to use only one master node. More can be added for improved availability.

## Deployement

### Requirements

The following are required on all nodes. This is installed by default as part of the MIP.

1. Install docker

   ```sh
   $ sudo apt-get update
   $ sudo apt-get install \
	    apt-transport-https \
	    ca-certificates \
	    curl \
	    software-properties-common
	$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
   ```

2. Check the finger print: `9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88`

   ```sh
	$ sudo apt-key fingerprint 0EBFCD88
	pub   4096R/0EBFCD88 2017-02-22
      Key fingerprint = 9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
	uid                  Docker Release (CE deb) <docker@docker.com>
	sub   4096R/F273FCD8 2017-02-22
   ```

3. Add the Docker official repository

  ```sh
  $ sudo add-apt-repository \
	   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	   $(lsb_release -cs) \
	   stable"
  ```

4. Update the index and install docker:

  ```sh
  $ sudo apt-get update
  $ sudo apt-get install docker-ce
  ```

### Deploy the Federation
1. Create the master nodes

   ```sh
   $ sudo ./createManager.sh
   ```

   The command to execute on the worker node can be obtained at any time, as follows:

   ```sh
   $ sudo docker swarm join-token worker
   To add a worker to this swarm, run the following command:

   docker swarm join --token SWMTKN-1-11jmbp9n3rbwyw23m2q51h4jo4o1nus4oqxf3rk7s7lwf7b537-9xakyj8dxmvb0p3ffhpv5y6g3 10.2.1.1:2377
   ```

2. On each worker node (a.k.a node of the federation)

   ```sh
   $ sudo docker swarm join --token <Swarm Token> <Master Node URL>
   ```

   For example, assuming the result above of `docker swarm join-token worker`:

   ```sh
   $ sudo docker swarm join --token SWMTKN-1-11jmbp9n3rbwyw23m2q51h4jo4o1nus4oqxf3rk7s7lwf7b537-9xakyj8dxmvb0p3ffhpv5y6g3 10.2.1.1:2377
   ```

3. Add more informative labels for each worker node, on the swarm master

   ```sh
   $ sudo docker node update --label-add name=<Alias> <node hostname>
   ```

   * `<node hostname>` can be found with `docker node ls`
   * `<Alias>` will be used when bringing up the services and should be a short descriptive name.

4. Deploy the Federation service

   ```sh
   $ sudo ./start.sh <Role> <Alias>
   ```

   * `<Role>` is either `manager` or `worker`.
   * `<Alias>` will be used when bringing up the services and should be a short descriptive name.
