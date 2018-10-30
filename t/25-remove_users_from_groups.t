use strict;
use warnings;
use Test::More;

use Catalyst::Test 'Daedalus::Core';
use Daedalus::Core::Controller::REST;

use JSON::XS;
use MIME::Base64;
use HTTP::Request::Common qw(GET PUT POST DELETE);

my $endpoint = '/organization/removeuserfromgroup';

my $failed_because_no_auth_token =
  request( DELETE $endpoint, Content_Type => 'application/json', );

is( $failed_because_no_auth_token->code(), 400, );

my $failed_because_no_auth_token_json =
  decode_json( $failed_because_no_auth_token->content );

is( $failed_because_no_auth_token_json->{status}, 0, );
is(
    $failed_because_no_auth_token_json->{message},
    "No session token provided.",
);

my $non_admin_success = request(
    POST '/user/login',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            'e-mail' => 'notanadmin@daedalus-project.io',
            password => 'Test_is_th1s_123',
        }
    )
);

is( $non_admin_success->code(), 200, );

my $non_admin_success_json = decode_json( $non_admin_success->content );

is( $non_admin_success_json->{status}, 1, );

my $not_admin_session_token = $non_admin_success_json->{data}->{session_token};

my $not_admin_authorization_basic =
  MIME::Base64::encode( "session_token:$not_admin_session_token", '' );

my $failed_no_token = request(
    DELETE $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $not_admin_authorization_basic",
);

is( $failed_no_token->code(), 400, );

my $failed_no_token_json = decode_json( $failed_no_token->content );

is( $failed_no_token_json->{status}, 0, );
is(
    $failed_no_token_json->{message},
    'No organization_token provided.',
    'Because you are not an admin user.'
);

my $failed_no_admin = request(
    DELETE $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $not_admin_authorization_basic",
    Content       => encode_json(
        {
            organization_token => 'ljMPXvVHZZQTbXsaXWA2kgSWzL942Puf',
            group_name         => 'Mega Shops Administrators',
            user_email         => 'otheradminagain@megashops.com'
        }
    ),
);

is( $failed_no_admin->code(), 400, );

my $failed_no_admin_json = decode_json( $failed_no_admin->content );

is( $failed_no_admin_json->{status}, 0, );
is(
    $failed_no_admin_json->{message},
    'Invalid organization token.',
    'Beacuse you are not an admin user.'
);

my $admin_success = request(
    POST '/user/login',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            'e-mail' => 'otheradminagain@megashops.com',
            password => '__::___Password_1234',
        }
    )
);

is( $admin_success->code(), 200, );

my $admin_success_json = decode_json( $admin_success->content );

is( $admin_success_json->{status}, 1, );

my $admin_session_token = $admin_success_json->{data}->{session_token};

my $admin_authorization_basic =
  MIME::Base64::encode( "session_token:$admin_session_token", '' );

my $failed_no_data = request(
    DELETE $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $admin_authorization_basic",
    Content       => encode_json( {} )
);

is( $failed_no_data->code(), 400, );
#
my $failed_no_data_json = decode_json( $failed_no_data->content );

is( $failed_no_data_json->{status},  0, );
is( $failed_no_data_json->{message}, 'No organization_token provided.', );

my $failed_no_group_data_no_user = request(
    DELETE $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $admin_authorization_basic",
    Content       => encode_json(
        { organization_token => 'ljMPXvVHZZQTbXsaXWA2kgSWzL942Puf' }
    ),
);

is( $failed_no_group_data_no_user->code(), 400, );
#
my $failed_no_group_data_no_user_json =
  decode_json( $failed_no_group_data_no_user->content );

is( $failed_no_group_data_no_user_json->{status}, 0, );
is(
    $failed_no_group_data_no_user_json->{message},
    'No group_name provided. No user_email provided.',
);

my $failed_no_organization_data_no_user = request(
    DELETE $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $admin_authorization_basic",
    Content       => encode_json( { group_name => 'Some Group Name' } ),
);

