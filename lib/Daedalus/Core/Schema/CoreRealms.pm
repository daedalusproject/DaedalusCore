use utf8;

package Daedalus::Core::Schema::CoreRealms;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;

# Created by DBIx::Class::Schema::Loader v0.07048 @ 2018-05-03 07:05:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rP3H5zA1qM/GAl6uMxDwJQ

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
1;