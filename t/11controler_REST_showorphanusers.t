use strict;
use warnings;
use Test::More;

use Catalyst::Test 'Daedalus::Core';
use Daedalus::Core::Controller::REST;

use JSON::XS;
use HTTP::Request::Common;

my $endpoint = "showorphanusers";

my $show_orphan_users_GET_content = get($endpoint);
ok( $show_orphan_users_GET_content, qr /Method GET not implemented/ );

my $failed_because_no_auth = request(
    POST $endpoint,
    Content_Type => 'application/json',
    Content      => encode_json( {} ),
);

is( $failed_because_no_auth->code(), 403, );

my $failed_because_no_auth_json =
  decode_json( $failed_because_no_auth->content );

is_deeply(
    $failed_because_no_auth_json,
    {
        'status'  => '0',
        'message' => 'Wrong e-mail or password.',
    }
);

my $failed_no_admin = request(
    POST $endpoint,
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            auth => {
                email    => 'notanadmin@daedalus-project.io',
                password => 'Test_is_th1s_123',
            }
        }
    )
);

is( $failed_no_admin->code(), 403, );

my $failed_no_admin_json = decode_json( $failed_no_admin->content );

is( $failed_no_admin_json->{status},  0, );
is( $failed_no_admin_json->{message}, 'You are not an admin user.', );

# yetanotheradmin@daedalus-project.io has registered two users for the time being, these users have not confirmed its registration yet

my $yetanotheradmin_two_user = request(
    POST $endpoint,
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            auth => {
                email    => 'yetanotheradmin@daedalus-project.io',
                password => 'Is a Password_1234',
            }
        }
    )
);

is( $yetanotheradmin_two_user->code(), 200, );

my $yetanotheradmin_two_user_json =
  decode_json( $yetanotheradmin_two_user->content );

is( $yetanotheradmin_two_user_json->{status}, 1, 'Status success, admin.' );
is( keys %{ $admin_admin_one_user_json->{orfan_users} },
    2, 'There are 2 orfan users' );

my $anotheradmin_admin_zero_users = request(
    POST $endpoint,
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            auth => {
                email    => 'adminagain@daedalus-project.io',
                password => '__:___Password_1234',
            }
        }
    )
);

is( $anotheradmin_admin_zero_users->code(), 200, );

my $anotheradmin_admin_zero_users_json =
  decode_json( $anotheradmin_admin_zero_users->content );

is( $anotheradmin_admin_zero_users_json->{status},
    1, 'Status success, andmin.' );
is( keys %{ $anotheradmin_admin_zero_users_json->{registered_users} },
    0, 'adminagain@daedalus-project.io has 0 users registered' );

done_testing();
