<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Store extends Model
{
    use HasFactory;

    protected $fillable = [
        'license_id',
        'store_name',
        'store_code',
        'address',
        'phone',
        'email',
        'currency',
        'currency_symbol',
        'receipt_footer',
        'is_active',
        'last_synced_at',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'last_synced_at' => 'datetime',
    ];

    public function license()
    {
        return $this->belongsTo(License::class);
    }

    public function products()
    {
        return $this->hasMany(SyncProduct::class);
    }

    public function categories()
    {
        return $this->hasMany(SyncCategory::class);
    }

    public function customers()
    {
        return $this->hasMany(SyncCustomer::class);
    }

    public function transactions()
    {
        return $this->hasMany(SyncTransaction::class);
    }

    public function expenses()
    {
        return $this->hasMany(SyncExpense::class);
    }

    public function suppliers()
    {
        return $this->hasMany(SyncSupplier::class);
    }

    public function backups()
    {
        return $this->hasMany(CloudBackup::class);
    }
}
