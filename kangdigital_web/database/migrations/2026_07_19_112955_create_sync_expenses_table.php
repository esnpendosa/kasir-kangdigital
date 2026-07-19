<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Tabel sync_expenses: Pengeluaran toko dari Android
     */
    public function up(): void
    {
        Schema::create('sync_expenses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('store_id')->constrained('stores')->onDelete('cascade');
            $table->unsignedBigInteger('remote_id');
            $table->string('category')->default('umum'); // gaji, sewa, listrik, operasional, dll
            $table->string('description')->nullable();
            $table->decimal('amount', 15, 2)->default(0);
            $table->string('payment_method')->default('cash');
            $table->string('cashier_username')->nullable();
            $table->timestamp('expense_date');
            $table->timestamp('synced_at')->nullable();
            $table->timestamps();

            $table->unique(['store_id', 'remote_id']);
            $table->index(['store_id', 'expense_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sync_expenses');
    }
};
