<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class PasswordResetTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    private function createUser(): User
    {
        return User::factory()->create([
            'email' => 'test@example.com',
            'password' => Hash::make('oldpassword'),
        ]);
    }

    /** @test */
    public function user_can_request_forgot_password_otp()
    {
        $user = $this->createUser();

        $response = $this->postJson('/api/forgot-password', [
            'email' => $user->email,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'OTP generated successfully. Check your email (or server logs) for the code.'
            ]);

        $this->assertTrue(Cache::has('otp_' . $user->email));
        $this->assertEquals(6, strlen(Cache::get('otp_' . $user->email)));
    }

    /** @test */
    public function forgot_password_requires_valid_email()
    {
        $response = $this->postJson('/api/forgot-password', [
            'email' => 'nonexistent@example.com',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }

    /** @test */
    public function user_can_verify_valid_otp()
    {
        $user = $this->createUser();
        $otp = '123456';
        Cache::put('otp_' . $user->email, $otp, now()->addMinutes(15));

        $response = $this->postJson('/api/verify-otp', [
            'email' => $user->email,
            'otp' => $otp,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'OTP verified successfully'
            ]);
    }

    /** @test */
    public function verifying_invalid_otp_fails()
    {
        $user = $this->createUser();
        Cache::put('otp_' . $user->email, '123456', now()->addMinutes(15));

        $response = $this->postJson('/api/verify-otp', [
            'email' => $user->email,
            'otp' => '654321', // wrong OTP
        ]);

        $response->assertStatus(400)
            ->assertJson([
                'message' => 'Invalid or expired OTP'
            ]);
    }

    /** @test */
    public function user_can_reset_password_with_valid_otp()
    {
        $user = $this->createUser();
        $otp = '123456';
        Cache::put('otp_' . $user->email, $otp, now()->addMinutes(15));

        $response = $this->postJson('/api/reset-password', [
            'email' => $user->email,
            'otp' => $otp,
            'password' => 'newpassword123',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'Password reset successfully'
            ]);

        // Check if password was actually changed
        $this->assertTrue(Hash::check('newpassword123', $user->fresh()->password));

        // Check if OTP was cleared from cache
        $this->assertFalse(Cache::has('otp_' . $user->email));
    }

    /** @test */
    public function resetting_password_with_invalid_otp_fails()
    {
        $user = $this->createUser();
        Cache::put('otp_' . $user->email, '123456', now()->addMinutes(15));

        $response = $this->postJson('/api/reset-password', [
            'email' => $user->email,
            'otp' => 'wrongotp',
            'password' => 'newpassword123',
        ]);

        $response->assertStatus(422) // size:6 validation failure
            ->assertJsonValidationErrors(['otp']);

        // Now with size 6 but wrong
        $response = $this->postJson('/api/reset-password', [
            'email' => $user->email,
            'otp' => '654321',
            'password' => 'newpassword123',
        ]);

        $response->assertStatus(400)
            ->assertJson([
                'message' => 'Invalid or expired OTP'
            ]);

        // Password should remain oldpassword
        $this->assertTrue(Hash::check('oldpassword', $user->fresh()->password));
    }
}
