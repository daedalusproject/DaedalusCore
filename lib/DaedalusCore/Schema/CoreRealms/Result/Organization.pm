use utf8;

package DaedalusCore::Schema::CoreRealms::Result::Organization;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DaedalusCore::Schema::CoreRealms::Result::Organization

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

=head1 TABLE: C<organizations>

=cut

__PACKAGE__->table("organizations");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 100

=head2 created_at

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 modified_at

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
    "id",
    {
        data_type         => "bigint",
        extra             => { unsigned => 1 },
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    "name",
    {
        data_type     => "varchar",
        default_value => "",
        is_nullable   => 0,
        size          => 100
    },
    "created_at",
    {
        data_type                 => "timestamp",
        datetime_undef_if_invalid => 1,
        is_nullable               => 0,
    },
    "modified_at",
    {
        data_type                 => "timestamp",
        datetime_undef_if_invalid => 1,
        is_nullable               => 0,
    },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 organization_role_groups

Type: has_many

Related object: L<DaedalusCore::Schema::CoreRealms::Result::OrganizationRoleGroup>

=cut

__PACKAGE__->has_many(
    "organization_role_groups",
    "DaedalusCore::Schema::CoreRealms::Result::OrganizationRoleGroup",
    { "foreign.organization_id" => "self.id" },
    { cascade_copy              => 0, cascade_delete => 0 },
);

=head2 user_organizations

Type: has_many

Related object: L<DaedalusCore::Schema::CoreRealms::Result::UserOrganization>

=cut

__PACKAGE__->has_many(
    "user_organizations",
    "DaedalusCore::Schema::CoreRealms::Result::UserOrganization",
    { "foreign.organization_id" => "self.id" },
    { cascade_copy              => 0, cascade_delete => 0 },
);

# Created by DBIx::Class::Schema::Loader v0.07048 @ 2018-05-08 06:57:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hnbfzeGSNr88PqaDfymXRw

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
