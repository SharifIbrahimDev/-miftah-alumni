<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Project;
use App\Models\ProjectContribution;
use Illuminate\Http\Request;

class ProjectController extends Controller
{
    public function index()
    {
        return response()->json(Project::with(['creator'])->withSum('contributions', 'amount')->latest()->get());
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'required|string',
            'target_amount' => 'required|numeric|min:0',
        ]);

        $project = Project::create([
            'name' => $request->name,
            'description' => $request->description,
            'target_amount' => $request->target_amount,
            'created_by' => $request->user()->id,
        ]);

        return response()->json($project->load('creator'), 201);
    }

    public function recordContribution(Request $request)
    {
        $request->validate([
            'project_id' => 'required|exists:projects,id',
            'user_id' => 'required|exists:users,id',
            'amount' => 'required|numeric|min:0',
        ]);

        $contribution = ProjectContribution::create([
            'project_id' => $request->project_id,
            'user_id' => $request->user_id,
            'amount' => $request->amount,
            'recorded_by' => $request->user()->id,
        ]);

        return response()->json($contribution->load(['project', 'user', 'recorder']), 201);
    }

    public function myContributions(Request $request)
    {
        $contributions = ProjectContribution::with(['project', 'recorder'])
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get();

        return response()->json($contributions);
    }

    public function show(Project $project)
    {
        return response()->json($project->load(['creator', 'contributions.user', 'contributions.recorder']));
    }
}
