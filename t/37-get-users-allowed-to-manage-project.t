use v5.26;
use strict;
use warnings;
use Test::More;

use Catalyst::Test 'Daedalus::Core';
use Daedalus::Core::Controller::REST;

use JSON::XS;
use MIME::Base64;
use HTTP::Request::Common qw(GET PUT POST DELETE);

use FindBin qw($Bin);
use lib "$Bin/../lib";
use lib "$Bin/script";

use DatabaseSetUpTearDown;

use Data::Dumper;

DatabaseSetUpTearDown::delete_database();
DatabaseSetUpTearDown::create_database();

my $endpoint = '/project/users';

my $non_admin_login_success = request(
    POST '/user/login',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            'e-mail' => 'noadmin@megashops.com',
            password => '__;;_12__Password_34',
        }
    )
);

is( $non_admin_login_success->code(), 200, );

my $non_admin_login_success_json =
  decode_json( $non_admin_login_success->content );

is( $non_admin_login_success_json->{status}, 1, );

my $non_admin_login_success_token =
  $non_admin_login_success_json->{data}->{session_token};

my $non_admin_authorization_basic =
  MIME::Base64::encode( "session_token:$non_admin_login_success_token", '' );

my $admin_login_success = request(
    POST '/user/login',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            'e-mail' => 'otheradminagain@megashops.com',
            password => '__::___Password_1234',
        }
    )
);

is( $admin_login_success->code(), 200, );

my $admin_login_success_json = decode_json( $admin_login_success->content );

is( $admin_login_success_json->{status}, 1, );

my $admin_login_success_token =
  $admin_login_success_json->{data}->{session_token};

my $admin_authorization_basic =
  MIME::Base64::encode( "session_token:$admin_login_success_token", '' );

my $superadmin_login = request(
    POST '/user/login',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            'e-mail' => 'admin@daedalus-project.io',
            password => 'this_is_a_Test_1234',
        }
    )
);

is( $superadmin_login->code(), 200, );

my $superadmin_login_json = decode_json( $superadmin_login->content );

is( $superadmin_login_json->{status}, 1, );

my $superadmin_session_token = $superadmin_login_json->{data}->{session_token};

my $superadmin_authorization_basic =
  MIME::Base64::encode( "session_token:$superadmin_session_token", '' );

my $hank_scorpio_login_success = request(
    POST '/user/login',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            'e-mail' => 'hscorpio@globex.com',
            password => '::::Sc0rP10___:::;;;;;',
        }
    )
);

is( $hank_scorpio_login_success->code(), 200, );

my $hank_scorpio_login_success_json =
  decode_json( $hank_scorpio_login_success->content );

is( $hank_scorpio_login_success_json->{status}, 1, );

my $hank_scorpio_login_success_token =
  $hank_scorpio_login_success_json->{data}->{session_token};

my $hank_scorpio_authorization_basic =
  MIME::Base64::encode( "session_token:$hank_scorpio_login_success_token", '' );

my $super_boss_login_success = request(
    POST '/user/login',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            'e-mail' => 'superboos@bugstech.com',
            password => '__:bugs:___Password_1234',
        }
    )
);

is( $super_boss_login_success->code(), 200, );

my $super_boss_login_success_json =
  decode_json( $super_boss_login_success->content );

is( $super_boss_login_success_json->{status}, 1, );

my $super_boss_login_success_token =
  $super_boss_login_success_json->{data}->{session_token};

my $super_boss_authorization_basic =
  MIME::Base64::encode( "session_token:$super_boss_login_success_token", '' );

my $failed_no_organization_token = request(
    GET $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $non_admin_authorization_basic",
);

is( $failed_no_organization_token->code(), 404, );

my $failed_admin_no_organization_token = request(
    GET $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $admin_authorization_basic",
);

is( $failed_admin_no_organization_token->code(), 404, );

my $failed_invalid_organization_token_no_project_token = request(
    GET "$endpoint/someorganizationtoken",
    Content_Type  => 'application/json',
    Authorization => "Basic $non_admin_authorization_basic",
);

is( $failed_invalid_organization_token_no_project_token->code(), 404, );

my $failed_admin_invalid_organization_token_invalid_project_token = request(
    GET "$endpoint/someorganizationtoken/invalidprojecttoken",
    Content_Type  => 'application/json',
    Authorization => "Basic $admin_authorization_basic",
);

is( $failed_admin_invalid_organization_token_invalid_project_token->code(),
    400, );

my $failed_admin_invalid_organization_token_invalid_project_token_json =
  decode_json(
    $failed_admin_invalid_organization_token_invalid_project_token->content );

is(
    $failed_admin_invalid_organization_token_invalid_project_token_json
      ->{status},
    0,
);
is(
    $failed_admin_invalid_organization_token_invalid_project_token_json
      ->{message},
    'Invalid organization token.',
);

my $failed_not_your_organization = request(
    GET "$endpoint/cnYXfKLhTIgYxX7zHZLYjEAL1k8UhtvW/invalidprojecttoken"
    ,    # Bugs Techs
    Content_Type  => 'application/json',
    Authorization => "Basic $non_admin_authorization_basic",
);

is( $failed_not_your_organization->code(), 400, );

