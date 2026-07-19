<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Service;
use App\Models\License;
use App\Models\KasirUser;
use App\Models\Setting;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 0. Seed Default Settings
        Setting::setValue('site_title', 'Kang Digital - Jasa Pembuatan Website & Aplikasi Kasir Android');
        Setting::setValue('site_description', 'Kang Digital melayani pembuatan website professional, sistem kustom Laravel, aplikasi Android premium, serta solusi Kasir UMKM offline-first.');
        Setting::setValue('site_keywords', 'jasa website, pembuatan aplikasi, kasir android, pos umkm, kang digital, gresik, surabaya');
        Setting::setValue('whatsapp_number', '6285730302827');
        Setting::setValue('whatsapp_text', 'Halo Kang Digital, saya tertarik dengan jasa pembuatan website / aplikasi / lisensi Kasir UMKM Anda.');
        Setting::setValue('hero_title', 'Kelola Sistem <span class="highlight-accent">Bisnis & Kasir</span> Digital Anda dengan Aman');
        Setting::setValue('hero_description', 'Kami melayani pembuatan website professional, sistem kustom Laravel, aplikasi Android premium, serta solusi Kasir UMKM offline-first untuk kemudahan manajemen toko Anda.');
        Setting::setValue('app_mockup_title', 'Kasir UMKM');
        Setting::setValue('app_mockup_description', 'Aplikasi kasir offline professional dengan bluetooth printer thermal & backup cloud hPanel.');
        Setting::setValue('app_mockup_version', '1.0.0');
        Setting::setValue('app_download_url', 'https://kangdigital.web.id/downloads/kasir_umkm.apk');
        Setting::setValue('seo_cities', 'Gresik, Surabaya, Sidoarjo, Jakarta, Malang, Bandung, Semarang, Yogyakarta');
        Setting::setValue('seo_geotargeting_enabled', '1');

        // 1. Create Web Admin User (For Landing Page Admin Dashboard)
        // Check if user exists first to prevent duplicates
        if (!User::where('email', 'admin@kangdigital.web.id')->exists()) {
            User::create([
                'name' => 'Admin Kang Digital',
                'email' => 'admin@kangdigital.web.id',
                'password' => Hash::make('admin123'),
            ]);
        }

        // 2. Create Dynamic Services
        Service::create([
            'title' => 'Jasa Pembuatan Website',
            'icon' => 'globe',
            'description' => 'Website Company Profile, E-Commerce, Landing Page Premium, Web Portal, dan sistem custom Laravel yang cepat, responsif, dan SEO Friendly.',
            'price' => 'Mulai Rp 1.500.000',
        ]);

        Service::create([
            'title' => 'Jasa Pembuatan Aplikasi Mobile',
            'icon' => 'smartphone',
            'description' => 'Aplikasi Android & iOS premium berbasis Flutter dengan backend REST API Laravel. Cepat, interaktif, offline-first, dan terintegrasi payment gateway.',
            'price' => 'Mulai Rp 3.500.000',
        ]);

        Service::create([
            'title' => 'Sistem Kasir UMKM Premium',
            'icon' => 'shopping-cart',
            'description' => 'Aplikasi POS kasir offline-first untuk toko, minimarket, atau restoran Anda dengan printer bluetooth thermal, manajemen stok, dan laporan excel/pdf.',
            'price' => 'Mulai Rp 99.000 / bln',
        ]);

        Service::create([
            'title' => 'Optimasi SEO & Cloud Hosting',
            'icon' => 'trending-up',
            'description' => 'Layanan Optimasi Mesin Pencari (SEO), pendaftaran domain (.id/ .com), set up server share hosting / hPanel Hostinger, dan pemeliharaan website bulanan.',
            'price' => 'Mulai Rp 500.000',
        ]);

        // 3. Create Sample Licenses (Member Systems)
        $license1 = License::create([
            'license_key' => 'UMKM-PREMIUM-ACTIVE',
            'device_limit' => 2,
            'price' => 249000,
            'duration_type' => '1_year',
            'status' => 'inactive', // ready to be activated
            'expires_at' => now()->addYear(),
        ]);

        $license2 = License::create([
            'license_key' => 'UMKM-TRIAL-KEY',
            'device_limit' => 1,
            'price' => 29000,
            'duration_type' => '1_month',
            'status' => 'inactive',
            'expires_at' => now()->addMonth(),
        ]);

        License::create([
            'license_key' => 'UMKM-LIFETIME-PREMIUM',
            'device_limit' => 5,
            'price' => 499000,
            'duration_type' => 'lifetime',
            'status' => 'inactive',
            'expires_at' => null, // Lifetime doesn't expire
        ]);

        // 4. Create Cashier Users (Members) for the first license
        // Use password: 'password123'
        $hashedPassword = Hash::make('password123');

        KasirUser::create([
            'username' => 'admin_umkm',
            'name' => 'Owner Kasir UMKM',
            'email' => 'owner_umkm@kangdigital.web.id',
            'password' => $hashedPassword,
            'role' => 'admin',
            'is_active' => true,
            'license_id' => $license1->id,
        ]);

        KasirUser::create([
            'username' => 'kasir_umkm',
            'name' => 'Cashier UMKM',
            'email' => 'cashier_umkm@kangdigital.web.id',
            'password' => $hashedPassword,
            'role' => 'cashier',
            'is_active' => true,
            'license_id' => $license1->id,
        ]);

        // Cashier users for license 2
        KasirUser::create([
            'username' => 'trial_user',
            'name' => 'Trial Owner',
            'email' => 'trial_owner@kangdigital.web.id',
            'password' => $hashedPassword,
            'role' => 'admin',
            'is_active' => true,
            'license_id' => $license2->id,
        ]);
    }
}
