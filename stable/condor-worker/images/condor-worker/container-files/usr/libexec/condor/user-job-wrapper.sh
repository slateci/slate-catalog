#!/bin/bash


function getPropBool
{
    # $1 the file (for example, $_CONDOR_JOB_AD or $_CONDOR_MACHINE_AD)
    # $2 the key
    # $3 is the default value if unset
    # echo "1" for true, "0" for false/unspecified
    # return 0 for true, 1 for false/unspecified
    default=$3
    if [ "x$default" = "x" ]; then
        default=0
    fi
    val=`(grep -i "^$2 " $1 | cut -d= -f2 | sed "s/[\"' \t\n\r]//g") 2>/dev/null`
    # convert variations of true to 1
    if (echo "x$val" | grep -i true) >/dev/null 2>&1; then
        val="1"
    fi
    if [ "x$val" = "x" ]; then
        val="$default"
    fi
    echo $val
    # return value accordingly, but backwards (true=>0, false=>1)
    if [ "$val" = "1" ];  then
        return 0
    else
        return 1
    fi
}


function getPropStr
{
    # $1 the file (for example, $_CONDOR_JOB_AD or $_CONDOR_MACHINE_AD)
    # $2 the key
    # $3 default value if unset
    default="$3"
    val=`(grep -i "^$2 " $1 | cut -d= -f2 | sed "s/[\"' \t\n\r]//g") 2>/dev/null`
    if [ "x$val" = "x" ]; then
        val="$default"
    fi
    echo $val
}


function create_host_lib_dir()
{
    # this is a temporary solution until enough sites have newer versions
    # of Singularity. Idea for this solution comes from:
    # https://github.com/singularityware/singularity/blob/master/libexec/cli/action_argparser.sh#L123
    mkdir -p .host-libs
    NVLIBLIST=`mktemp ${TMPDIR:-/tmp}/.nvliblist.XXXXXXXX`
    cat >$NVLIBLIST <<EOF
libcuda.so
libEGL_installertest.so
libEGL_nvidia.so
libEGL.so
libGLdispatch.so
libGLESv1_CM_nvidia.so
libGLESv1_CM.so
libGLESv2_nvidia.so
libGLESv2.so
libGL.so
libGLX_installertest.so
libGLX_nvidia.so
libglx.so
libGLX.so
libnvcuvid.so
libnvidia-cfg.so
libnvidia-compiler.so
libnvidia-eglcore.so
libnvidia-egl-wayland.so
libnvidia-encode.so
libnvidia-fatbinaryloader.so
libnvidia-fbc.so
libnvidia-glcore.so
libnvidia-glsi.so
libnvidia-gtk2.so
libnvidia-gtk3.so
libnvidia-ifr.so
libnvidia-ml.so
libnvidia-opencl.so
libnvidia-ptxjitcompiler.so
libnvidia-tls.so
libnvidia-wfb.so
libOpenCL.so
libOpenGL.so
libvdpau_nvidia.so
nvidia_drv.so
tls_test_.so
EOF
    for TARGET in $(ldconfig -p | grep -f "$NVLIBLIST"); do
        if [ -f "$TARGET" ]; then
            BASENAME=`basename $TARGET`
            # only keep the first one found
            if [ ! -e ".host-libs/$BASENAME" ]; then
                cp -L $TARGET .host-libs/
            fi
        fi
    done
    rm -f $NVLIBLIST
}


