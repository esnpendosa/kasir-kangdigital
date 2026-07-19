<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Tabel sync_transaction_items: Item-item dalam transaksi
     */
    public function up(): void
    {
        Schema::create('sync_transaction_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('transaction_id')->constrained('sync_transactions')->onDelete('cascade');
            $table->unsignedBigInteger('remote_product_id')->nullable();
            $table->string('product_name'); // disimpan snapshot nama saat transaksi
            $table->string('product_sku')->nullable();
            $table->decimal('price', 15, 2)->default(0); // harga saat transaksi
            $table->decimal('cost_price', 15, 2)->default(0);
            $table->integer('quantity')->default(1);
            $table->decimal('discount', 15, 2)->default(0);
            $table->decimal('subtotal', 15, 2)->default(0);
            $table->timestamps();

            $table->index('transaction_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sync_transaction_items');
    }
};
