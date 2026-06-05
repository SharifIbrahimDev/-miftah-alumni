<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\MonthlyContribution;
use App\Models\Project;
use App\Models\ProjectContribution;
use App\Models\Transaction;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class MiftahApiTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    private function createPresident(): User
    {
        return User::factory()->create([
            'role' => 'president',
            'gender' => 'male',
        ]);
    }

    private function createCashier(): User
    {
        return User::factory()->create([
            'role' => 'cashier',
            'gender' => 'female',
        ]);
    }

    private function createRegistrar(): User
    {
        return User::factory()->create([
            'role' => 'registrar',
            'gender' => 'male',
        ]);
    }

    private function createMember(): User
    {
        return User::factory()->create([
            'role' => 'member',
            'gender' => 'female',
        ]);
    }

    /** @test */
    public function public_can_register_and_login()
    {
        // 1. Register
        $registerData = [
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'phone' => '1234567890',
            'gender' => 'male',
            'password' => 'secret123',
        ];

        $response = $this->postJson('/api/register', $registerData);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'user' => ['id', 'name', 'email', 'phone', 'role', 'gender'],
                'token',
            ]);

        $this->assertDatabaseHas('users', [
            'email' => 'john@example.com',
            'role' => 'member', // default role
        ]);

        // 2. Login
        $loginData = [
            'email' => 'john@example.com',
            'password' => 'secret123',
        ];

        $loginResponse = $this->postJson('/api/login', $loginData);

        $loginResponse->assertStatus(200)
            ->assertJsonStructure([
                'user',
                'token',
            ]);
    }

    /** @test */
    public function authenticated_user_can_access_me_profile_and_logout()
    {
        $user = $this->createMember();

        // 1. Get Me
        $response = $this->actingAs($user)
            ->getJson('/api/me');

        $response->assertStatus(200)
            ->assertJsonPath('email', $user->email);

        // 2. Update Profile
        $updateData = [
            'name' => 'Updated Name',
            'phone' => '999999999',
        ];

        $profileResponse = $this->actingAs($user)
            ->putJson('/api/profile', $updateData);

        $profileResponse->assertStatus(200)
            ->assertJsonPath('name', 'Updated Name')
            ->assertJsonPath('phone', '999999999');

        // 3. Logout
        $logoutResponse = $this->actingAs($user)
            ->postJson('/api/logout');

        $logoutResponse->assertStatus(200)
            ->assertJson(['message' => 'Logged out successfully']);
    }

    /** @test */
    public function dashboard_returns_custom_stats_based_on_role()
    {
        $president = $this->createPresident();
        $member = $this->createMember();

        // President Dashboard
        $responsePres = $this->actingAs($president)->getJson('/api/dashboard');
        $responsePres->assertStatus(200)
            ->assertJsonStructure([
                'total_users',
                'total_collected_monthly',
                'total_project_raised',
                'total_expenses',
                'active_projects',
                'recent_monthly',
                'total_members',
                'recent_members',
            ]);

        // Member Dashboard
        $responseMem = $this->actingAs($member)->getJson('/api/dashboard');
        $responseMem->assertStatus(200)
            ->assertJsonStructure([
                'my_total_monthly',
                'my_total_project',
                'recent_my_activities',
                'available_projects',
            ]);
    }

    /** @test */
    public function user_management_is_restricted_to_president_and_registrar()
    {
        $president = $this->createPresident();
        $registrar = $this->createRegistrar();
        $member = $this->createMember();
        $otherUser = $this->createMember();

        // Member cannot list users
        $this->actingAs($member)
            ->getJson('/api/users')
            ->assertStatus(403);

        // President can list users
        $this->actingAs($president)
            ->getJson('/api/users')
            ->assertStatus(200);

        // Registrar can list users
        $this->actingAs($registrar)
            ->getJson('/api/users')
            ->assertStatus(200);

        // President can create user with role
        $createData = [
            'name' => 'New Cashier',
            'email' => 'cashier@example.com',
            'phone' => '111222333',
            'gender' => 'female',
            'role' => 'cashier',
            'password' => 'password123',
        ];

        $this->actingAs($president)
            ->postJson('/api/users', $createData)
            ->assertStatus(201)
            ->assertJsonPath('role', 'cashier');

        // Registrar can create user but cannot assign roles (restricted to member in controller unless President)
        $createDataReg = [
            'name' => 'New Member',
            'email' => 'newmem@example.com',
            'phone' => '444555666',
            'gender' => 'male',
            'role' => 'cashier', // will default to member
            'password' => 'password123',
        ];

        $this->actingAs($registrar)
            ->postJson('/api/users', $createDataReg)
            ->assertStatus(201)
            ->assertJsonPath('role', 'member');

        // Registrar/President can update and delete user
        $this->actingAs($registrar)
            ->putJson("/api/users/{$otherUser->id}", ['name' => 'Updated by Registrar'])
            ->assertStatus(200);

        $this->actingAs($president)
            ->deleteJson("/api/users/{$otherUser->id}")
            ->assertStatus(200);

        $this->assertSoftDeletedOrMissing($otherUser);
    }

    /** @test */
    public function monthly_contributions_are_restricted_to_president_and_cashier()
    {
        $president = $this->createPresident();
        $cashier = $this->createCashier();
        $registrar = $this->createRegistrar();
        $member = $this->createMember();

        // 1. Member/Registrar unauthorized
        $this->actingAs($member)
            ->getJson('/api/monthly-contributions')
            ->assertStatus(403);

        $this->actingAs($registrar)
            ->getJson('/api/monthly-contributions')
            ->assertStatus(403);

        // 2. Cashier/President authorized
        $this->actingAs($cashier)
            ->getJson('/api/monthly-contributions')
            ->assertStatus(200);

        $this->actingAs($president)
            ->getJson('/api/monthly-contributions')
            ->assertStatus(200);

        // 3. Record contribution
        $data = [
            'user_id' => $member->id,
            'amount' => 5000.00,
            'month' => '2026-05',
            'status' => 'paid',
        ];

        $res = $this->actingAs($cashier)
            ->postJson('/api/monthly-contributions', $data);

        $res->assertStatus(201);
        $contributionId = $res->json('id');

        // 4. Update contribution status
        $this->actingAs($cashier)
            ->putJson("/api/monthly-contributions/{$contributionId}", ['status' => 'unpaid'])
            ->assertStatus(200)
            ->assertJsonPath('status', 'unpaid');
    }

    /** @test */
    public function transactions_and_projects_creation_are_restricted_to_president_and_cashier()
    {
        $president = $this->createPresident();
        $cashier = $this->createCashier();
        $member = $this->createMember();

        // 1. Transactions list & record
        $this->actingAs($member)
            ->getJson('/api/transactions')
            ->assertStatus(403);

        $this->actingAs($cashier)
            ->getJson('/api/transactions')
            ->assertStatus(200);

        $transData = [
            'type' => 'debit',
            'amount' => 1500.00,
            'description' => 'Office stationery',
        ];

        $this->actingAs($cashier)
            ->postJson('/api/transactions', $transData)
            ->assertStatus(201);

        // 2. Project creation
        $this->actingAs($member)
            ->postJson('/api/projects', [
                'name' => 'Failed Project',
                'description' => 'Will fail',
                'target_amount' => 10000,
            ])
            ->assertStatus(403);

        $projectData = [
            'name' => 'Annual Gala Night',
            'description' => 'Funding for annual alumni dinner',
            'target_amount' => 500000,
        ];

        $resProject = $this->actingAs($president)
            ->postJson('/api/projects', $projectData);

        $resProject->assertStatus(201);
        $projectId = $resProject->json('id');

        // 3. Project contributions and index are open to members
        $this->actingAs($member)
            ->getJson('/api/projects')
            ->assertStatus(200);

        $contribData = [
            'project_id' => $projectId,
            'user_id' => $member->id,
            'amount' => 10000,
        ];

        $this->actingAs($member)
            ->postJson('/api/project-contributions', $contribData)
            ->assertStatus(201);
    }

    /** @test */
    public function member_can_access_own_contributions()
    {
        $member = $this->createMember();
        $president = $this->createPresident();

        // Setup some monthly and project contributions
        $monthly = MonthlyContribution::create([
            'user_id' => $member->id,
            'amount' => 2000,
            'month' => '2026-04',
            'status' => 'paid',
            'recorded_by' => $president->id,
        ]);

        $project = Project::create([
            'name' => 'Lab Equipment',
            'description' => 'Buy school computers',
            'target_amount' => 1000000,
            'created_by' => $president->id,
        ]);

        $projectContrib = ProjectContribution::create([
            'project_id' => $project->id,
            'user_id' => $member->id,
            'amount' => 5000,
            'recorded_by' => $president->id,
        ]);

        // Get my-contributions
        $this->actingAs($member)
            ->getJson('/api/my-contributions')
            ->assertStatus(200)
            ->assertJsonCount(1)
            ->assertJsonPath('0.id', $monthly->id);

        // Get my-project-contributions
        $this->actingAs($member)
            ->getJson('/api/my-project-contributions')
            ->assertStatus(200)
            ->assertJsonCount(1)
            ->assertJsonPath('0.id', $projectContrib->id);
    }

    private function assertSoftDeletedOrMissing($model)
    {
        $this->assertDatabaseMissing($model->getTable(), ['id' => $model->id]);
    }
}