is( $failed_no_organization_data_no_user->code(), 400, );
#
my $failed_no_organization_data_no_user_json =
  decode_json( $failed_no_organization_data_no_user->content );

is( $failed_no_organization_data_no_user_json->{status}, 0, );
is(
    $failed_no_organization_data_no_user_json->{message},
    'No organization_token provided.',
);

my $failed_no_organization_data_no_group_data = request(
    DELETE $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $admin_authorization_basic",
    Content => encode_json( { user_email => 'nonexistentuser@megashops.com' } ),
);

is( $failed_no_organization_data_no_group_data->code(), 400, );
#
my $failed_no_organization_data_no_group_data_json =
  decode_json( $failed_no_organization_data_no_group_data->content );

is( $failed_no_organization_data_no_group_data_json->{status}, 0, );
is(
    $failed_no_organization_data_no_group_data_json->{message},
    'No organization_token provided.',
);

my $failed_no_organization_data_no_role_data = request(
    DELETE $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $admin_authorization_basic",
    Content       => encode_json(
        {
            organization_token => 'ljMPXvVHZZQTbXsaXWA2kgSWzL942Puf',
            user_email         => 'nonexistentuser@megashops.com'
        }
    ),
);

is( $failed_no_organization_data_no_role_data->code(), 400, );

my $failed_no_organization_data_no_role_data_json =
  decode_json( $failed_no_organization_data_no_role_data->content );

is( $failed_no_organization_data_no_role_data_json->{status}, 0, );
is(
    $failed_no_organization_data_no_role_data_json->{message},
    'No group_name provided.',
);

my $failed_invalid_organization_data = request(
    DELETE $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $admin_authorization_basic",
    Content       => encode_json(
        {
            organization_token => 'ivalidorganizationtoken',
            group_name         => 'non existen group',
            user_email         => 'nonexistentuser@megashops.com'
        }
    ),
);

is( $failed_invalid_organization_data->code(), 400, );

my $failed_invalid_organization_data_json =
  decode_json( $failed_invalid_organization_data->content );

is( $failed_invalid_organization_data_json->{status}, 0, );
is(
    $failed_invalid_organization_data_json->{message},
    'Invalid organization token.',
);

my $failed_invalid_group_data = request(
    DELETE $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $admin_authorization_basic",
    Content       => encode_json(
        {
            organization_token => 'ivalidorganizationtoken',
            group_name         => 'non existen group',
            user_email => 'nonexistentuser@megashops.com'   # There is no clowns
        }
    ),
);

is( $failed_invalid_group_data->code(), 400, );

my $failed_invalid_group_data_json =
  decode_json( $failed_invalid_group_data->content );

is( $failed_invalid_group_data_json->{status}, 0, );
is( $failed_invalid_group_data_json->{message},
    'Invalid organization token.', );

my $failed_group_not_found = request(
    DELETE $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $admin_authorization_basic",
    Content       => encode_json(
        {
            organization_token => 'ljMPXvVHZZQTbXsaXWA2kgSWzL942Puf',
            group_name         => 'Mega Shop Clowns',
            user_email         => 'marvin@megashops.com'
        }
    ),
);

is( $failed_group_not_found->code(), 400, );

my $failed_group_not_found_json =
  decode_json( $failed_group_not_found->content );

is( $failed_group_not_found_json->{status}, 0, );
is( $failed_group_not_found_json->{message},
    'Required group does not exist.', );

my $failed_user_not_found = request(
    DELETE $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $admin_authorization_basic",
    Content       => encode_json(
        {
            organization_token => 'ljMPXvVHZZQTbXsaXWA2kgSWzL942Puf',
            group_name         => 'Mega Shop Sysadmins',
            user_email         => 'nonexistentuser@megashops.com'
        }
    ),
);

is( $failed_user_not_found->code(), 400, );

my $failed_user_not_found_json = decode_json( $failed_user_not_found->content );

is( $failed_user_not_found_json->{status}, 0, );
is(
    $failed_user_not_found_json->{message},
    'There is no registered user with that e-mail address.',
);

