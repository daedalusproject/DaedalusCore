use strict;
use warnings;
use Test::More;

use Catalyst::Test 'Daedalus::Core';
use Daedalus::Core::Controller::REST;

use JSON::XS;
use HTTP::Request::Common;

my $registerGETcontent = get('/registernewuser');
ok( $registerGETcontent, qr /Method GET not implemented/ );

my $failed_because_no_auth = request(
    POST '/registernewuser',
    Content_Type => 'application/json',
    Content      => encode_json( {} ),
);

is( $failed_because_no_auth->code(), 403, );

my $failed_because_no_auth_json =
  decode_json( $failed_because_no_auth->content );

is( $failed_because_no_auth_json->{status}, 0, 'Status failed, no auth.' );
is(
    $failed_because_no_auth_json->{message},
    'Wrong e-mail or password.',
    'A valid e-mail password must be provided.'
);

my $failed_no_admin = request(
    POST '/registernewuser',
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

is( $failed_no_admin_json->{status}, 0, 'Status failed, not an andmin.' );
is(
    $failed_no_admin_json->{message},
    'You are not an admin user.',
    'Only admin uers are able to register new users.'
);

my $failed_no_data = request(
    POST '/registernewuser',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            auth => {
                email    => 'admin@daedalus-project.io',
                password => 'this_is_a_Test_1234',
            }
        }
    )
);

is( $failed_no_data->code(), 400, );

my $failed_no_data_json = decode_json( $failed_no_data->content );

is( $failed_no_data_json->{status}, 0, 'There is no user data.' );
is(
    $failed_no_data_json->{message},
    'Invalid user data.',
    'It is required user data to register a new user.'
);

my $failed_empty_data = request(
    POST '/registernewuser',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            auth => {
                email    => 'admin@daedalus-project.io',
                password => 'this_is_a_Test_1234',
            },
            new_user_data => {},
        }
    )
);

is( $failed_empty_data->code(), 400, );

my $failed_empty_data_json = decode_json( $failed_empty_data->content );

is( $failed_empty_data_json->{status}, 0, 'Nothing supplied' );
is(
    $failed_empty_data_json->{message},
    'No email supplied.No name supplied.No surname supplied.',
    'new_user_data is empty.'
);

my $failed_no_email_no_surname = request(
    POST '/registernewuser',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            auth => {
                email    => 'admin@daedalus-project.io',
                password => 'this_is_a_Test_1234',
            },
            new_user_data => {
                name => 'John',
            },
        }
    )
);

is( $failed_no_email_no_surname->code(), 400, );

my $failed_no_email_no_surname_json =
  decode_json( $failed_no_email_no_surname->content );

is( $failed_no_email_no_surname_json->{status}, 0, 'Only name is supplied' );
is(
    $failed_no_email_no_surname_json->{message},
    'No email supplied.No surname supplied.',
    'new_user_data only contains a name.'
);

my $failed_no_name_no_surname = request(
    POST '/registernewuser',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            auth => {
                email    => 'admin@daedalus-project.io',
                password => 'this_is_a_Test_1234',
            },
            new_user_data => {
                email => 'never@mind',
            },
        }
    )
);

is( $failed_no_name_no_surname->code(), 400, );

my $failed_no_name_no_surname_json =
  decode_json( $failed_no_name_no_surname->content );

is( $failed_no_name_no_surname_json->{status}, 0, 'Only email is supplied' );
is(
    $failed_no_name_no_surname_json->{message},
    'No name supplied.No surname supplied.',
    'new_user_data only contains an email.'
);

my $failed_invalid_email = request(
    POST '/registernewuser',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            auth => {
                email    => 'admin@daedalus-project.io',
                password => 'this_is_a_Test_1234',
            },
            new_user_data => {
                email   => 'invalidemail_example.com',
                name    => 'somename',
                surname => 'Some surname',

            },
        }
    )
);

is( $failed_invalid_email->code(), 400, );

my $failed_invalid_email_json = decode_json( $failed_invalid_email->content );

is( $failed_invalid_email_json->{status}, 0, 'E-mail is invalid.' );
is(
    $failed_invalid_email_json->{message},
    'Provided e-mail is invalid.',
    'A valid e-mail is required.'
);

