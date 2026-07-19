<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SyncProduct extends Model
{
    protected $table = 'sync_products';

    protected $fillable = [
        'store_id', 'remote_id', 'remote_category_id', 'name', 'sku', 'barcode',
        'price', 'cost_price', 'stock', 'min_stock', 'unit', 'description',
        'image_url', 'is_active', 'synced_at',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'cost_price' => 'decimal:2',
        'is_active' => 'boolean',
        'synced_at' => 'datetime',
    ];

    public function store()
    {
        return $this->belongsTo(Store::class);
    }
}
