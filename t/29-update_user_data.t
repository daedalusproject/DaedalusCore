use strict;
use warnings;
use Test::More;

use Catalyst::Test 'Daedalus::Core';
use Daedalus::Core::Controller::REST;

use JSON::XS;
use MIME::Base64;
use HTTP::Request::Common qw(GET PUT POST DELETE);

my $endpoint = '/user';

my $failed_because_no_auth_token =
  request( PUT $endpoint, Content_Type => 'application/json', );

is( $failed_because_no_auth_token->code(), 400, );

my $failed_because_no_auth_token_json =
  decode_json( $failed_because_no_auth_token->content );

is( $failed_because_no_auth_token_json->{status}, 0, );
is(
    $failed_because_no_auth_token_json->{message},
    "No session token provided.",
);

my $marvin_login_success = request(
    POST '/user/login',
    Content_Type => 'application/json',
    Content      => encode_json(
        {
            'e-mail' => 'marvin@megashops.com',
            password => '1_HAT3_MY_L1F3',
        }
    )
);

is( $marvin_login_success->code(), 200, );

my $marvin_login_success_json = decode_json( $marvin_login_success->content );

is( $marvin_login_success_json->{status}, 1, );

my $marvin_login_success_token =
  $marvin_login_success_json->{data}->{session_token};

my $marvin_authorization_basic =
  MIME::Base64::encode( "session_token:$marvin_login_success_token", '' );

my $failed_no_token =
  request( PUT $endpoint, Content_Type => 'application/json', );

is( $failed_no_token->code(), 400, );

my $failed_no_token_json = decode_json( $failed_no_token->content );

my $failed_no_data = request(
    PUT $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $marvin_authorization_basic",
);

is( $failed_no_data->code(), 400, );

my $failed_no_data_json = decode_json( $failed_no_data->content );

is( $failed_no_data_json->{status},  0, );
is( $failed_no_data_json->{message}, 'Nothing changed.', );

my $failed_update_wrong_data = request(
    PUT $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $marvin_authorization_basic",
    Content       => encode_json(
        {
            mac_address => 'fe80::fdc2:8f3f:dee8:ee87/64',
        }
      )

);

is( $failed_update_wrong_data->code(), 400, );

my $failed_update_wrong_data_json =
  decode_json( $failed_update_wrong_data->content );

is( $failed_update_wrong_data_json->{status},  0, );
is( $failed_update_wrong_data_json->{message}, 'Nothing changed.', );

my $update_name = request(
    PUT $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $marvin_authorization_basic",
    Content       => encode_json(
        {
            name => 'Alexa',
        }
      )

);

is( $update_name->code(), 200, );

my $update_name_json = decode_json( $update_name->content );

is( $update_name_json->{status},  1, );
is( $update_name_json->{message}, 'Data updated: name.', );

my $check_name = request(
    GET $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $marvin_authorization_basic",
);

is( $check_name->code(), 200, );

my $check_name_json = decode_json( $check_name->content );

is( $check_name_json->{status},  1, );
is( $check_name_json->{message}, undef, );

is( $check_name_json->{data}->{user}->{name}, 'Alexa', );

my $update_name_and_surname = request(
    PUT $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $marvin_authorization_basic",
    Content       => encode_json(
        {
            name    => 'Felix',
            surname => 'Rodriguez',
        }
      )

);

is( $update_name_and_surname->code(), 200, );

my $update_name_and_surname_json =
  decode_json( $update_name_and_surname->content );

is( $update_name_and_surname_json->{status},  1, );
is( $update_name_and_surname_json->{message}, 'Data updated: name, surname.', );

my $check_name_and_surname = request(
    GET $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $marvin_authorization_basic",
);

is( $check_name_and_surname->code(), 200, );

my $check_name_and_surname_json =
  decode_json( $check_name_and_surname->content );

is( $check_name_and_surname_json->{status},  1, );
is( $check_name_and_surname_json->{message}, undef, );

is( $check_name_and_surname_json->{data}->{user}->{name}, 'Felix', );

is( $check_name_and_surname_json->{data}->{user}->{surname}, 'Rogriguez', );

my $update_invalidvalid_number = request(
    PUT $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $marvin_authorization_basic",
    Content       => encode_json(
        {
            phone_number => '+3496352534478',
        }
    )
);

is( $update_invalidvalid_number->code(), 400, );

my $update_invalidvalid_number_json =
  decode_json( $update_invalidvalid_number->content );

is( $update_invalidvalid_number_json->{status},  0, );
is( $update_invalidvalid_number_json->{message}, 'Invalid phone_number.', );

$check_name_and_surname = request(
    GET $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $marvin_authorization_basic",
);

is( $check_name_and_surname->code(), 200, );

$check_name_and_surname_json = decode_json( $check_name_and_surname->content );

is( $check_name_and_surname_json->{status},  1, );
is( $check_name_and_surname_json->{message}, undef, );

is( $check_name_and_surname_json->{data}->{user}->{name}, 'Felix', );

is( $check_name_and_surname_json->{data}->{user}->{surname}, 'Rogriguez', );

my $update_valid_number = request(
    PUT $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $marvin_authorization_basic",
    Content       => encode_json(
        {
            phone_number => '+34963525478',
        }
    )
);

is( $update_valid_number->code(), 200, );

my $update_valid_number_json = decode_json( $update_valid_number->content );

is( $update_valid_number_json->{status},  1, );
is( $update_valid_number_json->{message}, 'Data updated: phone_number.', );

my $check_name_surname_phone = request(
    GET $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $marvin_authorization_basic",
);

is( $check_name_surname_phone->code(), 200, );

my $check_name_surname_phone_json =
  decode_json( $check_name_surname_phone->content );

is( $check_name_surname_phone_json->{status},  1, );
is( $check_name_surname_phone_json->{message}, undef, );

is( $check_name_surname_phone_json->{data}->{user}->{name}, 'Felix', );

is( $check_name_surname_phone_json->{data}->{user}->{surname}, 'Rogriguez', );

is( $check_name_surname_phone_json->{data}->{user}->{phone_number},
    '+34963525478', );

my $update_all_data = request(
    PUT $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $marvin_authorization_basic",
    Content       => encode_json(
        {
            name         => 'Curro',
            surname      => 'Jimenez',
            phone_number => '+34962525478',
        }
    )
);

is( $update_all_data->code(), 200, );

my $update_all_data_json = decode_json( $update_all_data->content );

is( $update_all_data_json->{status}, 1, );
is(
    $update_all_data_json->{message},
    'Data updated: name, phone_number, surname.',
);

my $check_all_data = request(
    GET $endpoint,
    Content_Type  => 'application/json',
    Authorization => "Basic $marvin_authorization_basic",
);

is( $check_all_data->code(), 200, );

my $check_all_data_json = decode_json( $check_all_data->content );

is( $check_all_data_json->{status},  1, );
is( $check_all_data_json->{message}, undef, );

is( $check_all_data_json->{data}->{user}->{name}, 'Curro', );

is( $check_all_data_json->{data}->{user}->{surname}, 'Jimenez', );

is( $check_all_data_json->{data}->{user}->{phone_number}, '+34962525478', );

done_testing();
