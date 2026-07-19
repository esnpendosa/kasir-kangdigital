<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Tabel cloud_backups: Metadata backup file yang diupload dari Android
     * File fisik disimpan di storage/app/backups/{store_id}/
     * Compatible dengan shared hosting hPanel (tidak butuh queue worker)
     */
    public function up(): void
    {
        Schema::create('cloud_backups', function (Blueprint $table) {
            $table->id();
            $table->foreignId('store_id')->constrained('stores')->onDelete('cascade');
            $table->string('filename'); // nama file di server
            $table->string('original_filename'); // nama file asli dari Android
            $table->unsignedBigInteger('file_size')->default(0); // bytes
            $table->string('file_hash')->nullable(); // MD5 untuk verifikasi integritas
            $table->string('backup_type')->default('full'); // full, incremental
            $table->string('app_version')->nullable(); // versi app saat backup
            $table->string('device_id')->nullable(); // ID perangkat
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->index('store_id');
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cloud_backups');
    }
};