my $remove_user_from_group_success = request(
    DELETE $endpoint,
    Content_Type => 'application/json',
    Authorization =>
      "Basic $admin_authorization_basic",    #Megashops Project token
    Content => encode_json(
        {
            organization_token => 'ljMPXvVHZZQTbXsaXWA2kgSWzL942Puf',
            group_name         => 'Mega Shop Sysadmins',
            user_email         => 'marvin@megashops.com'
        }
    ),
);

is( $remove_user_from_group_success->code(), 200, );

my $remove_user_from_group_success_json =
  decode_json( $remove_user_from_group_success->content );

is( $remove_user_from_group_success_json->{status}, 1, );
is(
    $remove_user_from_group_success_json->{message},
    'Required user has been removed from organization group.',
);

is( $remove_user_from_group_success_json->{_hidden_data}, undef, );

my $failed_already_removed = request(
    DELETE $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $admin_authorization_basic",    #Megashops token
    Content       => encode_json(
        {
            organization_token => 'ljMPXvVHZZQTbXsaXWA2kgSWzL942Puf',
            group_name         => 'Mega Shop Sysadmins',
            user_email         => 'marvin@megashops.com'
        }
    ),
);

is( $failed_already_removed->code(), 400, );

my $failed_already_removed_json =
  decode_json( $failed_already_removed->content );

is( $failed_already_removed_json->{status}, 0, );
is(
    $failed_already_removed_json->{message},
    'Required user does not belong to this group.',
);

# Check group

my $admin_user_mega_shop_groups = request(
    GET "/organization/showoallgroups/ljMPXvVHZZQTbXsaXWA2kgSWzL942Puf"
    ,    # Mega Shops Token
    Content_Type  => 'application/json',
    Authorization => "Basic $admin_authorization_basic",
);

is( $admin_user_mega_shop_groups->code(), 200, );

my $admin_user_mega_shop_groups_json =
  decode_json( $admin_user_mega_shop_groups->content );

is( $admin_user_mega_shop_groups_json->{status}, 1, 'Status success.' );
is( keys %{ $admin_user_mega_shop_groups_json->{data}->{groups} },
    3, 'This response contains three groups' );

isnt( $admin_user_mega_shop_groups_json->{data}->{groups},
    undef, 'API response contains organization groups' );

isnt(
    $admin_user_mega_shop_groups_json->{data}->{groups}
      ->{'Mega Shop Sysadmins'},
    undef, 'Now, Mega Shop Sysadmins exists'
);

is(
    scalar @{
        $admin_user_mega_shop_groups_json->{data}->{groups}
          ->{'Mega Shop Sysadmins'}->{users}
    },
    1,
'For the time being Mega Shop Sysadmins group has only one user, marvin@megashops.com has been removed.'
);

my $failed_not_your_organization = request(
    DELETE $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $admin_authorization_basic",    #Megashops token
    Content       => encode_json(
        {
            organization_token =>
              'FrFM2p5vUb2FpQ0Sl9v0MXvJnb4OxNzO',    #Dadeadlus Project token
            group_name => 'Daedalus Project Sysadmins',
            user_email => 'marvin@megashops.com'
        }
    ),
);

is( $failed_not_your_organization->code(), 400, );

my $failed_not_your_organization_json =
  decode_json( $failed_not_your_organization->content );

is( $failed_not_your_organization_json->{status}, 0, );
is(
    $failed_not_your_organization_json->{message},
    'Invalid organization token.',
);

my $superadmin_success = request(
    POST '/user/login',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            'e-mail' => 'admin@daedalus-project.io',
            password => 'this_is_a_Test_1234',
        }
    )
);

is( $superadmin_success->code(), 200, );

my $superadmin_success_json = decode_json( $superadmin_success->content );

is( $superadmin_success_json->{status}, 1, );

my $superadmin_session_token =
  $superadmin_success_json->{data}->{session_token};

