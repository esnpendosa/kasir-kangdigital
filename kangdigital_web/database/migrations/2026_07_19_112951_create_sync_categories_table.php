<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Tabel sync_categories: Kategori produk tersinkronisasi dari Android
     */
    public function up(): void
    {
        Schema::create('sync_categories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('store_id')->constrained('stores')->onDelete('cascade');
            $table->unsignedBigInteger('remote_id'); // ID di SQLite Android
            $table->string('name');
            $table->string('color')->nullable(); // warna hex untuk UI
            $table->string('icon')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamp('synced_at')->nullable();
            $table->timestamps();

            $table->unique(['store_id', 'remote_id']); // satu store, satu remote_id unik
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sync_categories');
    }
};
