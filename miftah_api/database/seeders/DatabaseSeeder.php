<?php

namespace Database\Seeders;

use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        \App\Models\User::factory()->create([
            'name' => 'Association President',
            'email' => 'president@miftah.org',
            'password' => \Illuminate\Support\Facades\Hash::make('password'),
            'role' => 'president',
            'gender' => 'male',
        ]);
    }
}
