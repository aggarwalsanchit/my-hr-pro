<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Plan;
use App\Models\Setting;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DefaultCompanySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Default companies array
        $defaultCompanies = [ [ 'name' => 'BrightPath Technologies', 'email' => 'admin@brightpathtech.com', 'lang' => 'en', ], [ 'name' => 'BluePeak Consulting', 'email' => 'admin@bluepeakconsulting.com', 'lang' => 'en', ], [ 'name' => 'Evergreen Digital Works', 'email' => 'admin@evergreendigital.com', 'lang' => 'en', ], [ 'name' => 'SilverLine Enterprises', 'email' => 'admin@silverlineent.com', 'lang' => 'en', ], [ 'name' => 'NorthStar Business Group', 'email' => 'admin@northstarbusiness.com', 'lang' => 'en', ], [ 'name' => 'Redwood Technologies', 'email' => 'admin@redwoodtech.com', 'lang' => 'en', ], [ 'name' => 'SkyBridge Solutions', 'email' => 'admin@skybridgesolutions.com', 'lang' => 'en', ], [ 'name' => 'GreenField Industries', 'email' => 'admin@greenfieldindustries.com', 'lang' => 'en', ], [ 'name' => 'PrimeWave Innovations', 'email' => 'admin@primewave.com', 'lang' => 'en', ], [ 'name' => 'CloudVista Systems', 'email' => 'admin@cloudvista.com', 'lang' => 'en', ], [ 'name' => 'MyHR Pro', 'email' => 'company@myhrpro.com', 'lang' => 'en', ], ];



        // Filter companies based on demo config
        if (config('app.is_saas') == true) {
            // Get all plans
            $plans = Plan::all();
            if (config('app.is_demo') == true) {
                $companiesToCreate = $defaultCompanies;
            } else {
                $companiesToCreate = array_filter($defaultCompanies, function ($company) {
                    return $company['email'] === 'company@myhrpro.com';
                });
            }
        } else {
            // Non-SaaS: Only one company
            $companiesToCreate = [[
                'name' => 'Company',
                'email' => 'company@myhrpro.com',
                'lang' => 'en',
            ]];
        }


        // Create default companies
        if (config('app.is_saas') == true) {
            foreach ($companiesToCreate as $companyData) {
                // Skip if user already exists
                if (User::where('email', $companyData['email'])->exists()) {
                    continue;
                }

                $defaultPlan = Plan::where('is_default', true)->first();
                // Create company user
                $user = User::create([
                    'name' => $companyData['name'],
                    'email' => $companyData['email'],
                    'email_verified_at' => now(),
                    'password' => Hash::make('password'),
                    'type' => 'company',
                    'lang' => $companyData['lang'],
                    'plan_id' => config('app.is_demo') ? $plans->random()->id : ($defaultPlan ? $defaultPlan->id : null),
                    'plan_expire_date' => now()->addMonth(),
                    'referral_code' => rand(100000, 999999),
                    'created_at' => now(),
                    'created_by' => 1,
                ]);

                // Assign company role
                $user->assignRole('company');

                // Create default settings
                if (!Setting::where('user_id', $user->id)->exists()) {
                    copySettingsFromSuperAdmin($user->id);
                }
            }
        } else {
            foreach ($companiesToCreate as $companyData) {
                // Skip if user already exists
                if (User::where('email', $companyData['email'])->exists()) {
                    continue;
                }

                // Create company user (no plan_id for non-SaaS)
                $user = User::create([
                    'name' => $companyData['name'],
                    'email' => $companyData['email'],
                    'email_verified_at' => now(),
                    'password' => Hash::make('password'),
                    'type' => 'company',
                    'lang' => $companyData['lang'],
                    'created_at' => now(),
                ]);

                // Assign company role
                $user->assignRole('company');

                // Create default settings
                if (!Setting::where('user_id', $user->id)->exists()) {
                    copySettingsFromSuperAdmin($user->id);
                }
            }
        }

        $this->command->info('Created ' . count($companiesToCreate) . ' default companies successfully!');
    }
}
