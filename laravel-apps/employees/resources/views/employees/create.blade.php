@extends('layouts.app')

@section('content')
<div class="container">
    <h1>Add Customer</h1>

    <form action="{{ route('employees.store') }}" method="POST">
        @csrf
        <div class="mb-3">
            <label for="customerName" class="form-label">Name *</label>
            <input type="text" class="form-control @error('customerName') is-invalid @enderror" 
                   id="customerName" name="customerName" value="{{ old('customerName') }}" required>
            @error('customerName')<span class="invalid-feedback">{{ $message }}</span>@enderror
        </div>

        <div class="mb-3">
            <label for="contactLastName" class="form-label">Last Name</label>
            <input type="text" class="form-control" id="contactLastName" name="contactLastName">
        </div>

        <div class="mb-3">
            <label for="contactFirstName" class="form-label">First Name</label>
            <input type="text" class="form-control" id="contactFirstName" name="contactFirstName">
        </div>

        <div class="mb-3">
            <label for="phone" class="form-label">Phone</label>
            <input type="text" class="form-control" id="phone" name="phone">
        </div>

        <div class="mb-3">
            <label for="city" class="form-label">City</label>
            <input type="text" class="form-control" id="city" name="city">
        </div>

        <div class="mb-3">
            <label for="country" class="form-label">Country</label>
            <input type="text" class="form-control" id="country" name="country">
        </div>

        <div class="mb-3">
            <label for="creditLimit" class="form-label">Credit Limit</label>
            <input type="number" step="0.01" class="form-control" id="creditLimit" name="creditLimit">
        </div>

        <button type="submit" class="btn btn-success">Save</button>
        <a href="{{ route('employees.index') }}" class="btn btn-secondary">Cancel</a>
    </form>
</div>
@endsection
