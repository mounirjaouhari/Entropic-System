@extends('layouts.app')

@section('content')
<div class="container">
    <h1>{{ $customer->customerName }}</h1>

    <div class="card mb-4">
        <div class="card-body">
            <p><strong>ID:</strong> {{ $customer->customerNumber }}</p>
            <p><strong>Contact:</strong> {{ $customer->contactFirstName }} {{ $customer->contactLastName }}</p>
            <p><strong>Phone:</strong> {{ $customer->phone }}</p>
            <p><strong>Address:</strong> {{ $customer->addressLine1 }}, {{ $customer->city }}, {{ $customer->country }}</p>
            <p><strong>Credit Limit:</strong> ${{ number_format($customer->creditLimit, 2) }}</p>
        </div>
    </div>

    <h3>Orders ({{ $customer->orders->count() }})</h3>
    <table class="table table-striped">
        <thead>
            <tr>
                <th>Order #</th>
                <th>Date</th>
                <th>Status</th>
                <th>Comments</th>
            </tr>
        </thead>
        <tbody>
            @forelse($customer->orders as $order)
            <tr>
                <td>{{ $order->orderNumber }}</td>
                <td>{{ $order->orderDate->format('Y-m-d') }}</td>
                <td><span class="badge bg-secondary">{{ $order->status }}</span></td>
                <td>{{ $order->comments }}</td>
            </tr>
            @empty
            <tr>
                <td colspan="4" class="text-center">No orders</td>
            </tr>
            @endforelse
        </tbody>
    </table>

    <div>
        <a href="{{ route('employees.edit', $customer) }}" class="btn btn-warning">Edit</a>
        <a href="{{ route('employees.index') }}" class="btn btn-secondary">Back</a>
    </div>
</div>
@endsection
