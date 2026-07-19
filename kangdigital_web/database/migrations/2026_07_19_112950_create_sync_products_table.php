<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Tabel sync_products: Produk dari Android tersinkronisasi ke server
     */
    public function up(): void
    {
        Schema::create('sync_products', function (Blueprint $table) {
            $table->id();
            $table->foreignId('store_id')->constrained('stores')->onDelete('cascade');
            $table->unsignedBigInteger('remote_id'); // ID produk di SQLite Android
            $table->unsignedBigInteger('remote_category_id')->nullable(); // ID kategori di Android
            $table->string('name');
            $table->string('sku')->nullable();
            $table->string('barcode')->nullable();
            $table->decimal('price', 15, 2)->default(0);
            $table->decimal('cost_price', 15, 2)->default(0);
            $table->integer('stock')->default(0);
            $table->integer('min_stock')->default(0);
            $table->string('unit')->default('pcs'); // pcs, kg, liter, dll
            $table->text('description')->nullable();
            $table->string('image_url')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamp('synced_at')->nullable();
            $table->timestamps();

            $table->unique(['store_id', 'remote_id']);
            $table->index(['store_id', 'barcode']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sync_products');
    }
};