if [ "x$OSG_SINGULARITY_REEXEC" = "x" ]; then
    
    if [ "x$_CONDOR_JOB_AD" = "x" ]; then
        export _CONDOR_JOB_AD="NONE"
    fi
    if [ "x$_CONDOR_MACHINE_AD" = "x" ]; then
        export _CONDOR_MACHINE_AD="NONE"
    fi

    # make sure the job can access certain information via the environment, for example ProjectName
    export OSGVO_PROJECT_NAME=$(getPropStr $_CONDOR_JOB_AD ProjectName)
    export OSGVO_SUBMITTER=$(getPropStr $_CONDOR_JOB_AD User)
    
    # "save" some setting from the condor ads - we need these even if we get re-execed
    # inside singularity in which the paths in those env vars are wrong
    # Seems like arrays do not survive the singularity transformation, so set them
    # explicity

    export HAS_SINGULARITY=$(getPropBool $_CONDOR_MACHINE_AD HAS_SINGULARITY 0)
    export OSG_SINGULARITY_PATH=$(getPropStr $_CONDOR_MACHINE_AD OSG_SINGULARITY_PATH)
    export OSG_SINGULARITY_IMAGE_DEFAULT=$(getPropStr $_CONDOR_MACHINE_AD OSG_SINGULARITY_IMAGE_DEFAULT)
    export OSG_SINGULARITY_IMAGE=$(getPropStr $_CONDOR_JOB_AD SingularityImage)
    export OSG_SINGULARITY_AUTOLOAD=$(getPropBool $_CONDOR_JOB_AD SingularityAutoLoad 1)
    export OSG_SINGULARITY_BIND_CVMFS=$(getPropBool $_CONDOR_JOB_AD SingularityBindCVMFS 1)
    export OSG_SINGULARITY_BIND_GPU_LIBS=$(getPropBool $_CONDOR_JOB_AD SingularityBindGPULibs 1)

    export STASHCACHE=$(getPropBool $_CONDOR_JOB_AD WantsStashCache 0)
    export STASHCACHE_WRITABLE=$(getPropBool $_CONDOR_JOB_AD WantsStashCacheWritable 0)

    export POSIXSTASHCACHE=$(getPropBool $_CONDOR_JOB_AD WantsPosixStashCache 0)

    export InitializeModulesEnv=$(getPropBool $_CONDOR_JOB_AD InitializeModulesEnv 1)
    export LoadModules=$(getPropStr $_CONDOR_JOB_AD LoadModules)

    export LMOD_BETA=$(getPropBool $_CONDOR_JOB_AD LMOD_BETA 0)
    
    export OSG_MACHINE_GPUS=$(getPropStr $_CONDOR_MACHINE_AD GPUs "0")

    if [ "x$OSG_SINGULARITY_AUTOLOAD" != "x1" ]; then
        echo "Warning: Using +SingularityAutoLoad is no longer allowed. Ignoring." 1>&2
        export OSG_SINGULARITY_AUTOLOAD=0
    fi

    #############################################################################
    #
    #  Singularity
    #
    if [ "x$HAS_SINGULARITY" = "x1" -a "x$OSG_SINGULARITY_PATH" != "x" ]; then

        # If  image is not provided, load the default one
        # Custom URIs: http://singularity.lbl.gov/user-guide#supported-uris
        if [ "x$OSG_SINGULARITY_IMAGE" = "x" ]; then
            # Default
            export OSG_SINGULARITY_IMAGE="$OSG_SINGULARITY_IMAGE_DEFAULT"
            export OSG_SINGULARITY_BIND_CVMFS=1

            # also some extra debugging and make sure CVMFS has not fallen over
            if ! ls -l "$OSG_SINGULARITY_IMAGE/" >/dev/null; then
                echo "warning: unable to access $OSG_SINGULARITY_IMAGE" 1>&2
                echo "         $OSG_SITE_NAME" `hostname -f` 1>&2
                touch ../../.stop-glidein.stamp >/dev/null 2>&1
                sleep 10m
            fi
        fi

        # put a human readable version of the image in the env before
        # expanding it - useful for monitoring
        export OSG_SINGULARITY_IMAGE_HUMAN="$OSG_SINGULARITY_IMAGE"

        # for /cvmfs based directory images, expand the path without symlinks so that
        # the job can stay within the same image for the full duration
        if echo "$OSG_SINGULARITY_IMAGE" | grep /cvmfs >/dev/null 2>&1; then
            if (cd $OSG_SINGULARITY_IMAGE) >/dev/null 2>&1; then
                NEW_IMAGE_PATH=`(cd $OSG_SINGULARITY_IMAGE && pwd -P) 2>/dev/null`
                if [ "x$NEW_IMAGE_PATH" != "x" ]; then
                    OSG_SINGULARITY_IMAGE="$NEW_IMAGE_PATH"
                fi
            fi
        fi
    
        # set up the env to make sure Singularity uses the glidein dir for exported /tmp, /var/tmp
        if [ "x$GLIDEIN_Tmp_Dir" != "x" -a -e "$GLIDEIN_Tmp_Dir" ]; then
            if mkdir $GLIDEIN_Tmp_Dir/singularity-work.$$ ; then
                export SINGULARITY_WORKDIR=$GLIDEIN_Tmp_Dir/singularity-work.$$
            fi
        fi
        
        OSG_SINGULARITY_EXTRA_OPTS=""
   
        # cvmfs access inside container (default, but optional)
        if [ "x$OSG_SINGULARITY_BIND_CVMFS" = "x1" ]; then
            OSG_SINGULARITY_EXTRA_OPTS="$OSG_SINGULARITY_EXTRA_OPTS --bind /cvmfs"
        fi

        # Binding different mounts
        for MNTPOINT in \
            /hadoop \
            /hdfs \
            /lizard \
            /mnt/hadoop \
            /mnt/hdfs \
        ; do
            if [ -e $MNTPOINT/. -a -e $OSG_SINGULARITY_IMAGE/$MNTPOINT ]; then
                OSG_SINGULARITY_EXTRA_OPTS="$OSG_SINGULARITY_EXTRA_OPTS --bind $MNTPOINT"
            fi
        done

        # GPUs - bind outside GPU library directory to inside /host-libs
        if [ $OSG_MACHINE_GPUS -gt 0 ]; then
            if [ "x$OSG_SINGULARITY_BIND_GPU_LIBS" = "x1" ]; then
                HOST_LIBS=""
                if [ -e "/usr/lib64/nvidia" ]; then
                    HOST_LIBS=/usr/lib64/nvidia
                elif create_host_lib_dir; then
                    HOST_LIBS=$PWD/.host-libs
                fi
                if [ "x$HOST_LIBS" != "x" ]; then
                    OSG_SINGULARITY_EXTRA_OPTS="$OSG_SINGULARITY_EXTRA_OPTS --bind $HOST_LIBS:/host-libs"
                fi
                if [ -e /etc/OpenCL/vendors ]; then
                    OSG_SINGULARITY_EXTRA_OPTS="$OSG_SINGULARITY_EXTRA_OPTS --bind /etc/OpenCL/vendors:/etc/OpenCL/vendors"
                fi
            fi
        else
            # if not using gpus, we can limit the image more
            OSG_SINGULARITY_EXTRA_OPTS="$OSG_SINGULARITY_EXTRA_OPTS --contain"
        fi

        # We want to bind $PWD to /srv within the container - however, in order
        # to do that, we have to make sure everything we need is in $PWD, most
        # notably the user-job-wrapper.sh (this script!)
        cp $0 .osgvo-user-job-wrapper.sh

        # Remember what the outside pwd dir is so that we can rewrite env vars
        # pointing to omewhere inside that dir (for example, X509_USER_PROXY)
        if [ "x$_CONDOR_JOB_IWD" != "x" ]; then
            export OSG_SINGULARITY_OUTSIDE_PWD="$_CONDOR_JOB_IWD"
        else
            export OSG_SINGULARITY_OUTSIDE_PWD="$PWD"
        fi

        # build a new command line, with updated paths
        CMD=()
        for VAR in "$@"; do
            # Two seds to make sure we catch variations of the iwd,
            # including symlinked ones. The leading space is to prevent
            # echo to interpret dashes.
            VAR=`echo " $VAR" | sed -E "s;$PWD(.*);/srv\1;" | sed -E "s;.*/execute/dir_[0-9a-zA-Z]*(.*);/srv\1;" | sed -E "s;^ ;;"`
            CMD+=("$VAR")
        done

        export OSG_SINGULARITY_REEXEC=1
        exec $OSG_SINGULARITY_PATH exec $OSG_SINGULARITY_EXTRA_OPTS \
                                   --home $PWD:/srv \
                                   --pwd /srv \
                                   --ipc --pid \
                                   "$OSG_SINGULARITY_IMAGE" \
                                   /srv/.osgvo-user-job-wrapper.sh \
                                   "${CMD[@]}"
    fi

