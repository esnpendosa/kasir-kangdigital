<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SyncSupplier extends Model
{
    protected $table = 'sync_suppliers';

    protected $fillable = [
        'store_id', 'remote_id', 'name', 'phone', 'email', 'address',
        'contact_person', 'notes', 'is_active', 'synced_at',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'synced_at' => 'datetime',
    ];

    public function store()
    {
        return $this->belongsTo(Store::class);
    }
}
