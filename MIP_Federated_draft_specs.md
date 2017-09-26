Version 1.0 - 25.09.2017

# MIP Federation specifications

!!! Work in progress !!!

This document is work in progress, it is meant to evolve in the near future. The second Federation PoC will clarify the Federation specifications.


## Access to the Federation

The Federation functionalities will be accessed through the CHUV's public Web Portal (to be confirmed).


## Federation architecture overview

This is on overview of the working principle of the Federation, based on the current knowledge and proof-of-concept results.

CHUV will host three important Federation elements (alongside its MIP Local instance):

- Federation Web Portal (usual Docker container)
- Federation Swarm manager
- Exareme master (Docker container launched on the Swarm)

The CHUV Federation server will run Docker engine (as other MIP servers). It will create the Federation Swarm (standard Docker functionality), which will make it the Swarm manager.

The other MIP nodes will mostly be the same as for MIP Local. The modifications will be:

- The Federation server will have an internet access.
- The Data Capture and Data Factory might be moved to another server for security reasons.
- The Federation server (or more accurately its instance of Docker engine) will join the Swarm created by the Swarm manager.
- The Swarm manager will remotely start an Exareme worker on the node.


## Regarding Docker Swarm

As written in the official documentation, "Docker includes a _swarm mode_ for natively managing a cluster of Docker Engines called a _swarm_". The Docker Swarm functionality creates a link among distant Docker engines. A Docker engine can only be part of one Swarm, so all Federation servers Docker Engines will be part of the Federation Swarm (and no other Swarm, assuming the normal and recommanded setup where only one Docker engine runs on each server).

The Swarm is created by a Swarm manager; other Federation nodes will join as Swarm workers. The Federation Swarm will create a `mip-federation` network using the `--opt encrypted` option, thus ensuring that all communication on this network are encrypted.

Then Docker containers can be launched in two ways: 

- In the Swarm: This requires the container to be started **from the Swarm manager**, as containers started directly on the worker nodes can not join the swarm for security reasons. Because of this the Exareme containers (Master and worker instances) have to be started from the Swarm manager at CHUV. They will be connected through the `mip-federation` network.
- Outside the Swarm: Docker container running outside the swarm can be started locally as usual on the worker nodes. All other Docker services composing MIP Local will be run locally, without access to the Swarm or the other MIP nodes.


# MIP Federated deployment


## Deployment for the Swarm manager node (CHUV)

Requirements:

- Static IP
- Network configuration:
	- TCP: ports 2377 and 7946 must be open and available
	- UDP: ports 4789 and 7946 must be open and available
	- IP protocol 50 (ESP) must be enabled

MIP Local will mostly function as previously: the docker containers will be run locally, and can be deployed with the MIP Local deployment scripts (given that everything runs on the same server or that the deployment scripts are adapted to deploy individual building blocks - see the "MIP Local deployment" document regarding current limitations).

On the Swarm manager server, the Swarm will be created using a deployment script. At creation time, two pieces of information must be retrieved: two tokens to add worker or manager nodes.

Note: The Swarm manager can be located on any server running docker; ideally it should be duplicated on three (or any odd-numbered number of) servers for redundancy. We assume here that the MIP Federation server of CHUV will be the Swarm manager (others can be added later using the "manager" token).

Once the Swarm is created, the Exareme master will be run on the Swarm. The Web Portal must be configured to access Exareme on the correct port.


## Deployment for other MIP nodes

Requirements:

- Static IP
- Network configuration:
	- TCP: port 7946 must be open and available
	- UDP: ports 4789 and 7946 must be open and available
	- IP protocol 50 (ESP) must be enabled

MIP Local will mostly function as previously: the docker containers will be run locally, and can be deployed with the MIP-Local deployment scripts (given that everything runs on the same server or that the deployment scripts are adapted to deploy individual building blocks - see the "MIP Local deployment" document regarding current limitations).

The only supplementary deployment step to perform on the Federation server is to join the Swarm, using the token retrieved by the Swarm manager at the creation of the Swarm.

Modifications required at the level of the MIP local deployment scripts:

- The LDSM must be available on one of the machine's ports.

## Deployment of Exareme and creation of the Federation

Once the worker nodes have joined the Swarm, the Swarm manager will tag each of them with a representative name (e.g. hospital name) and launch an Exareme worker on each of them. The Exareme worker will access the local LDSM to perform the queries requested by the Exarme master.





