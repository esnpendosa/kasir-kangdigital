<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SyncCustomer extends Model
{
    protected $table = 'sync_customers';

    protected $fillable = [
        'store_id', 'remote_id', 'name', 'phone', 'email', 'address',
        'points', 'total_spent', 'synced_at',
    ];

    protected $casts = [
        'total_spent' => 'decimal:2',
        'synced_at' => 'datetime',
    ];

    public function store()
    {
        return $this->belongsTo(Store::class);
    }
}
