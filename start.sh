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
: ${pg_data_root:="/var/Federation-PoC-1-data/data"}
: ${raw_data_root:="/var/Federation-PoC-1-data/datasets"}
: ${federation_node:="UNKNOWN"} # Invalid default value, this needs to be setup.
export pg_data_root raw_data_root federation_node

# Whole Swarm config
: ${consul_url:="$(cat consul_url.conf)"}
: ${POSTGRES_USER:=mip}
: ${POSTGRES_PASSWORD:=s3cret}
: ${POSTGRES_PORT:=5432}
: ${POSTGRES_DB:=ldsm}
export consul_url POSTGRES_USER POSTGRES_PASSWORD POSTGRES_PORT POSTGRES_DB

usage() {
cat <<EOT
usage: $0 [-h|--help] (uoa|epfl|chuv)
	-h, --help: show this message and exit
	(uoa|epfl|chuv): the node on which to deploy the stack

The following environment variables can be set to override defaults:
 - pg_data_root		Folder containing the PostgreSQL data
 - raw_data_root	Folder containing the raw data
 - raw_admin_root	Folder containing the administration configuration

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
	uoa)
		federation_node="uoa"
		exareme_master="master"
		exareme_workers_wait="2"
		role=master
	;;

	epfl|chuv)
		federation_node=$1
		role=worker
	;;

	-h|--help|*)
		usage
		exit 0
	;;

	*)
		usage
		exit 2
	;;
esac

if [ ${federation_node} == "UNKNOWN" ]; then
	echo "Invalid federation node name"
	usage
	exit 3
fi

export federation_node exareme_master exareme_workers_wait
shift # drop the node name from the argument list

# Finally deploy the stack
docker stack up -c docker-compose-${role}.yml ${federation_node}