else
    # we are now inside singularity - fix up the env
    unset TMP
    unset TMPDIR
    unset TEMP
    unset X509_CERT_DIR
    for key in X509_USER_PROXY X509_USER_CERT \
               _CONDOR_CREDS _CONDOR_MACHINE_AD _CONDOR_JOB_AD \
               _CONDOR_SCRATCH_DIR _CONDOR_CHIRP_CONFIG _CONDOR_JOB_IWD \
               OSG_WN_TMP ; do
        eval val="\$$key"
        val=`echo "$val" | sed -E "s;$OSG_SINGULARITY_OUTSIDE_PWD(.*);/srv\1;"`
        eval $key=$val
    done

    # If X509_USER_PROXY and friends are not set by the job, we might see the
    # glidein one - in that case, just unset the env var
    for key in X509_USER_PROXY X509_USER_CERT X509_USER_KEY ; do
        eval val="\$$key"
        if [ "x$val" != "x" ]; then
            if [ ! -e "$val" ]; then
                eval unset $key >/dev/null 2>&1 || true
            fi
        fi
    done

    # override some OSG specific variables
    if [ "x$OSG_WN_TMP" != "x" ]; then
        export OSG_WN_TMP=/tmp
    fi

    # Some java programs have seen problems with the timezone in our containers.
    # If not already set, provide a default TZ
    if [ "x$TZ" = "x" ]; then
        export TZ="UTC"
    fi
