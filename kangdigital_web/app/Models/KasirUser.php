<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KasirUser extends Model
{
    use HasFactory;

    protected $fillable = [
        'username',
        'name',
        'email',
        'password',
        'role',
        'is_active',
        'license_id',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function license()
    {
        return $this->belongsTo(License::class);
    }
}
