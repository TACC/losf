#!/usr/bin/perl
#-----------------------------------------------------------------------bl-
#--------------------------------------------------------------------------
# 
# LosF - a Linux operating system Framework for HPC clusters
#
# Copyright (C) 2007-2013 Karl W. Schulz
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the Version 2 GNU General
# Public License as published by the Free Software Foundation.
#
# These programs are distributed in the hope that they will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc. 51 Franklin Street, Fifth Floor, 
# Boston, MA  02110-1301  USA
#
#-----------------------------------------------------------------------el-
# Configuration paths definitions.
#
# $Id$
#--------------------------------------------------------------------------

package LosF_paths;
use strict;
use base 'Exporter';
use File::Basename;

our @EXPORT            = qw($osf_top_dir 
			    $osf_config_dir
                            $osf_custom_config_dir
		            $osf_utils_dir
		            $osf_log4perl_dir
		            $osf_ini4perl_dir
                            $osf_term_prompt_dir
			    $osf_osupdates_dir);

# Determine full path to LosF install
		       
our $osf_top_dir       = "";

my ($filename,$basename) = fileparse($0);

# Strip off utils/ dir if necessary

if ($basename =~ m/(.*)\/utils\/$/) {
    our $osf_top_dir = $1;
} else {
    our $osf_top_dir = $basename;
}

# ----------------------------------------------------------------------
# v0.43.0 Change:
#
# require user to provide us with a config path (we
# no longer assume it is local to LosF install since users will likely
# want to use their own SCM for config files). Config path can be
# specified in one of two ways:
# 
# 1. LOSF_CONFIG_DIR environment variable
# 2. config/config_dir file in locally running LosF path
#
# The environment variable takes precedence over config_dir setting
# ----------------------------------------------------------------------

# Allow for potential separation of LosF install path and LosF
# configuration path. By default, we assume a config/ dir local to the
# LosF install but this can be overridden by an environment variable.

my $config_dir = $ENV{'LOSF_CONFIG_DIR'};

if ( defined $ENV{'LOSF_CONFIG_DIR'} ) {
    if ( -d $config_dir ) {
	# remove trailing slash if present

	if($config_dir =~ /(.*)\/$/) {
	    chop($config_dir);
	}
	our $osf_config_dir        = $config_dir;
	our $osf_custom_config_dir = $config_dir;
###	our $osf_custom_config = 1;
    } else {
	MYERROR("LOSF_CONFIG_DIR provided path does not exist ($config_dir)");
    }
} else {
    my $local_config_file="$osf_top_dir/config/config_dir";
    if ( -s $local_config_file ) {
	open (my $IN,"<$local_config_file") || MYERROR("Unable to open  file ($local_config_file)");
	my $local_config_dir = <$IN>;
	chomp($local_config_dir);
	close($IN);

	if ( -d $local_config_dir ) {

	    # remove trailing slash if present
	    if($local_config_dir =~ /(.*)\/$/) {
		chop($local_config_dir);
	    }

	    our $osf_config_dir        = "$local_config_dir";
	    our $osf_custom_config_dir = "$local_config_dir";
	} else {
	    print "\nError: A valid LosF config directory was not provided. You must provide a valid config\n";
	    print "path for your local cluster. You can do this via one of two methods:\n\n";
	    print "  (1) Set the LOSF_CONFIG_DIR environment variable\n";
	    print "  (2) Add your desired config path to the file -> $osf_top_dir/config/config_dir\n\n";
	    print "Example configuration files are availabe at -> $osf_top_dir/config/config_example\n\n";
	    exit(1);
	}
    }
}

our $osf_utils_dir         = "$osf_top_dir/utils";
our $osf_log4perl_dir      = "$osf_utils_dir/dependencies/mschilli-log4perl-d124229/lib";
our $osf_ini4perl_dir      = "$osf_utils_dir/dependencies/Config-IniFiles-2.68/lib";
our $osf_term_prompt_dir   = "$osf_utils_dir/dependencies/Term-Prompt-1.04/lib";
our $osf_osupdates_dir     = "$osf_top_dir/os-updates";

unless(-d $osf_osupdates_dir){
    mkdir $osf_osupdates_dir or die("[ERROR]: Unable to create dir ($osf_osupdates_dir)\n");
}

1;
