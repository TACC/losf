#!/bin/bash
#
# $Id$
#
#---------------------------------------------------------
# Designation of Node Types: the current node types
# for Ranger are as follows:
# master, login, lustre, and compute.
# 
# The compute type is the catch-all for nodes that do not
# correspond to one of the other types.  Syntax for the
# designation is "node_type:hostname"
#
# Originally: 4-15-2007 - ks
#             6-21-2007 -> Ranger version
# Texas Advanced Computing Center 
#---------------------------------------------------------


export PRODUCTION_DATE_login="2008-12-02"    # "2008-10-04" "2008-10-04" "2008-07-01,2008-05-06,2008-02-04"
export PRODUCTION_DATE_gridftp="2008-07-01"
export PRODUCTION_DATE_master="2007-12-01"
export PRODUCTION_DATE_oss="2007-06-21"
export PRODUCTION_DATE_sge="2007-06-21"
export PRODUCTION_DATE_mds="2007-06-21"
#export PRODUCTION_DATE_compute="2007-12-16"
export PRODUCTION_DATE_compute="2009-01-16"  # "2007-06-21"      
export PRODUCTION_DATE_vis="2008-09-03"	     #  new Ranger vis sub-system

NODE_TYPES=( login:"login[1-4]|spur" oss:"oss[1-9]+" mds:mds[1-6] \
             compute:"\bcompute-*-*|\bc-*-*|\bamd|\bi-*-*|build|localhost" \
             master:master gridftp:gridftp[1-4] sge:sge[1-2] \
             vis:"visbig|vis[1-7]")

# End Inputs -------------------

export MYHOST=`hostname -s`

#---------------------
# Determine node type
#---------------------

COMPUTE_NODE=0
export BASENAME="undefined"

num_appliances="${#NODE_TYPES[@]}"

if [ "$NODE_TYPE_SILENT" == "" ];then
    NODE_TYPE_SILENT=0
fi

for j in ${NODE_TYPES[@]}; do

    test_type=`echo $j | awk -F: '{print $1}'`
    test_host=`echo $j | awk -F: '{print $2}'`

    result=`echo $MYHOST | egrep $test_host`

    if [ "$result" == "$MYHOST" ]; then

	if [ $NODE_TYPE_SILENT != 1 ];then
	    echo " "
	    echo "This is a $test_type node...($MYHOST)"
	fi

	export BASENAME=$test_type
	
	if [ ${test_type} == "login" ];then
	    PROD_DATE=$PRODUCTION_DATE_login
	elif [ "$test_type" == "gridftp" ];then
	    PROD_DATE=$PRODUCTION_DATE_gridftp
	elif [ "$test_type" == "master" ];then
	    PROD_DATE=$PRODUCTION_DATE_master
	elif [ "$test_type" == "mds" ];then
	    PROD_DATE=$PRODUCTION_DATE_mds
	elif [ "$test_type" == "oss" ];then
	    PROD_DATE=$PRODUCTION_DATE_oss
	elif [ "$test_type" == "sge" ];then
	    PROD_DATE=$PRODUCTION_DATE_sge
	elif [ "$test_type" == "vis" ];then
	    PROD_DATE=$PRODUCTION_DATE_vis
 	elif [ "$test_type" == "compute" ];then
	    PROD_DATE=$PRODUCTION_DATE_compute
	    COMPUTE_NODE=1
	fi
    fi

done

if [ "$BASENAME" == "undefined" ];then
    echo " "
    echo "I'm very sorry to report that I can't determine the node type for $MYHOST"
    echo "You should probably go yell at karl as he's a dodgy bastard"
    echo " "
    exit 1
fi

if [ $NODE_TYPE_SILENT != 1 ];then
    echo "--> os-update production date = $PROD_DATE"
    echo "basename = $BASENAME"

    if [ COMPUTE_NODE == 1 ];then
	echo " "
    	echo "This is a compute node...($MYHOST)"
	export BASENAME=compute
	export PROD_DATE=$PRODUCTION_DATE_compute
	echo "--> os-update production date = $PROD_DATE"
	echo " "
    fi
fi

