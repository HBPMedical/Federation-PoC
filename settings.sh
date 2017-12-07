#Settings are taken in the following order of precedence:
#  1. Shell Environment, or on the command line

#  2. Node-specific settings `settings.local.<Alias>.sh`
if test ! -z "$1" && test -f ./settings.local.$1.sh;
then
	. ./settings.local.$1.sh;
fi

#  3. Federation-specific `settings.local.sh`
if test -f ./settings.local.sh;
then
	. ./settings.local.sh;
fi

#  4. Default settings `settings.default.sh`
if test -f ./settings.default.sh;
then
	. ./settings.default.sh;
fi

echo "Current settings:"
for v in $(grep '^:' settings.default.sh|cut -c 5- |cut -d: -f1)
do
	eval "echo $v=\$$v"
done
