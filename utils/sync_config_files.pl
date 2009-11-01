#!/usr/bin/perl
#
# $Id: utils.pl 200 2009-11-01 17:48:31Z karl $
#
#-------------------------------------------------------------------
#
# Utility Functions for Syncing Small Configuration Files
#
# $Id: utils.pl 200 2009-11-01 17:48:31Z karl $
#-------------------------------------------------------------------

use OSF_paths;
use base 'Exporter';
use lib "$osf_log4perl_dir";
use File::Basename;
use File::Compare;
use File::Copy;
use File::Temp qw(tempfile);

my $motd_production="/etc/motd";

sub sync_const_file {

    begin_routine();

    my $file    = shift;
    my $logr    = get_logger();
    my $found   = 0;

    (my $cluster, my $type) = determine_node_membership();

    if ( ! -s "$file" ) {
	WARN("Warning: production file $file not found - not syncing file\n");
	end_routine();
	return;
    }

    my $basename = basename($file);
    INFO("--> Attempting to sync file: $file (base = $basename)\n");

    my $sync_file = "$osf_top_dir/config/const_files/$cluster/$type/$basename";
    DEBUG("--> Looking for file $sync_file\n");

    if ( ! -s $sync_file ) {
	WARN("Warning: $sync_file not found - not syncing...\n");
	end_routine();
	return;
    }

    if ( compare($file,$sync_file) == 0 ) {
	INFO("--> Files are the same - no sync required.\n");
    } else {
	INFO("--> Differences found: $basename requires syncing\n");

	(my $fh, my $tmpfile) = tempfile();

	DEBUG("--> Copying contents to $tmpfile\n");

	copy("$sync_file","$tmpfile") || MYERROR("Unable to copy $sync_file to $tmpfile");
	copy("$tmpfile","$file")      || MYERROR("Unable to move $tmpfile to $file");
	unlink("$tmpfile")            || MYERROR("Unable to remove $tmpfile");

	INFO("--> Sync successful\n");
    }
    
    end_routine();
}

1;

