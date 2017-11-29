Version 1.0 - 25.09.2017

# MIP Federation specifications

!!! Work in progress !!!

This document is work in progress, it is meant to evolve in the near future. The second Federation PoC will clarify the Federation specifications.


## Access to the Federation

The Federation functionalities will be accessed through the MIP main public Web Portal (currently hosted at CHUV).


## Federation architecture overview

This is on overview of the working principle of the Federation, based on the current knowledge and proof-of-concept results.

CHUV will host three important Federation elements (alongside its MIP Local instance):

- Federation Web Portal (usual Docker container)
- Federation Swarm manager
- Exareme master (Docker container launched on the Swarm)

The CHUV Federation server will run Docker engine (as other MIP servers). It will create the Federation Swarm (standard Docker functionality), which will make it the Swarm manager.

The other MIP nodes will mostly be the same as for MIP Local, but possibly hosted on several servers for improved security. The modifications will be:

- The server dedicated to the Federation will have an internet access.
- The Data Capture and Data Factory might be moved to other servers for security reasons.
- The Federation server (or more accurately its Docker engine instance) will join the Swarm created by the Swarm manager.
- The Swarm manager will remotely start an Exareme worker on the node.


## Regarding Docker Swarm

As written in the official documentation, "Docker includes a _swarm mode_ for natively managing a cluster of Docker Engines called a _swarm_". The Docker Swarm functionality creates a link among distant Docker engines. A Docker engine can only be part of one Swarm, so all Federation servers Docker Engines will be part of the Federation Swarm (and no other Swarm, assuming the normal and recommanded setup where only one Docker engine runs on each server).

The Swarm is created by a Swarm manager; other Federation nodes will join as Swarm workers. The Federation Swarm will create a `mip-federation` network using the encrypted option `--opt encrypted`, thus ensuring that all communication on this network are encrypted.

Then Docker containers can be launched in two ways: 

- In the Swarm: This requires the container to be started **from the Swarm manager**, as containers started directly on the worker nodes can not join the swarm for security reasons. Because of this the Exareme containers (Master and worker instances) have to be started from the Swarm manager at CHUV. They will be connected through the `mip-federation` network.
- Outside the Swarm: Docker container running outside the swarm can be started locally as usual on the worker nodes. All other Docker services composing MIP Local will be run locally, without access to the Swarm or the other MIP nodes.


# MIP Federated deployment


## Deployment for the Federation manager node

Based on the last version of the Federation infrastructure schema provided by Jacek Manthey, the Federation manager node will be a server independant from any particular hospital (alternatively, any hospital node could be the Federation manager).

Requirements:

- Static IP
- Network configuration:
	- TCP: ports 2377 and 7946 must be open and available
	- UDP: ports 4789 and 7946 must be open and available
	- IP protocol 50 (ESP) must be enabled
- If the configuration uses a whitelist of allowed IP addresses, the IP of all other Federation nodes must be authorised.

If the Federation manager server is not a hospital node, it only needs to run an instance of the LDSM containing the research dataset that must be exposed at the Federation level.

If the server also serves as a hospital node, the MIP Local will mostly function as previously: the docker containers will be run locally, and can be deployed with the MIP Local deployment scripts (assuming that everything runs on the same server or that the deployment scripts are adapted to deploy individual building blocks).

On the Swarm manager server, the Federation Swarm will be created. At creation time, two tokens must be retrieved: they allow to add worker or manager nodes to the swarm.

Note: The Swarm manager can be located on any server running docker; ideally it should be duplicated on three (or any odd-numbered number of) servers for redundancy. We assume here that the MIP Federation server of CHUV will be the Swarm manager (others can be added later using the "manager" token).

Once the Swarm is created, the Exareme master will be run on the Swarm. The Web Portal must be configured to access Exareme on the correct port.


## Deployment for other MIP nodes

Requirements:

- Static IP
- Network configuration:
	- TCP: port 7946 must be open and available
	- UDP: ports 4789 and 7946 must be open and available
	- IP protocol 50 (ESP) must be enabled

MIP Local will mostly function as previously: the docker containers will be run locally, and can be deployed with the MIP-Local deployment scripts (assuming that everything runs on the same server or that the deployment scripts are adapted to deploy individual building blocks).

The only supplementary deployment step to perform on the Federation server is to join the Swarm, using the token retrieved by the Swarm manager at the creation of the Swarm.

Modifications required at the level of the MIP local deployment scripts:

- To be defined, if any.

## Deployment of Exareme and creation of the Federation

Once the worker nodes have joined the Swarm, the Swarm manager will tag each of them with a representative name (e.g. hospital name) and launch an Exareme worker on each of them. The Exareme worker will access the local LDSM to perform the queries requested by the Exareme master.