my $superadmin_authorization_basic =
  MIME::Base64::encode( "session_token:$superadmin_session_token", '' );

my $superadmin_remove_user_success = request(
    DELETE $endpoint,
    Content_Type => 'application/json',
    Authorization =>
      "Basic $superadmin_authorization_basic",    #Megashops Project token
    Content => encode_json(
        {
            organization_token => 'FrFM2p5vUb2FpQ0Sl9v0MXvJnb4OxNzO',
            group_name         => 'Daedalus Core Sysadmins',
            user_email         => 'notanadmin@daedalus-project.io'
        }
    ),
);

is( $superadmin_remove_user_success->code(), 200, );

my $superadmin_remove_user_success_json =
  decode_json( $superadmin_remove_user_success->content );

is( $superadmin_remove_user_success_json->{status}, 1, );
is(
    $superadmin_remove_user_success_json->{message},
    'Required user has been removed from organization group.',
);

isnt( $superadmin_remove_user_success_json->{_hidden_data}, undef, );

my $superadmin_remove_user_other_organization_success = request(
    DELETE $endpoint,
    Content_Type => 'application/json',
    Authorization =>
      "Basic $superadmin_authorization_basic",    #Megashops Project token
    Content => encode_json(
        {
            organization_token =>
              'ljMPXvVHZZQTbXsaXWA2kgSWzL942Puf',    # Mega shops
            group_name => 'Mega Shop Sysadmins',
            user_email => 'noadmin@megashops.com'
        }
    ),
);

is( $superadmin_remove_user_other_organization_success->code(), 200, );

my $superadmin_remove_user_other_organization_success_json =
  decode_json( $superadmin_remove_user_other_organization_success->content );

is( $superadmin_remove_user_other_organization_success_json->{status}, 1, );
is(
    $superadmin_remove_user_other_organization_success_json->{message},
    'Required user has been removed from organization group.',
);

isnt( $superadmin_remove_user_other_organization_success_json->{_hidden_data},
    undef, );

my $admin_user_mega_shop_one_user = request(
    GET "/organization/showoallgroups/ljMPXvVHZZQTbXsaXWA2kgSWzL942Puf"
    ,    # Mega Shops Token
    Content_Type  => 'application/json',
    Authorization => "Basic $admin_authorization_basic",
);

is( $admin_user_mega_shop_one_user->code(), 200, );

my $admin_user_mega_shop_one_user_json =
  decode_json( $admin_user_mega_shop_one_user->content );

is( $admin_user_mega_shop_one_user_json->{status}, 1, 'Status success.' );

is(
    scalar @{
        $admin_user_mega_shop_one_user_json->{data}->{groups}
          ->{'Mega Shop Sysadmins'}->{users}
    },
    0,
    'Mega Shop Sysadmins has no users'
);

my $failed_remove_removed_user = request(
    DELETE $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $admin_authorization_basic",    #Megashops token
    Content       => encode_json(
        {
            organization_token => 'ljMPXvVHZZQTbXsaXWA2kgSWzL942Puf',
            group_name         => 'Mega Shop Sysadmins',
            user_email         => 'noadmin@megashops.com'
        }
    ),
);

is( $failed_remove_removed_user->code(), 400, );

my $failed_remove_removed_user_json =
  decode_json( $failed_remove_removed_user->content );

is( $failed_remove_removed_user_json->{status}, 0, );
is(
    $failed_remove_removed_user_json->{message},
    'Required user does not belong to this group.',
);

my $failed_unique_admin = request(
    DELETE $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $admin_authorization_basic",    #Megashops token
    Content       => encode_json(
        {
            organization_token => 'ljMPXvVHZZQTbXsaXWA2kgSWzL942Puf',
            group_name         => 'Mega Shops Administrators',
            user_email         => 'otheradminagain@megashops.com'
        }
    ),
);

is( $failed_unique_admin->code(), 400, );

my $failed_unique_admin_json = decode_json( $failed_unique_admin->content );

