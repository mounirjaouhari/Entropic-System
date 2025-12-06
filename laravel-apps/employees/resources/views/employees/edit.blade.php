@extends('layouts.app')

@section('content')
<div class="container">
    <h1>Edit Customer</h1>

    <form action="{{ route('employees.update', $customer) }}" method="POST">
        @csrf
        @method('PUT')
        <div class="mb-3">
            <label for="customerName" class="form-label">Name *</label>
            <input type="text" class="form-control @error('customerName') is-invalid @enderror" 
                   id="customerName" name="customerName" value="{{ old('customerName', $customer->customerName) }}" required>
            @error('customerName')<span class="invalid-feedback">{{ $message }}</span>@enderror
        </div>

        <div class="mb-3">
            <label for="city" class="form-label">City</label>
            <input type="text" class="form-control" id="city" name="city" value="{{ old('city', $customer->city) }}">
        </div>

        <div class="mb-3">
            <label for="country" class="form-label">Country</label>
            <input type="text" class="form-control" id="country" name="country" value="{{ old('country', $customer->country) }}">
        </div>

        <div class="mb-3">
            <label for="creditLimit" class="form-label">Credit Limit</label>
            <input type="number" step="0.01" class="form-control" id="creditLimit" name="creditLimit" value="{{ old('creditLimit', $customer->creditLimit) }}">
        </div>

        <button type="submit" class="btn btn-success">Update</button>
        <a href="{{ route('employees.show', $customer) }}" class="btn btn-secondary">Cancel</a>
    </form>
</div>
@endsection
