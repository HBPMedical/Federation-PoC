#!/bin/sh
#                    Copyright (c) 2017-2016
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
: ${MASTERPORT:=2377}
: ${MASTERIP:=$(wget http://ipinfo.io/ip -qO -)}
: ${MASTERNAME:=$(hostname)}

usage() {
cat <<EOT
usage: $0 [-h|--help] <Swarm Token> <Master Node URL>
	-h, --help: show this message and exit
	<Swarm Token>: Token generated when initializing the first manager node
	<Master Node URL>: ip:port address of the manager node to contact
EOT
}

if [ $# -lt 2 ]; then
    usage
    exit 1
fi

case $1 in
	-h|--help)
		usage
		exit 0
	;;
	*)
		docker swarm join --token $1 $2
	;;
esac
