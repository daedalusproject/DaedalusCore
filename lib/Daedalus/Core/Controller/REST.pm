package Daedalus::Core::Controller::REST;

use strict;
use warnings;
use Moose;
use namespace::autoclean;
use JSON;
use Data::Dumper;

use base qw(Catalyst::Controller::REST);

use Daedalus::Core::Controller::UserController qw(confirmUserRegistration);
use Daedalus::Users::Manager;

__PACKAGE__->config( default => 'application/json' );
__PACKAGE__->config( json_options => { relaxed => 1 } );

BEGIN { extends 'Catalyst::Controller::REST' }

=head1 NAME

Daedalus::Core::Controller::REST - Catalyst Controller

=head1 DESCRIPTION

Daedalus::Core REST Controller.

=head1 METHODS

=cut

=head2 ping

Returns "pong"

=cut

sub begin : ActionClass('Deserialize') {
    my ( $self, $c ) = @_;
}

sub ping : Path('/ping') : Args(0) : ActionClass('REST') {
    my ( $self, $c ) = @_;
}

sub ping_GET {
    my ( $self, $c ) = @_;
    return $self->status_ok(
        $c,
        entity => {
            status => "pong",
        },
    );
}

=head2 loginUser

Login user

=cut

sub loginUser : Path('/login') : Args(0) : ActionClass('REST') {
    my ( $self, $c ) = @_;
}

sub loginUser_GET {
    my ( $self, $c ) = @_;
    return $self->status_ok(
        $c,
        entity => {
            status  => 'Failed',
            message => 'This method does not support GET requests.',
        },
    );
}

sub loginUser_POST {
    my ( $self, $c ) = @_;
    my $request = $c->req;

    my $parameters = $request->data;
    my $auth       = $parameters->{auth};

    #Check paramms first

    # Check user
    my $response = Daedalus::Users::Manager::auth_user_using_model(
        {
            request => $request->data,
            model   => $c->model('CoreRealms::User'),
        }
    );

    return $self->status_ok( $c, entity => $response, );

}

=head2 registerNewUser

Admin users are able to create new users.

=cut

sub registeruser : Path('/registernewuser') : Args(0) : ActionClass('REST') {
    my ( $self, $c ) = @_;

}

sub registeruser_GET {
    my ( $self, $c ) = @_;
    return $self->status_ok(
        $c,
        entity => {
            status  => 'Failed',
            message => 'This method does not support GET requests.',
        },
    );
}

=head2 confrimRegister

Receives Auth token, if that token is owned by unactive user, user is registered.

=cut

sub confrimRegister : Path('/confirmuserregistration') : Args(1) :
  ActionClass('REST') {
    my ( $self, $c, $auth_token ) = @_;
    my ( $status, @user_info ) =
      Daedalus::Core::Controller::UserController->confirmUserRegistration( $c,
        $auth_token );
    die("Stop");
}

sub confrimRegister_POST {
    my ( $self, $c ) = @_;
    return $self->status_ok(
        $c,
        entity => {
            status => "pong",
        },
    );
}

=encoding utf8

=head1 AUTHOR

Álvaro Castellano Vela, alvaro.castellano.vela@gmail.com,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
