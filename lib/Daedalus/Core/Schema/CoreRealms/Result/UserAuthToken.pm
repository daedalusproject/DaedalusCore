use utf8;

package Daedalus::Core::Schema::CoreRealms::Result::UserAuthToken;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Daedalus::Core::Schema::CoreRealms::Result::UserAuthToken

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=back

=cut

__PACKAGE__->load_components( "InflateColumn::DateTime", "TimeStamp" );

=head1 TABLE: C<user_auth_tokens>

=cut

__PACKAGE__->table("user_auth_tokens");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 active

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 auth_token

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 32

=cut

__PACKAGE__->add_columns(
    "id",
    {
        data_type         => "bigint",
        extra             => { unsigned => 1 },
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    "user_id",
    {
        data_type      => "bigint",
        extra          => { unsigned => 1 },
        is_foreign_key => 1,
        is_nullable    => 0,
    },
    "active",
    { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
    "auth_token",
    {
        data_type     => "varchar",
        default_value => "",
        is_nullable   => 0,
        size          => 32
    },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<Daedalus::Core::Schema::CoreRealms::Result::User>

=cut

__PACKAGE__->belongs_to(
    "user",
    "Daedalus::Core::Schema::CoreRealms::Result::User",
    { id            => "user_id" },
    { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);

# Created by DBIx::Class::Schema::Loader v0.07048 @ 2018-05-07 06:47:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:s6XmaU8w/ThengxGpAgaPQ

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
