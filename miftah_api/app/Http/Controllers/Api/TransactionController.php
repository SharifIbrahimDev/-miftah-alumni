<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\Request;

class TransactionController extends Controller
{
    public function index()
    {
        return response()->json(Transaction::with('recorder')->latest()->paginate(20));
    }

    public function store(Request $request)
    {
        $request->validate([
            'type' => 'required|in:credit,debit',
            'amount' => 'required|numeric|min:0',
            'description' => 'required|string|max:255',
        ]);

        $transaction = Transaction::create([
            'type' => $request->type,
            'amount' => $request->amount,
            'description' => $request->description,
            'recorded_by' => $request->user()->id,
        ]);

        return response()->json($transaction->load('recorder'), 201);
    }
}