my $failed_duplicated_email = request(
    POST '/registernewuser',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            auth => {
                email    => 'admin@daedalus-project.io',
                password => 'this_is_a_Test_1234',
            },
            new_user_data => {
                email   => 'notanadmin@daedalus-project.io',
                name    => 'somename',
                surname => 'Some surname',

            },
        }
    )
);

is( $failed_duplicated_email->code(), 400, );

my $failed_duplicated_email_json =
  decode_json( $failed_duplicated_email->content );

is( $failed_duplicated_email_json->{status}, 0, 'E-mail is duplicated.' );
is(
    $failed_duplicated_email_json->{message},
    'There already exists a user using this e-mail.',
    'A non previously stored e-mail is required.'
);

my $success_not_admin = request(
    POST '/registernewuser',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            auth => {
                email    => 'admin@daedalus-project.io',
                password => 'this_is_a_Test_1234',
            },
            new_user_data => {
                email   => 'othernotanadmin@daedalus-project.io',
                name    => 'Other',
                surname => 'Not Admin',
            },
        }
    )
);

is( $success_not_admin->code(), 200, );

my $success_not_admin_json = decode_json( $success_not_admin->content );

is( $success_not_admin_json->{status}, 1, 'User has been created.' );
is(
    $success_not_admin_json->{message},
    'User has been registered.',
    'User registered.'
);

my $success_admin = request(
    POST '/registernewuser',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            auth => {
                email    => 'yetanotheradmin@daedalus-project.io',
                password => 'Is a Password_1234',
            },
            new_user_data => {
                email   => 'otheradmin@daedalus-project.io',
                name    => 'Other',
                surname => 'Admin',
            },
        }
    )
);

is( $success_admin->code(), 200, );

my $success_admin_json = decode_json( $success_admin->content );

is( $success_admin_json->{status}, 1, 'User has been created.' );
is(
    $success_admin_json->{message},
    'User has been registered.',
    'User registered.'
);

my $success_no_admin_user = request(
    POST '/registernewuser',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            auth => {
                email    => 'yetanotheradmin@daedalus-project.io',
                password => 'Is a Password_1234',
            },
            new_user_data => {
                email   => 'othernoadmin@daedalus-project.io',
                name    => 'Other',
                surname => 'No Admin',
            },
        }
    )
);

is( $success_no_admin_user->code(), 200, );

my $success_no_admin_user_json = decode_json( $success_no_admin_user->content );

is( $success_no_admin_user_json->{status}, 1, 'User has been created.' );
is(
    $success_no_admin_user_json->{message},
    'User has been registered.',
    'User registered.'
);

my $success_superadmin_admin = request(
    POST '/registernewuser',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            auth => {
                email    => 'admin@daedalus-project.io',
                password => 'this_is_a_Test_1234',
            },
            new_user_data => {
                email   => 'anotheradmin@daedalus-project.io',
                name    => 'Another',
                surname => 'Admin',
            },
        }
    )
);

is( $success_superadmin_admin->code(), 200, );

my $success_superadmin_admin_json =
  decode_json( $success_superadmin_admin->content );

is( $success_superadmin_admin_json->{status}, 1, 'User has been created.' );
is(
    $success_superadmin_admin_json->{message},
    'User has been registered.',
    'User registered.'
);

is( $success_superadmin_admin_json->{status}, 1, 'User has been created.' );

# Only "daedalus_manager" users receives _hidden_data

is(
    $success_superadmin_admin_json->{_hidden_data}->{user}->{email},
    'anotheradmin@daedalus-project.io',
);

my $inactive_user_cant_login = request(
    POST '/user/login',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            auth => {
                email    => 'inactiveuser@daedalus-project.io',
                password => 'N0b0d7car5_;___',
            },
        }
    )
);

is( $inactive_user_cant_login->code(), 403, );

my $inactive_user_cant_login_json =
  decode_json( $inactive_user_cant_login->content );

is( $inactive_user_cant_login_json->{status},  0, );
is( $inactive_user_cant_login_json->{message}, 'Wrong e-mail or password.', );

done_testing();
