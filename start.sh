#!/usr/bin/env bash
#                    Copyright (c) 2016-2017
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

# Node-specific config:
: ${federation_node:="UNKNOWN"} # Invalid default value, this needs to be setup.

# Whole Swarm config
: ${consul_url:="exareme-keystore:8500"}
: ${POSTGRES_USER:=mip}
: ${POSTGRES_PASSWORD:=s3cret}
: ${POSTGRES_PORT:=5432}
: ${POSTGRES_DB:=ldsm}
export consul_url POSTGRES_USER POSTGRES_PASSWORD POSTGRES_PORT POSTGRES_DB

usage() {
cat <<EOT
usage: $0 [-h|--help] nodename
	-h, --help: show this message and exit
	nodename: the node on which to deploy the stack

The following environment variables can be set to override defaults:
 - consul_url: URL to contact consul server for Exareme
 - exareme_workers_wait: Number of active workers in the federation
 - POSTGRES_USER
 - POSTGRES_PASSWORD
 - POSTGRES_PORT
 - POSTGRES_DB

Errors: This script will exit with the following error codes:
 1	No arguments provided
 2	Federation node is incorrect
EOT
}

if [ $# -lt 1 ]; then
	usage
	exit 1
fi

case $1 in
	-h|--help)
		usage
		exit 0
	;;

	*)
		federation_node="$1"
	;;
esac

if [ ${federation_node} == "UNKNOWN" ]; then
	echo "Invalid federation node name"
	usage
	exit 3
fi

exareme_workers_wait="1"
for h in $(docker node ls --format '{{ .Hostname }}')
do
	l=$(docker node inspect --format '{{ .Spec.Labels.name }}' ${h})
	if [ "x$l" == "x$federation_node" ];
	then
		rawhost=$(docker node inspect --format '{{ .Status.Addr }}' $h)
		role=$(docker node inspect --format '{{ .Spec.Role }}' $h)
		break;
	fi
done

export federation_node rawhost exareme_workers_wait
shift # drop the node name from the argument list

# Finally deploy the stack
docker stack up -c docker-compose-${role}.yml ${federation_node}
