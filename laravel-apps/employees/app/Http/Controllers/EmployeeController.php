<?php

namespace App\Http\Controllers;

use App\Models\Customer;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Http\RedirectResponse;
use Illuminate\View\View;
use Symfony\Component\Process\Process;

class EmployeeController extends Controller
{
    /**
     * Display a listing of customers
     */
    public function index(): View
    {
        $customers = Customer::with('orders')->paginate(10);
        return view('employees.index', compact('customers'));
    }

    /**
     * Show the form for creating a new customer
     */
    public function create(): View
    {
        return view('employees.create');
    }

    /**
     * Store a newly created customer in storage
     */
    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'customerName' => 'required|string|max:100',
            'contactLastName' => 'nullable|string|max:50',
            'contactFirstName' => 'nullable|string|max:50',
            'phone' => 'nullable|string|max:50',
            'city' => 'nullable|string|max:100',
            'country' => 'nullable|string|max:100',
            'creditLimit' => 'nullable|numeric|min:0'
        ]);

        $customer = Customer::create($validated);

        // Send to Kafka via Python producer
        $this->produceToKafka($customer);

        return redirect()->route('employees.show', $customer->customerNumber)
            ->with('success', 'Customer created successfully.');
    }

    /**
     * Display the specified customer
     */
    public function show(Customer $customer): View
    {
        $customer->load('orders');
        return view('employees.show', compact('customer'));
    }

    /**
     * Show the form for editing the specified customer
     */
    public function edit(Customer $customer): View
    {
        return view('employees.edit', compact('customer'));
    }

    /**
     * Update the specified customer in storage
     */
    public function update(Request $request, Customer $customer): RedirectResponse
    {
        $validated = $request->validate([
            'customerName' => 'required|string|max:100',
            'contactLastName' => 'nullable|string|max:50',
            'contactFirstName' => 'nullable|string|max:50',
            'phone' => 'nullable|string|max:50',
            'city' => 'nullable|string|max:100',
            'country' => 'nullable|string|max:100',
            'creditLimit' => 'nullable|numeric|min:0'
        ]);

        $customer->update($validated);

        // Send to Kafka via Python producer
        $this->produceToKafka($customer, 'update');

        return redirect()->route('employees.show', $customer->customerNumber)
            ->with('success', 'Customer updated successfully.');
    }

    /**
     * Remove the specified customer from storage
     */
    public function destroy(Customer $customer): RedirectResponse
    {
        $customer->delete();

        return redirect()->route('employees.index')
            ->with('success', 'Customer deleted successfully.');
    }

    /**
     * Produce message to Kafka via Python script
     */
    private function produceToKafka(Customer $customer, string $action = 'create'): void
    {
        $message = [
            'action' => $action,
            'customerNumber' => $customer->customerNumber,
            'customerName' => $customer->customerName,
            'city' => $customer->city,
            'country' => $customer->country,
            'timestamp' => now()->toIso8601String()
        ];

        $process = new Process([
            'python3',
            base_path('../scripts/produce.py'),
            json_encode($message)
        ]);

        try {
            $process->run();
        } catch (\Exception $e) {
            \Log::warning('Kafka producer error: ' . $e->getMessage());
        }
    }
}
