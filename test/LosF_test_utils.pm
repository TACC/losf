#!/usr/bin/env perl
#-----------------------------------------------------------------------bl-
#--------------------------------------------------------------------------
# 
# LosF - a Linux operating system Framework for HPC clusters
#
# Copyright (C) 2007-2014 Karl W. Schulz <losf@koomie.com>
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
# Support routines for regression testing.
#--------------------------------------------------------------------------

package LosF_test_utils;
use strict;
use warnings;
use Exporter qw(import);
use File::Basename;
use Test::More;

our @EXPORT = qw(test_binary_existence);

sub test_binary_existence {
    my $binary = shift;
    my $basename = basename($binary);
    ok (-x "$binary", "$basename binary");
    return;
}

1;
