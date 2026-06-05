<?php
// test_register_live.php
// This script simulates the exact request sent by the Flutter mobile app's Register Page
// It hits the remote API server to see where the data goes.

$url = 'https://miftah-api.daynapp.com/api/register';

$data = [
    'name' => 'Test Live Registration',
    'email' => 'testlive_' . time() . '@example.com',
    'phone' => '09012345678',
    'gender' => 'female',
    'password' => 'password123',
    'password_confirmation' => 'password123'
];

$ch = curl_init($url);
$payload = json_encode($data);

curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLINFO_HEADER_OUT, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json',
    'User-Agent: MiftahApp/1.0',
]);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

$result = curl_exec($ch);
$httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

echo "Testing Register Page submission to Live API ($url)...\n\n";
echo "Submitted Data:\n";
print_r($data);
echo "\nResponse Code: $httpcode\n";
if ($error) {
    echo "cURL Error: $error\n";
}
echo "Response Body:\n";
echo $result;
echo "\n";