my $failed_not_your_organization_json =
  decode_json( $failed_not_your_organization->content );

is( $failed_not_your_organization_json->{status}, 0, );
is(
    $failed_not_your_organization_json->{message},
    'Invalid organization token.',
);

my $failed_admin_not_your_organization = request(
    GET "$endpoint/cnYXfKLhTIgYxX7zHZLYjEAL1k8UhtvW/invalidprojecttoken"
    ,    # Bugs Techs
    Content_Type  => 'application/json',
    Authorization => "Basic $admin_authorization_basic",
);

is( $failed_admin_not_your_organization->code(), 400, );

my $failed_admin_not_your_organization_json =
  decode_json( $failed_admin_not_your_organization->content );

is( $failed_admin_not_your_organization_json->{status}, 0, );
is(
    $failed_admin_not_your_organization_json->{message},
    'Invalid organization token.',
);

my $failed_not_organization_admin = request(
    GET "$endpoint/ljMPXvVHZZQTbXsaXWA2kgSWzL942Puf/invalidprojecttoken"
    ,    # Mega shops
    Content_Type  => 'application/json',
    Authorization => "Basic $non_admin_authorization_basic",
);

is( $failed_not_organization_admin->code(), 403, );

my $failed_not_organization_admin_json =
  decode_json( $failed_not_organization_admin->content );

is( $failed_not_organization_admin_json->{status}, 0, );
is(
    $failed_not_organization_admin_json->{message},
'Your organization roles does not match with the following roles: organization master.',
);

is( $failed_not_organization_admin_json->{_hidden_data}, undef, );

my $invalid_organization_project = request(
    GET
      "$endpoint/AUDBO7LQvpFciDhfuApGkVbpYQqJVFV3/invalidprojecttoken", # Globex
    Content_Type  => 'application/json',
    Authorization => "Basic $hank_scorpio_authorization_basic",
);

is( $invalid_organization_project->code(), 400, );

my $invalid_organization_project_json =
  decode_json( $invalid_organization_project->content );

is( $invalid_organization_project_json->{status}, 0, );

is( $invalid_organization_project_json->{message}, 'Invalid project_token.', );

my $create_arcturus_project = request(
    POST '/project/create',
    Content_Type  => 'application/json',
    Authorization => "Basic $hank_scorpio_authorization_basic",
    Content       => encode_json(
        {
            'organization_token' => 'AUDBO7LQvpFciDhfuApGkVbpYQqJVFV3', # Globex
            'name'               => 'Arcturus Project',
        }
    )
);

is( $create_arcturus_project->code(), 200, );

my $create_arcturus_project_json =
  decode_json( $create_arcturus_project->content );

my $arcturus_project_token =
  $create_arcturus_project_json->{data}->{project}->{token};

my $invalid_not_your_organization_project = request(
    GET
"$endpoint/AUDBO7LQvpFciDhfuApGkVbpYQqJVFV3/igcSJAryn0ZoK7tns9StDJwU4mi1Wcpj"
    ,    # Globex # Bugs e-commerce
    Content_Type  => 'application/json',
    Authorization => "Basic $hank_scorpio_authorization_basic",
);

is( $invalid_not_your_organization_project->code(), 400, );

my $invalid_not_your_organization_project_json =
  decode_json( $invalid_not_your_organization_project->content );

is( $invalid_not_your_organization_project_json->{status}, 0, );

is(
    $invalid_not_your_organization_project_json->{message},
    'Invalid project token.',
);

my $invalid_not_your_organization_project_super_admin = request(
    GET
"$endpoint/FrFM2p5vUb2FpQ0Sl9v0MXvJnb4OxNzO/igcSJAryn0ZoK7tns9StDJwU4mi1Wcpj"
    ,    # Globex # Bugs e-commerce
    Content_Type  => 'application/json',
    Authorization => "Basic $superadmin_authorization_basic",
);

is( $invalid_not_your_organization_project_super_admin->code(), 400, );

my $invalid_not_your_organization_project_super_admin_json =
  decode_json( $invalid_not_your_organization_project_super_admin->content );

is( $invalid_not_your_organization_project_super_admin_json->{status}, 0, );

is(
    $invalid_not_your_organization_project_super_admin_json->{message},
    'Project does not belong to this organization.',
);

my $success_admin_with_no_users = request(
    GET "$endpoint/AUDBO7LQvpFciDhfuApGkVbpYQqJVFV3/$arcturus_project_token"
    ,    # Globex
    Content_Type  => 'application/json',
    Authorization => "Basic $hank_scorpio_authorization_basic",
);

is( $success_admin_with_no_users->code(), 200, );

my $success_admin_with_no_users_json =
  decode_json( $success_admin_with_no_users->content );

is( $success_admin_with_no_users_json->{message}, undef, );

is( $success_admin_with_no_users_json->{status}, 1, );

is( $success_admin_with_no_users_json->{_hidden_data}, undef, );

isnt( $success_admin_with_no_users_json->{data},          undef, );
isnt( $success_admin_with_no_users_json->{data}->{users}, undef, );

is( keys %{ $success_admin_with_no_users_json->{data}->{users} },
    0, 'For the time being this organization has no shared projects with it.' );

done_testing();

#DatabaseSetUpTearDown::delete_database();
