<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MonthlyContribution;
use App\Models\Project;
use App\Models\ProjectContribution;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $stats = [];

        if ($user->isPresident() || $user->isCashier()) {
            $stats['total_users'] = User::count();
            $stats['total_collected_monthly'] = MonthlyContribution::where('status', 'paid')->sum('amount');
            $stats['total_project_raised'] = ProjectContribution::sum('amount');
            $stats['total_expenses'] = Transaction::where('type', 'debit')->sum('amount');
            $stats['active_projects'] = Project::count();
            $stats['recent_monthly'] = MonthlyContribution::with('user')->where('status', 'paid')->latest()->limit(5)->get();
        }

        if ($user->isRegistrar() || $user->isPresident()) {
            $stats['total_members'] = User::where('role', 'member')->count();
            $stats['recent_members'] = User::where('role', 'member')->latest()->limit(5)->get();
        }

        if ($user->isMember()) {
            $stats['my_total_monthly'] = MonthlyContribution::where('user_id', $user->id)->where('status', 'paid')->sum('amount');
            $stats['my_total_project'] = ProjectContribution::where('user_id', $user->id)->sum('amount');
            $stats['recent_my_activities'] = MonthlyContribution::where('user_id', $user->id)->latest()->limit(5)->get();
            $stats['available_projects'] = Project::latest()->limit(3)->get();
        }

        return response()->json($stats);
    }
}
