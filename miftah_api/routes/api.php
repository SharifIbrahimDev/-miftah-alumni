<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\ContributionController;
use App\Http\Controllers\Api\ProjectController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\PasswordResetController;
use Illuminate\Support\Facades\Route;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/forgot-password', [PasswordResetController::class, 'forgotPassword']);
Route::post('/verify-otp', [PasswordResetController::class, 'verifyOtp']);
Route::post('/reset-password', [PasswordResetController::class, 'resetPassword']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::put('/profile', [AuthController::class, 'updateProfile']);
    Route::get('/dashboard', [DashboardController::class, 'index']);

    // Registrar and President role based access
    Route::middleware('role:president,registrar')->group(function () {
        Route::get('/users', [UserController::class, 'index']);
        Route::post('/users', [UserController::class, 'store']);
        Route::get('/users/{user}', [UserController::class, 'show']);
        Route::put('/users/{user}', [UserController::class, 'update']);
        Route::delete('/users/{user}', [UserController::class, 'destroy']);
    });

    // Cashier and President role based access
    Route::middleware('role:president,cashier')->group(function () {
        Route::get('/monthly-contributions', [ContributionController::class, 'index']);
        Route::post('/monthly-contributions', [ContributionController::class, 'store']);
        Route::put('/monthly-contributions/{monthlyContribution}', [ContributionController::class, 'update']);
        
        Route::get('/transactions', [TransactionController::class, 'index']);
        Route::post('/transactions', [TransactionController::class, 'store']);
    });

    // President only role based access
    Route::middleware('role:president')->group(function () {
        Route::post('/projects', [ProjectController::class, 'store']);
    });

    // Project routes accessible by all members
    Route::get('/projects', [ProjectController::class, 'index']);
    Route::post('/project-contributions', [ProjectController::class, 'recordContribution']);

    // Self-service routes for all users
    Route::get('/my-contributions', [ContributionController::class, 'myContributions']);
    Route::get('/my-project-contributions', [ProjectController::class, 'myContributions']);
});
