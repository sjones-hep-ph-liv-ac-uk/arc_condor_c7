export ATLAS_RECOVERDIR=/data/atlas
EDG_WL_SCRATCH=$TMPDIR

ID=`id -u`

if [ $ID -gt 19999 ]; then
  ulimit -v 10000000
fi


