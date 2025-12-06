<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('orders', function (Blueprint $table) {
            $table->id('orderNumber');
            $table->date('orderDate');
            $table->date('requiredDate')->nullable();
            $table->date('shippedDate')->nullable();
            $table->string('status')->nullable();
            $table->text('comments')->nullable();
            $table->unsignedBigInteger('customerNumber');
            $table->timestamps();
            $table->foreign('customerNumber')->references('customerNumber')->on('customers')->onDelete('cascade');
            $table->index('customerNumber');
        });
    }

    public function down(): void {
        Schema::dropIfExists('orders');
    }
};
