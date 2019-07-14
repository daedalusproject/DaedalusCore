package Daedalus::Core::Controller::Projects;

use strict;
use warnings;
use Moose;
use namespace::autoclean;
use JSON::XS;
use List::MoreUtils qw(any uniq);
use Daedalus::Utils::Constants qw(
  $bad_request
);

use base qw(Daedalus::Core::Controller::REST);

use Daedalus::Projects::Manager;

__PACKAGE__->config( default => 'application/json' );
__PACKAGE__->config( json_options => { relaxed => 1 } );

BEGIN { extends 'Daedalus::Core::Controller::REST'; return; }

our $VERSION = '0.01';

=head1 NAME

Daedalus::Core::Controller::Projects - Catalyst Controller

=head1 SYNOPSIS

Daedalus::Core Projects Controller.

=head1 DESCRIPTION

Daedalus::Core /project endpoint.

=head1 SEE ALSO

L<https://docs.daedalus-project.io/|Daedalus Project Docs>

=head1 VERSION

$VERSION

=head1 SUBROUTINES/METHODS

=head2 begin

Begin function

=cut

sub begin : ActionClass('Deserialize') {
    my ( $self, $c ) = @_;
    return;
}

=head2 create_project

Create Projects.

Only admin users are allowed to perform this operation.

Required data:   - Organization token
                 - Project name

=cut

sub create_project : Path('/project/create') : Args(0) : ActionClass('REST') {
    my ( $self, $c ) = @_;
    return;
}

=head2 create_project_POST

/project/create is a POST request

=cut

sub create_project_POST {
    my ( $self, $c ) = @_;

    my $response;
    my $organization;
    my $user_data;
    my $project_name;

    my $authorization_and_validatation = $self->authorize_and_validate(
        $c,
        {
            auth => {
                type               => 'organization',
                organization_roles => ['organization_master'],
            },
            required_data => {
                'name' => {
                    name                           => "string",
                    required                       => 1,
                    forbid_empty                   => 1,
                    associated_model               => "CoreRealms",
                    associated_model_source        => "Project",
                    associated_model_source_column => "name",
                },
                organization_token => {
                    type  => "organization",
                    value => $c->{request}->{arguments}[0],
                },
            }
        }
    );

    if ( $authorization_and_validatation->{status} == 0 ) {
        $response = $authorization_and_validatation;
    }
    else {
        $organization = $authorization_and_validatation->{data}->{organization};
        $user_data    = $authorization_and_validatation->{data}->{user_data};
        $project_name =
          $authorization_and_validatation->{data}->{required_data}->{name};

        $response =
          Daedalus::Projects::Manager::create_project( $c,
            $organization->{_hidden_data}->{organization}->{id},
            $project_name );
        $response->{_hidden_data}->{user} =
          $user_data->{_hidden_data}->{user};
    }
    return $self->return_response( $c, $response );
}

=encoding utf8

=head1 DIAGNOSTICS
=head1 CONFIGURATION AND ENVIRONMENT
=head1 DEPENDENCIES

See debian/control

=head1 INCOMPATIBILITIES
=head1 BUGS AND LIMITATIONS
=head1 LICENSE AND COPYRIGHT

Copyright 2018-2019 Álvaro Castellano Vela <alvaro.castellano.vela@gmail.com>

Copying and distribution of this file, with or without modification, are permitted in any medium without royalty provided the copyright notice and this notice are preserved. This file is offered as-is, without any warranty.

=head1 AUTHOR

Álvaro Castellano Vela, alvaro.castellano.vela@gmail.com,,

=cut

__PACKAGE__->meta->make_immutable;

1;