is( $failed_unique_admin_json->{status}, 0, );
is(
    $failed_unique_admin_json->{message},
'Cannot remove this user, no more admin users will left in this organization.',
);

my $add_new_admin = request(
    POST '/organization/addusertogroup',
    Content_Type  => 'application/json',
    Authorization => "Basic $admin_authorization_basic",    #Megashops token
    Content       => encode_json(
        {
            organization_token => 'ljMPXvVHZZQTbXsaXWA2kgSWzL942Puf',
            group_name         => 'Mega Shops Administrators',
            user_email         => 'marvin@megashops.com'
        }
    ),
);

is( $add_new_admin->code(), 200, );

my $add_new_admin_json = decode_json( $add_new_admin->content );

is( $add_new_admin_json->{status}, 1, );
is(
    $add_new_admin_json->{message},
    'Required user has been added to organization group.',
);

my $remove_user_from_admin_group_success = request(
    DELETE $endpoint,
    Content_Type => 'application/json',
    Authorization =>
      "Basic $admin_authorization_basic",    #Megashops Project token
    Content => encode_json(
        {
            organization_token => 'ljMPXvVHZZQTbXsaXWA2kgSWzL942Puf',
            group_name         => 'Mega Shops Administrators',
            user_email         => 'marvin@megashops.com'
        }
    ),
);

is( $remove_user_from_admin_group_success->code(),
    200,
    'If there are more than one admin this user is able to remove itself.' );

my $remove_user_from_admin_group_success_json =
  decode_json( $remove_user_from_admin_group_success->content );

is( $remove_user_from_admin_group_success_json->{status}, 1, );
is(
    $remove_user_from_admin_group_success_json->{message},
    'Required user has been removed from organization group.',
);

is( $remove_user_from_admin_group_success_json->{_hidden_data}, undef, );

my $superadmin_remove_unique_admin = request(
    DELETE $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $superadmin_authorization_basic",   #Megashops token
    Content       => encode_json(
        {
            organization_token => 'ljMPXvVHZZQTbXsaXWA2kgSWzL942Puf',
            group_name         => 'Mega Shops Administrators',
            user_email         => 'otheradminagain@megashops.com'
        }
    ),
);

is( $superadmin_remove_unique_admin->code(), 200, );

my $superadmin_remove_unique_admin_json =
  decode_json( $superadmin_remove_unique_admin->content );

is( $superadmin_remove_unique_admin_json->{status}, 1, );
is(
    $superadmin_remove_unique_admin_json->{message},
    'Required user has been removed from organization group.',
);

my $failed_no_admin_users_left = request(
    POST '/organization/addusertogroup',
    Content_Type  => 'application/json',
    Authorization => "Basic $admin_authorization_basic",    #Megashops token
    Content       => encode_json(
        {
            organization_token => 'ljMPXvVHZZQTbXsaXWA2kgSWzL942Puf',
            group_name         => 'Mega Shops Administrators',
            user_email         => 'marvin@megashops.com'
        }
    ),
);

is( $failed_no_admin_users_left->code(), 403, );

my $failed_no_admin_users_left_json =
  decode_json( $failed_no_admin_users_left->content );

is( $failed_no_admin_users_left_json->{status}, 0, );
is(
    $failed_no_admin_users_left_json->{message},
    'You are not a organization master of this organization.',
);

my $add_new_admin_again = request(
    POST '/organization/addusertogroup',
    Content_Type  => 'application/json',
    Authorization => "Basic $superadmin_authorization_basic",   #Megashops token
    Content       => encode_json(
        {
            organization_token => 'ljMPXvVHZZQTbXsaXWA2kgSWzL942Puf',
            group_name         => 'Mega Shops Administrators',
            user_email         => 'otheradminagain@megashops.com'
        }
    ),
);

is( $add_new_admin_again->code(), 200, );

my $add_new_admin_again_json = decode_json( $add_new_admin_again->content );

is( $add_new_admin_again_json->{status}, 1, );
is(
    $add_new_admin_again_json->{message},
    'Required user has been added to organization group.',
);

done_testing();