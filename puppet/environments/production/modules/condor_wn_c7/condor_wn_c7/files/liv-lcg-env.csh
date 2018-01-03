setenv ATLAS_RECOVERDIR /data/atlas
if ( "$?TMPDIR" == "1" ) then
setenv EDG_WL_SCRATCH $TMPDIR
else
setenv EDG_WL_SCRATCH ""
endif


