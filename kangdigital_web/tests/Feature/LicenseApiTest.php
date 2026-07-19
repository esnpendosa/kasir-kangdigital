<?php

namespace Tests\Feature;

use App\Models\License;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class LicenseApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_activate_yearly_license_success()
    {
        $license = License::create([
            'license_key' => 'UMKM-TEST-YEARLY',
            'device_limit' => 1,
            'price' => 249000,
            'duration_type' => '1_year',
            'status' => 'inactive',
            'expires_at' => now()->addYear(),
        ]);

        $response = $this->postJson('/api/license/activate', [
            'license_key' => 'UMKM-TEST-YEARLY',
            'device_id' => 'device-uuid-1',
            'app_version' => '1.0.0',
            'platform' => 'android',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Aktivasi berhasil.',
            ]);

        $this->assertDatabaseHas('licenses', [
            'license_key' => 'UMKM-TEST-YEARLY',
            'status' => 'active',
            'device_id' => 'device-uuid-1',
        ]);
    }

    public function test_activate_lifetime_license_has_null_expires_at()
    {
        $license = License::create([
            'license_key' => 'UMKM-TEST-LIFETIME',
            'device_limit' => 5,
            'price' => 499000,
            'duration_type' => 'lifetime',
            'status' => 'inactive',
            'expires_at' => null,
        ]);

        $response = $this->postJson('/api/license/activate', [
            'license_key' => 'UMKM-TEST-LIFETIME',
            'device_id' => 'device-uuid-1',
            'app_version' => '1.0.0',
            'platform' => 'android',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'license_key' => 'UMKM-TEST-LIFETIME',
                    'expires_at' => null,
                ]
            ]);

        $license->refresh();
        $this->assertNull($license->expires_at);
        $this->assertEquals('active', $license->status);
    }

    public function test_check_lifetime_license_success()
    {
        $license = License::create([
            'license_key' => 'UMKM-TEST-LIFETIME',
            'device_limit' => 5,
            'price' => 499000,
            'duration_type' => 'lifetime',
            'status' => 'active',
            'activated_at' => now(),
            'expires_at' => null,
            'token' => 'mock-token-lifetime',
            'device_id' => 'device-uuid-1',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer mock-token-lifetime',
        ])->postJson('/api/license/check', [
            'device_id' => 'device-uuid-1',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'license_key' => 'UMKM-TEST-LIFETIME',
                    'expires_at' => null,
                    'status' => 'active',
                ]
            ]);
    }

    public function test_refresh_lifetime_license_success()
    {
        $license = License::create([
            'license_key' => 'UMKM-TEST-LIFETIME',
            'device_limit' => 5,
            'price' => 499000,
            'duration_type' => 'lifetime',
            'status' => 'active',
            'activated_at' => now(),
            'expires_at' => null,
            'token' => 'mock-token-lifetime',
            'device_id' => 'device-uuid-1',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer mock-token-lifetime',
        ])->postJson('/api/license/refresh');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'license_key' => 'UMKM-TEST-LIFETIME',
                    'expires_at' => null,
                ]
            ]);

        $this->assertNotEquals('mock-token-lifetime', $response->json('data.token'));
    }
}
