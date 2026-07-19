<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SyncTransaction extends Model
{
    protected $table = 'sync_transactions';

    protected $fillable = [
        'store_id', 'remote_id', 'remote_customer_id', 'invoice_no', 'cashier_username',
        'subtotal', 'discount_amount', 'tax_amount', 'total', 'paid_amount',
        'change_amount', 'payment_method', 'status', 'notes', 'sold_at', 'synced_at',
    ];

    protected $casts = [
        'subtotal' => 'decimal:2',
        'discount_amount' => 'decimal:2',
        'tax_amount' => 'decimal:2',
        'total' => 'decimal:2',
        'paid_amount' => 'decimal:2',
        'change_amount' => 'decimal:2',
        'sold_at' => 'datetime',
        'synced_at' => 'datetime',
    ];

    public function store()
    {
        return $this->belongsTo(Store::class);
    }

    public function items()
    {
        return $this->hasMany(SyncTransactionItem::class, 'transaction_id');
    }
}
