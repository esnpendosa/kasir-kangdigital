<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SyncTransactionItem extends Model
{
    protected $table = 'sync_transaction_items';

    protected $fillable = [
        'transaction_id', 'remote_product_id', 'product_name', 'product_sku',
        'price', 'cost_price', 'quantity', 'discount', 'subtotal',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'cost_price' => 'decimal:2',
        'discount' => 'decimal:2',
        'subtotal' => 'decimal:2',
    ];

    public function transaction()
    {
        return $this->belongsTo(SyncTransaction::class, 'transaction_id');
    }
}
