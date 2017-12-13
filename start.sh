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

. ./settings.sh

federation_nodes=""
for h in $(docker node ls --format '{{ .Hostname }}')
do
	federation_nodes="$federation_nodes $(docker node inspect --format '{{ .Spec.Labels.name }}' ${h})"
done

usage() {
	cat <<EOT
usage: $0 [-h|--help] nodename
	-h, --help: show this message and exit
	nodename: the node on which to deploy the stack

You can use environment variables, or add them into settings.local.sh
to change the default values.

To see the full list, please refer to settings.default.sh

Please find below the list of known Federation nodes:
$federation_nodes

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
		FEDERATION_NODE="$1"
	;;
esac

if [ -z "${FEDERATION_NODE}" ]; then
	echo "Invalid federation node name"
	usage
	exit 3
fi

for h in $(docker node ls --format '{{ .Hostname }}')
do
	label=$(docker node inspect --format '{{ .Spec.Labels.name }}' ${h})
	if [ "x${label}" == "x${FEDERATION_NODE}" ];
	then
		test -z "${LDSM_HOST}" && \
			LDSM_HOST=$(docker node inspect --format '{{ .Status.Addr }}' ${h})
		
		test -z "${EXAREME_ROLE}" && \
			EXAREME_ROLE=$(docker node inspect --format '{{ .Spec.Role }}' ${h})
		break;
	fi
done

shift # drop the node name from the argument list

# Export the settings to the docker-compose files
export FEDERATION_NODE

export LDSM_USERNAME LDSM_PASSWORD LDSM_HOST LDSM_PORT

export EXAREME_ROLE EXAREME_KEYSTORE EXAREME_MODE EXAREME_WORKERS_WAIT
export EXAREME_LDSM_ENDPOINT EXAREME_LDSM_RESULTS EXAREME_LDSM_DATAKEY

# Finally deploy the stack
docker stack up -c docker-compose-${EXAREME_ROLE}.yml ${FEDERATION_NODE}
