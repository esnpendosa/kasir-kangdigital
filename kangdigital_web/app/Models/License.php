<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class License extends Model
{
    use HasFactory;

    protected $fillable = [
        'license_key',
        'device_id',
        'app_version',
        'platform',
        'device_limit',
        'price',
        'duration_type',
        'status',
        'activated_at',
        'expires_at',
        'token',
    ];

    protected $casts = [
        'activated_at' => 'datetime',
        'expires_at' => 'datetime',
    ];

    public function kasirUsers()
    {
        return $this->hasMany(KasirUser::class);
    }

    public function stores()
    {
        return $this->hasMany(Store::class);
    }
}
