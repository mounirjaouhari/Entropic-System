@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row mb-4">
        <div class="col-md-8">
            <h1>Customers</h1>
        </div>
        <div class="col-md-4 text-end">
            <a href="{{ route('employees.create') }}" class="btn btn-primary">Add Customer</a>
        </div>
    </div>

    @if(session('success'))
        <div class="alert alert-success">{{ session('success') }}</div>
    @endif

    <table class="table table-striped">
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>City</th>
                <th>Country</th>
                <th>Credit Limit</th>
                <th>Orders</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            @foreach($customers as $customer)
            <tr>
                <td>{{ $customer->customerNumber }}</td>
                <td>{{ $customer->customerName }}</td>
                <td>{{ $customer->city }}</td>
                <td>{{ $customer->country }}</td>
                <td>${{ number_format($customer->creditLimit, 2) }}</td>
                <td><span class="badge bg-info">{{ $customer->orders->count() }}</span></td>
                <td>
                    <a href="{{ route('employees.show', $customer) }}" class="btn btn-sm btn-info">View</a>
                    <a href="{{ route('employees.edit', $customer) }}" class="btn btn-sm btn-warning">Edit</a>
                    <form action="{{ route('employees.destroy', $customer) }}" method="POST" style="display:inline;">
                        @csrf
                        @method('DELETE')
                        <button class="btn btn-sm btn-danger">Delete</button>
                    </form>
                </td>
            </tr>
            @endforeach
        </tbody>
    </table>

    {{ $customers->links() }}
</div>
@endsection
