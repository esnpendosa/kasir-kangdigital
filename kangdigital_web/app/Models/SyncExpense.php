<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SyncExpense extends Model
{
    protected $table = 'sync_expenses';

    protected $fillable = [
        'store_id', 'remote_id', 'category', 'description', 'amount',
        'payment_method', 'cashier_username', 'expense_date', 'synced_at',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'expense_date' => 'datetime',
        'synced_at' => 'datetime',
    ];

    public function store()
    {
        return $this->belongsTo(Store::class);
    }
}
