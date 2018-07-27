#! /usr/bin/env perl
###################################################
#
#  Copyright (C) 2018 Yassine Ilmi and Shutter Team
#
#  This file is part of Shutter.
#
#  Shutter is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  Shutter is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with Shutter; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
###################################################

package QubesSendTo;

use lib $ENV{'SHUTTER_ROOT'}.'/share/shutter/resources/modules';

use utf8;
use strict;
use POSIX qw/setlocale/;
use Locale::gettext;
use Glib qw/TRUE FALSE/;
use Data::Dumper;

use Shutter::Upload::Shared;
our @ISA = qw(Shutter::Upload::Shared);

my $d = Locale::gettext->domain("shutter-upload-plugins");
$d->dir( $ENV{'SHUTTER_INTL'} );

my %upload_plugin_info = (
	'module'                        => "QubesSendTo",
	'url'                           => "",
	'registration'                  => "",
	'name'                          => "QubesOS qvm-copy-to-vm wrapper",
	'description'                   => "Copy a screenshot to an AppVM",
	'supports_anonymous_upload'     => TRUE,
	'supports_authorized_upload'    => FALSE,
	'supports_oauth_upload'         => FALSE,
);

binmode( STDOUT, ":utf8" );
if ( exists $upload_plugin_info{$ARGV[0]} ) {
	print $upload_plugin_info{$ARGV[0]};
	exit;
}

###################################################

sub new {
	my $class = shift;
	my $self = $class->SUPER::new( shift, shift, shift, shift, shift, shift );

	bless $self, $class;
	return $self;
}


sub init {
	my $self = shift;

	$self->{_config} = {};
	$self->{_config}->{vm_name} = '';
	$self->{_config}->{default_config_file} = $ENV{"HOME"} . "/.shutter-qubes-default-vm";

	return $self->connect;
}


sub connect {
	my $self = shift;
	return $self->setup;
}


sub setup {
	my $self = shift;

	if ($self->{_debug_cparam}) {
		print "Getting target VM...\n";
	}

	my $sd = Shutter::App::SimpleDialogs->new;
	my $combobox = Gtk2::ComboBox->new_text;


	my @top_vm_list = ();
	my $top_vm_file = $self->{_config}->{default_config_file}; 
	if ( -e $top_vm_file ) {
		open(my $fh, '<', $top_vm_file)
			or die "Could not open file '$top_vm_file' $!";
		@top_vm_list = <$fh>;
		close $fh;
	}
	chomp(@top_vm_list);

	my @output = `qvm-ls --fields NAME | grep -Ev "NAME|dom0"`;
	foreach my $vm (@output) {
		chomp($vm);
		if (grep { $_ eq $vm }  @top_vm_list) {
			$combobox->prepend_text($vm);
		}
		else {
			$combobox->append_text($vm);
		}
	}

	$combobox->set_active(0);
	$combobox->signal_connect(
		changed => sub {
			$self->{_config}->{vm_name} = $combobox->get_active_text;
		}
	);

	my $response = $sd->dlg_info_message(
        $d->get("Please select target AppVM"),
        $d->get("Qubes send to VM"),
        'gtk-cancel','gtk-apply', undef,undef, undef, undef, undef, undef,$combobox);
	if ($response == 20) {
		return TRUE;
	}else {
		return FALSE;
	}
}

sub upload {
	my ( $self, $upload_filename ) = @_;

	$self->{_filename} = $upload_filename;
	my $vm_name = $self->{_config}->{vm_name};

	utf8::encode $upload_filename;
	utf8::encode $vm_name;

	eval{

		my @args = ("bash", "qvm-copy-to-vm", $vm_name, $upload_filename);
		if (system(@args) == 0) {
			$self->{_links}{'status'} = 200;
		}else {
			$self->{_links}{'status'} = 'Copy failed to ' . $vm_name;
		}
	};

	return %{ $self->{_links} };
}

1;