fi 



#############################################################################
#
#  modules and env 
#

# prepend HTCondor libexec dir so that we can call chirp
if [ -e ../../main/condor/libexec ]; then
    DER=`(cd ../../main/condor/libexec; pwd)`
    export PATH=$DER:$PATH
fi

# load modules, if available
if [ "x$InitializeModulesEnv" = "x1" ]; then
    if [ "x$LMOD_BETA" = "x1" ]; then
        # used for testing the new el6/el7 modules 
        if [ -e /cvmfs/oasis.opensciencegrid.org/osg/sw/module-beta-init.sh ]; then
            . /cvmfs/oasis.opensciencegrid.org/osg/sw/module-beta-init.sh
        fi
    elif [ -e /cvmfs/oasis.opensciencegrid.org/osg/sw/module-init.sh ]; then
        . /cvmfs/oasis.opensciencegrid.org/osg/sw/module-init.sh
    fi
fi


# fix discrepancy for Squid proxy URLs
if [ "x$GLIDEIN_Proxy_URL" = "x" -o "$GLIDEIN_Proxy_URL" = "None" ]; then
    if [ "x$OSG_SQUID_LOCATION" != "x" -a "$OSG_SQUID_LOCATION" != "None" ]; then
        export GLIDEIN_Proxy_URL="$OSG_SQUID_LOCATION"
    fi
fi


#############################################################################
#
#  Stash cache 
#

function setup_stashcp {
  # keep the user job output clean
  module load stashcache >/dev/null 2>&1 || module load stashcp >/dev/null 2>&1

  # we need xrootd, which is available both in the OSG software stack
  # as well as modules - use the system one by default
  if ! which xrdcp >/dev/null 2>&1; then
      module load xrootd >/dev/null 2>&1
  fi
 
  # Determine XRootD plugin directory.
  # in lieu of a MODULE_<name>_BASE from lmod, this will do:
  export MODULE_XROOTD_BASE=$(which xrdcp | sed -e 's,/bin/.*,,')
  export XRD_PLUGINCONFDIR=$MODULE_XROOTD_BASE/etc/xrootd/client.plugins.d
 
}
 
# Check for PosixStashCache first
if [ "x$POSIXSTASHCACHE" = "x1" ]; then
  setup_stashcp
 
  # Add the LD_PRELOAD hook
  export LD_PRELOAD=$MODULE_XROOTD_BASE/lib64/libXrdPosixPreload.so:$LD_PRELOAD
 
  # Set proxy for virtual mount point
  # Format: cache.domain.edu/local_mount_point=/storage_path
  # E.g.: export XROOTD_VMP=data.ci-connect.net:/stash=/
  # Currently this points _ONLY_ to the OSG Connect source server
  export XROOTD_VMP=$(stashcp --closest | cut -d'/' -f3):/stash=/
 
elif [ "x$STASHCACHE" = "x1" -o "x$STASHCACHE_WRITABLE" = "x1" ]; then
  setup_stashcp
fi


#############################################################################
#
#  Load user specified modules
#

if [ "X$LoadModules" != "X" ]; then
    ModuleList=`echo $LoadModules | sed 's/^LoadModules = //i' | sed 's/"//g'`
    for Module in $ModuleList; do
        module load $Module
    done
fi


#############################################################################
#
#  Trace callback
#

if [ ! -e .trace-callback ]; then
    (wget -nv -O .trace-callback http://osg-vo.isi.edu/osg/agent/trace-callback && chmod 755 .trace-callback) >/dev/null 2>&1 || /bin/true
fi
./.trace-callback start >/dev/null 2>&1 || /bin/true


#############################################################################
#
#  Cleanup
#

rm -f .trace-callback .osgvo-user-job-wrapper.sh >/dev/null 2>&1 || true


#############################################################################
#
#  Run the real job
#
exec "$@"
error=$?
echo "Failed to exec($error): $@" > $_CONDOR_WRAPPER_ERROR_FILE
exit 1



