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

use Storable qw(store retrieve freeze thaw nstore nstore_fd);
use Fcntl qw(:DEFAULT :flock);
use Data::Dumper;
use strict;
use warnings;

my %node_history        = ();
my $DATA_VERSION        = "1.0";
my $HOST_ENTRY_SIZE_1_0 = 4;
my $DATA_FILE="/admin/build/admin/hpc_stack/.losf_log_data";

sub add_node_event
{
    my $host       = shift;
    my $action     = shift;
    my $comment    = shift;
    my $admin_user = shift;
###    my $user       = shift;
###    my $job_id     = shift;

    my $timestamp=`date +"%F %r"`;
    chomp($timestamp);

    # validate action

    if($action eq "open") {print "open detected\n"};

    die("Unsupported action") if ( $action ne "close"   &&
				   $action ne "open"    && 
				   $action ne "comment");

    push @{$node_history{$host} },($timestamp,$action,$comment,$admin_user);

}

sub save_state_1_0
{
    # Initiate file lock

    sysopen(FH,$DATA_FILE,O_RDWR|O_CREAT, 0640) or die "Unable to open $DATA_FILE";
    flock  (FH, LOCK_EX)                        or die "Cannot lock $DATA_FILE: $!";

    # save the state

    nstore_fd ([$DATA_VERSION,%node_history ],*FH) or die "Unable to store log state to file";
    truncate(FH,tell(FH));

    # Release the lock

    close(FH);
}

sub read_state_1_0
{
#    my $retrieved = retrieve("/tmp/koomielog");
    ($DATA_VERSION,%node_history) = @{retrieve ($DATA_FILE)};
}

sub dump_state_1_0
{

    print "-" x 94;
    print "--- DATA VERSION = $DATA_VERSION ---";
    print "\n";
    print "Hostname         Timestamp         Action           Comment                      ";
    print "                                 User\n";
    for my $key (keys %node_history) {
	my $num_entries = @{$node_history{$key}};
	
	my @value = @{$node_history{$key}};
	my $count =0;
	for($count=0;$count<$num_entries;$count+=$HOST_ENTRY_SIZE_1_0) {
	    printf("%-10s ", $key);
	    printf("%-22s ",($value[$count+0]));
	    printf("%7s   ",($value[$count+1]));
	    printf("%-66s ",($value[$count+2]));
	    printf("%8s ",  ($value[$count+3]));
	    printf("\n");
	}

    }
    print "-" x 120;
    print "\n";
}

sub clear_state 
{
    $DATA_VERSION = "";
    %node_history = ();
}

my %node_status  = ("c401-101" => 0, "c401-102" => 1, "c401-103" => 0);

add_node_event("c401-101","open","just a test","koomie");
add_node_event("c401-101","close","uh oh","koomie");
add_node_event("c401-102","open","just a test2","koomie");

#print Dumper(%node_status);
print "before dump....\n";
###print Dumper(%node_history);
###dump_state_1_0();
save_state_1_0();
clear_state();
print "after clear - before read\n";
#####print Dumper(%node_history);
read_state_1_0();

print "after read....\n";
print "version = $DATA_VERSION\n";
###print Dumper(%node_history);

dump_state_1_0();





