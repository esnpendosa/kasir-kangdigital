<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('licenses', function (Blueprint $table) {
            $table->integer('device_limit')->default(1)->after('platform');
            $table->integer('price')->default(0)->after('device_limit');
            $table->string('duration_type')->default('1_year')->after('price'); // 1_month, 1_year, lifetime
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('licenses', function (Blueprint $table) {
            $table->dropColumn(['device_limit', 'price', 'duration_type']);
        });
    }
};
