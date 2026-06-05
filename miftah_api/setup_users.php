<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Hash;

$roles = ['president', 'cashier', 'registrar', 'member'];
$password = 'password123';

echo "Setting up users...\n\n";

foreach ($roles as $role) {
    $email = "{$role}@example.com";
    $user = User::where('email', $email)->first();
    
    if (!$user) {
        $user = User::create([
            'name' => ucfirst($role) . ' User',
            'email' => $email,
            'phone' => '1234567890',
            'gender' => 'male',
            'password' => Hash::make($password),
            'role' => $role,
        ]);
        echo "Created User: {$email}\n";
    } else {
        echo "User already exists: {$email}\n";
    }

    // Login the user to get a token
    $token = $user->createToken('auth_token')->plainTextToken;
    echo "Role: {$role}\n";
    echo "Email: {$email}\n";
    echo "Password: {$password}\n";
    echo "Token: {$token}\n\n";
}
