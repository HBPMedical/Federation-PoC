#!/bin/sh
#                    Copyright (c) 2017-2017
#   Data Intensive Applications and Systems Labaratory (DIAS)
#            Ecole Polytechnique Federale de Lausanne
#
#                      All Rights Reserved.
#
# Permission to use, copy, modify and distribute this software and its
# documentation is hereby granted, provided that both the copyright notice
# and this permission notice appear in all copies of the software, derivative
# works or modified versions, and any portions thereof, and that both notices
# appear in supporting documentation.
#
# This code is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. THE AUTHORS AND ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE
# DISCLAIM ANY LIABILITY OF ANY KIND FOR ANY DAMAGES WHATSOEVER RESULTING FROM THE
# USE OF THIS SOFTWARE.

set -e

: ${CONSULPORT:=8500}
: ${PORTAINERPORT:=9000}
: ${MASTERPORT:=2377}
: ${MASTERIP:=$(wget http://ipinfo.io/ip -qO -)}
: ${MASTERNAME:=$(hostname)}

# Master node/Manager
(
	echo "${MASTERIP}" > swarm_manager.conf

	# Initialize swarm
	docker swarm init --advertise-addr=${MASTERIP}

	# get join token
	SWARM_TOKEN=$(docker swarm join-token -q worker)
	echo "${SWARM_TOKEN}" > swarm_token.conf
)

# Keystore
if true
then
(
	docker run --restart=unless-stopped -d --name swarm-keystore -p ${CONSULPORT}:8500 progrium/consul -server -bootstrap
	echo "${MASTERIP}:${CONSULPORT}" > consul_url.conf

	# Check Keystore is responding
	sleep 1
	curl $(cat consul_url.conf)/v1/catalog/nodes
)
fi

# Portainer, a webUI for Docker Swarm
if true
then
	docker service create \
		--name portainer \
		--publish ${PORTAINERPORT}:9000 \
		--constraint 'node.role == manager' \
		--mount type=bind,src=//var/run/docker.sock,dst=/var/run/docker.sock \
		portainer/portainer \
		-H unix:///var/run/docker.sock
fi

docker network create \
	--driver=overlay \
	--opt encrypted \
	--attachable \
	--subnet=10.20.30.0/24 \
	--ip-range=10.20.30.0/24 \
	--gateway=10.20.30.254 \
	mip_net-federation
