use v5.26;
use strict;
use warnings;
use Test::More;

use Catalyst::Test 'Daedalus::Core';

use Daedalus::Core::Controller::REST;

use JSON::XS;
use HTTP::Request::Common;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use lib "$Bin/script";

use Daedalus::Core::Schema::CoreRealms;
use DatabaseSetUpTearDown;

DatabaseSetUpTearDown::delete_database();
DatabaseSetUpTearDown::create_database();

# Login User

## GET

my $login_get_content = get('/user/login');

ok( $login_get_content, qr /Method GET not implemented/ );

my $failed_login_user_post_content = request(
    POST '/user/login',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            'e-mail' => 'admin@nodomain.io',
            password => 'this_is_a_Test_1234',
        }
    )
);

is( $failed_login_user_post_content->code(), 403, );

my $failed_login_user_post_content_json =
  decode_json( $failed_login_user_post_content->content );

is_deeply(
    $failed_login_user_post_content_json,
    {
        'status'  => 0,
        'message' => 'Wrong e-mail or password.',
    }
);

my $failed_login_user_post_no_email = request(
    POST '/user/login',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            password => 'this_is_a_Test_1234',
        }
    )
);

is( $failed_login_user_post_no_email->code(), 400, );

my $failed_login_user_post_no_email_json =
  decode_json( $failed_login_user_post_no_email->content );

is( $failed_login_user_post_no_email_json->{status},  0, );
is( $failed_login_user_post_no_email_json->{message}, 'No e-mail provided.', );

my $failed_login_user_post_no_password = request(
    POST '/user/login',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            'e-mail' => 'admin@daedalus-project.io',
        }
    )
);

is( $failed_login_user_post_no_password->code(), 400, );

my $failed_login_user_post_no_password_json =
  decode_json( $failed_login_user_post_no_password->content );

is( $failed_login_user_post_no_password_json->{status}, 0, );
is(
    $failed_login_user_post_no_password_json->{message},
    'No password provided.',
);

my $failed_login_password_post_content = request(
    POST '/user/login',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            'e-mail' => 'admin@daedalus-project.io',
            password => 'this_is_a_Failed_password',
        }
    )
);

is( $failed_login_password_post_content->code(), 403, );

my $failed_login_password_post_content_json =
  decode_json( $failed_login_password_post_content->content );

is_deeply(
    $failed_login_password_post_content_json,
    {
        'status'  => 0,
        'message' => 'Wrong e-mail or password.',
    }
);

my $login_non_admin_post_success = request(
    POST '/user/login',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            'e-mail' => 'notanadmin@daedalus-project.io',
            password => 'Test_is_th1s_123',
        }
    )
);

is( $login_non_admin_post_success->code(), 200, );

my $login_non_admin_post_success_json =
  decode_json( $login_non_admin_post_success->content );

is( $login_non_admin_post_success_json->{status},  1, );
is( $login_non_admin_post_success_json->{message}, 'Auth Successful.', );
is(
    $login_non_admin_post_success_json->{data}->{user}->{'e-mail'},
    'notanadmin@daedalus-project.io',
);

isnt( $login_non_admin_post_success_json->{data}->{user}->{api_key}, undef, );

is( $login_non_admin_post_success_json->{data}->{user}->{is_admin}, 0, );
is( $login_non_admin_post_success_json->{_hidden_data},
    undef, 'Non admin users do no receive hidden data' );

my $login_admin_post_success = request(
    POST '/user/login',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            'e-mail' => 'admin@daedalus-project.io',
            password => 'this_is_a_Test_1234',
        }
    )
);

is( $login_admin_post_success->code(), 200, );

my $login_admin_post_success_json =
  decode_json( $login_admin_post_success->content );

is( $login_admin_post_success_json->{status},  1, );
is( $login_admin_post_success_json->{message}, 'Auth Successful.', );
is( $login_admin_post_success_json->{data}->{user}->{'e-mail'},
    'admin@daedalus-project.io', );

isnt( $login_admin_post_success_json->{data}->{user}->{api_key}, undef, );

is( $login_admin_post_success_json->{data}->{user}->{is_admin}, 1, );
isnt( $login_admin_post_success_json->{_hidden_data},
    undef, 'Admin users receive hidden data' );

done_testing();

DatabaseSetUpTearDown::delete_database();
