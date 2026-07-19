<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CloudBackup extends Model
{
    protected $table = 'cloud_backups';

    protected $fillable = [
        'store_id', 'filename', 'original_filename', 'file_size',
        'file_hash', 'backup_type', 'app_version', 'device_id', 'notes',
    ];

    protected $casts = [
        'file_size' => 'integer',
    ];

    public function store()
    {
        return $this->belongsTo(Store::class);
    }

    /**
     * Get human-readable file size
     */
    public function getFileSizeFormattedAttribute(): string
    {
        $bytes = $this->file_size;
        if ($bytes < 1024) return $bytes . ' B';
        if ($bytes < 1048576) return round($bytes / 1024, 1) . ' KB';
        return round($bytes / 1048576, 2) . ' MB';
    }
}
