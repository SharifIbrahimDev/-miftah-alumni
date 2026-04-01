<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'target_amount',
        'created_by',
    ];

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function contributions()
    {
        return $this->hasMany(ProjectContribution::class);
    }

    public function getTotalContributedAttribute()
    {
        return $this->contributions()->sum('amount');
    }
}
