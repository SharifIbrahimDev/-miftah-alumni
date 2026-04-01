<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MonthlyContribution;
use App\Models\User;
use Illuminate\Http\Request;

class ContributionController extends Controller
{
    public function index(Request $request)
    {
        $query = MonthlyContribution::with(['user', 'recorder'])->latest();

        if ($request->has('user_id')) {
            $query->where('user_id', $request->user_id);
        }

        if ($request->has('month')) {
            $query->where('month', $request->month);
        }

        return response()->json($query->paginate(20));
    }

    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'amount' => 'required|numeric|min:0',
            'month' => 'required|string', // "2026-03"
            'status' => 'required|in:paid,unpaid',
        ]);

        $contribution = MonthlyContribution::create([
            'user_id' => $request->user_id,
            'amount' => $request->amount,
            'month' => $request->month,
            'status' => $request->status,
            'recorded_by' => $request->user()->id,
        ]);

        return response()->json($contribution->load(['user', 'recorder']), 201);
    }

    public function myContributions(Request $request)
    {
        $contributions = MonthlyContribution::with('recorder')
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get();

        return response()->json($contributions);
    }

    public function update(Request $request, MonthlyContribution $monthlyContribution)
    {
        $request->validate([
            'status' => 'required|in:paid,unpaid',
            'amount' => 'sometimes|numeric|min:0',
        ]);

        $monthlyContribution->update($request->only(['status', 'amount']));

        return response()->json($monthlyContribution->load(['user', 'recorder']));
    }
}
