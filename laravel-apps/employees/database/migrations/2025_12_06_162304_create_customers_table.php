<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('customers', function (Blueprint $table) {
            $table->id('customerNumber');
            $table->string('customerName');
            $table->string('contactLastName')->nullable();
            $table->string('contactFirstName')->nullable();
            $table->string('phone')->nullable();
            $table->string('addressLine1')->nullable();
            $table->string('addressLine2')->nullable();
            $table->string('city')->nullable();
            $table->string('state')->nullable();
            $table->string('postalCode')->nullable();
            $table->string('country')->nullable();
            $table->unsignedBigInteger('salesRepEmployeeNumber')->nullable();
            $table->decimal('creditLimit', 10, 2)->nullable();
            $table->timestamps();
            $table->index('customerName');
        });
    }

    public function down(): void {
        Schema::dropIfExists('customers');
    }
};
