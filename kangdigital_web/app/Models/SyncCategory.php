<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SyncCategory extends Model
{
    protected $table = 'sync_categories';

    protected $fillable = [
        'store_id', 'remote_id', 'name', 'color', 'icon', 'is_active', 'synced_at',
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
