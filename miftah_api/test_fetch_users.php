<?php
// test_fetch_users.php
$loginUrl = 'https://miftah-api.daynapp.com/api/login';
$usersUrl = 'https://miftah-api.daynapp.com/api/users';

// 1. Login to get a valid live token
$ch = curl_init($loginUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
    'email' => 'isjajere@gmail.com',
    'password' => '123456'
]));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json',
    'User-Agent: MiftahApp/1.0',
]);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

$loginResult = curl_exec($ch);
curl_close($ch);

$token = null;
if ($loginResult) {
    $loginData = json_decode($loginResult, true);
    if (isset($loginData['token'])) {
        $token = $loginData['token'];
        echo "Successfully logged in to live API! Token: $token\n\n";
    } else {
        echo "Failed to login. Maybe wrong password or user doesn't exist on live DB.\n";
        echo $loginResult . "\n";
        exit;
    }
}

// 2. Fetch users using the live token
$ch = curl_init($usersUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Accept: application/json',
    'X-Authorization: Bearer ' . $token,
    'Authorization: Bearer ' . $token,
    'User-Agent: MiftahApp/1.0',
]);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

$result = curl_exec($ch);
$httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

echo "Testing Fetch Users API ($usersUrl)...\n\n";
echo "Response Code: $httpcode\n";
if ($error) {
    echo "cURL Error: $error\n";
}
echo "Response Body:\n";
echo json_encode(json_decode($result), JSON_PRETTY_PRINT) ?: $result;
echo "\n";
