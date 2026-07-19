<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Service;
use App\Models\Lead;
use App\Models\License;
use App\Models\KasirUser;
use App\Models\Setting;
use App\Models\Store;
use App\Models\SyncTransaction;
use App\Models\SyncProduct;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Support\Carbon;

class LandingPageController extends Controller
{
    /**
     * Helper to get all settings.
     */
    private function getSettings()
    {
        return [
            'site_title' => Setting::getValue('site_title', 'Kang Digital - Jasa Pembuatan Website & Aplikasi Kasir Android'),
            'site_description' => Setting::getValue('site_description', 'Kang Digital melayani pembuatan website professional, sistem kustom Laravel, aplikasi Android premium, serta solusi Kasir UMKM offline-first.'),
            'site_keywords' => Setting::getValue('site_keywords', 'jasa website, pembuatan aplikasi, kasir android, pos umkm, kang digital'),
            'whatsapp_number' => Setting::getValue('whatsapp_number', '6285730302827'),
            'whatsapp_text' => Setting::getValue('whatsapp_text', 'Halo Kang Digital, saya tertarik dengan jasa pembuatan website / aplikasi / lisensi Kasir UMKM Anda.'),
            'hero_title' => Setting::getValue('hero_title', 'Kelola Sistem <span class="highlight-accent">Bisnis & Kasir</span> Digital Anda dengan Aman'),
            'hero_description' => Setting::getValue('hero_description', 'Kami melayani pembuatan website professional, sistem kustom Laravel, aplikasi Android premium, serta solusi Kasir UMKM offline-first untuk kemudahan manajemen toko Anda.'),
            'app_mockup_title' => Setting::getValue('app_mockup_title', 'Kasir UMKM'),
            'app_mockup_description' => Setting::getValue('app_mockup_description', 'Aplikasi kasir offline professional dengan bluetooth printer thermal & backup cloud hPanel.'),
            'app_mockup_version' => Setting::getValue('app_mockup_version', '1.0.0'),
            'app_download_url' => Setting::getValue('app_download_url', 'https://kangdigital.web.id/downloads/kasir_umkm.apk'),
            'seo_cities' => Setting::getValue('seo_cities', 'Gresik, Surabaya, Sidoarjo, Jakarta, Malang, Bandung, Semarang, Yogyakarta'),
            'seo_geotargeting_enabled' => Setting::getValue('seo_geotargeting_enabled', '1'),
        ];
    }

    /**
     * Show the public landing page with dynamic services and settings.
     */
    public function index()
    {
        $services = Service::all();
        $settings = $this->getSettings();
        
        $seo = [
            'title' => $settings['site_title'],
            'description' => $settings['site_description'],
            'keywords' => $settings['site_keywords'],
            'headline' => $settings['hero_title'],
            'description_content' => $settings['hero_description'],
            'city' => null
        ];

        return view('welcome', compact('services', 'settings', 'seo'));
    }

    /**
     * Store contact inquiry (lead).
     */
    public function storeLead(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|max:255',
            'phone' => 'required|string|max:50',
            'message' => 'required|string|max:2000',
        ]);

        Lead::create($request->only('name', 'email', 'phone', 'message'));

        return redirect()->back()->with('success', 'Pesan Anda berhasil dikirim! Tim kami akan segera menghubungi Anda.');
    }

    /**
     * Show Admin Login Form
     */
    public function loginForm()
    {
        if (Auth::check()) {
            return redirect()->route('admin.dashboard');
        }
        return view('admin.login');
    }

    /**
     * Process Admin Login
     */
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        if (Auth::attempt($credentials)) {
            $request->session()->regenerate();
            return redirect()->route('admin.dashboard');
        }

        return back()->withErrors([
            'email' => 'Email atau password salah.',
        ])->onlyInput('email');
    }

    /**
     * Process Admin Logout
     */
    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect()->route('admin.login');
    }

    /**
     * Show Admin Dashboard (leads, licenses, and services management)
     */
    public function dashboard()
    {
        $leads = Lead::latest()->get();
        $licenses = License::with('kasirUsers')->latest()->get();
        $services = Service::latest()->get();
        $settings = $this->getSettings();

        return view('admin.dashboard', compact('leads', 'licenses', 'services', 'settings'));
    }

    /**
     * Create a new license key dynamically
     */
    public function createLicense(Request $request)
    {
        $request->validate([
            'duration' => 'required|in:1_month,1_year,lifetime',
            'custom_key' => 'nullable|string|max:50|unique:licenses,license_key',
            'device_limit' => 'required|integer|min:1',
            'price' => 'required|integer|min:0',
        ]);

        $key = $request->input('custom_key') ?: 'UMKM-' . strtoupper(Str::random(12));
        
        $duration = $request->input('duration');
        if ($duration === '1_month') {
            $expires = now()->addMonth();
        } elseif ($duration === '1_year') {
            $expires = now()->addYear();
        } else {
            $expires = null;
        }

        $license = License::create([
            'license_key' => $key,
            'status' => 'inactive',
            'expires_at' => $expires,
            'device_limit' => $request->input('device_limit'),
            'price' => $request->input('price'),
            'duration_type' => $duration,
        ]);

        // Automatically create a default owner user for this license
        $defaultPassword = Hash::make('password123');
        $username = strtolower(str_replace(' ', '_', $key)) . '_owner';
        // Cleanup username
        $username = preg_replace('/[^a-z0-9_]/', '', $username);

        KasirUser::create([
            'username' => $username,
            'name' => 'Owner ' . $key,
            'password' => $defaultPassword,
            'role' => 'admin',
            'is_active' => true,
            'license_id' => $license->id,
        ]);

        return redirect()->back()->with('success', 'Lisensi baru ' . $key . ' berhasil dibuat dengan member default: Username: ' . $username . ', Password: password123');
    }

    /**
     * Create a new service dynamically
     */
    public function createService(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'icon' => 'required|string|max:50',
            'description' => 'required|string',
            'price' => 'nullable|string|max:100',
        ]);

        Service::create($request->only('title', 'icon', 'description', 'price'));

        return redirect()->back()->with('success', 'Layanan berhasil ditambahkan secara dinamis!');
    }

    /**
     * Delete a lead
     */
    public function deleteLead($id)
    {
        Lead::destroy($id);
        return redirect()->back()->with('success', 'Lead berhasil dihapus.');
    }

    /**
     * Delete a service
     */
    public function deleteService($id)
    {
        Service::destroy($id);
        return redirect()->back()->with('success', 'Layanan berhasil dihapus.');
    }

    /**
     * Localized SEO (Geo AIO) for Website services
     */
    public function seoWebsite($city)
    {
        $cityFormatted = ucwords(str_replace('-', ' ', $city));
        $services = Service::all();
        $settings = $this->getSettings();
        
        $seo = [
            'title' => "Jasa Pembuatan Website di {$cityFormatted} Professional - Kang Digital",
            'description' => "Mencari jasa pembuatan website di {$cityFormatted}? Kang Digital melayani pembuatan landing page, web e-commerce, company profile professional di {$cityFormatted} murah & cepat.",
            'keywords' => "jasa website {$city}, buat web {$city}, developer web {$cityFormatted}, seo {$city}, kang digital",
            'headline' => "Jasa Pembuatan <span class=\"highlight-accent\">Website Professional</span> di {$cityFormatted}",
            'description_content' => "Kang Digital hadir di {$cityFormatted} untuk membantu digitalisasi bisnis Anda dengan website premium modern, responsive, cepat, dan teroptimasi SEO lokal.",
            'city' => $cityFormatted
        ];
        
        return view('welcome', compact('services', 'settings', 'seo'));
    }

    /**
     * Localized SEO (Geo AIO) for Kasir services
     */
    public function seoKasir($city)
    {
        $cityFormatted = ucwords(str_replace('-', ' ', $city));
        $services = Service::all();
        $settings = $this->getSettings();
        
        $seo = [
            'title' => "Aplikasi Kasir Android & POS Terbaik di {$cityFormatted} - Kang Digital",
            'description' => "Digitalisasi UMKM Anda di {$cityFormatted} dengan aplikasi Kasir Android offline-first. Cetak struk bluetooth & backup data hPanel cloud untuk toko di {$cityFormatted}.",
            'keywords' => "aplikasi kasir {$city}, pos android {$city}, kasir toko {$cityFormatted}, software kasir {$city}, kang digital",
            'headline' => "Aplikasi Kasir <span class=\"highlight-accent\">Android / POS</span> Terbaik di {$cityFormatted}",
            'description_content' => "Optimalkan manajemen transaksi toko, minimarket, kafe, dan UMKM Anda di {$cityFormatted} menggunakan sistem kasir handal dengan sinkronisasi member cloud.",
            'city' => $cityFormatted
        ];
        
        return view('welcome', compact('services', 'settings', 'seo'));
    }

    /**
     * Localized SEO (Geo AIO) general landing page for a City
     */
    public function seoCity($city)
    {
        $cityFormatted = ucwords(str_replace('-', ' ', $city));
        $services = Service::all();
        $settings = $this->getSettings();
        
        $seo = [
            'title' => "Jasa Pembuatan Website, Aplikasi & Kasir UMKM di {$cityFormatted} - Kang Digital",
            'description' => "Solusi IT terbaik untuk warga {$cityFormatted}. Jasa pembuatan website, aplikasi mobile Flutter, dan sistem kasir Android terintegrasi hPanel cloud di {$cityFormatted}.",
            'keywords' => "jasa website {$city}, buat aplikasi {$city}, kasir android {$cityFormatted}, pos umkm {$city}, kang digital",
            'headline' => "Solusi Teknologi & <span class=\"highlight-accent\">Digitalisasi Bisnis</span> di {$cityFormatted}",
            'description_content' => "Mulai dari pembuatan website profile, toko online, hingga software kasir modern, Kang Digital adalah partner digitalisasi bisnis terpercaya di {$cityFormatted}.",
            'city' => $cityFormatted
        ];
        
        return view('welcome', compact('services', 'settings', 'seo'));
    }

    /**
     * Update dynamic settings from admin dashboard
     */
    public function updateSettings(Request $request)
    {
        $data = $request->validate([
            'site_title' => 'required|string|max:255',
            'site_description' => 'required|string',
            'site_keywords' => 'required|string',
            'whatsapp_number' => 'required|string',
            'whatsapp_text' => 'required|string',
            'hero_title' => 'required|string|max:255',
            'hero_description' => 'required|string',
            'app_mockup_title' => 'required|string|max:255',
            'app_mockup_description' => 'required|string',
            'app_mockup_version' => 'required|string|max:50',
            'app_download_url' => 'required|url',
            'seo_cities' => 'required|string',
            'seo_geotargeting_enabled' => 'required|in:0,1',
        ]);

        foreach ($data as $key => $value) {
            Setting::setValue($key, $value);
        }

        return redirect()->back()->with('success', 'Pengaturan landing page & SEO berhasil diperbarui!');
    }

    /**
     * Create a new Kasir member under a license
     */
    public function createMember(Request $request)
    {
        $request->validate([
            'license_id' => 'required|exists:licenses,id',
            'username' => 'required|string|max:50|unique:kasir_users,username',
            'name' => 'required|string|max:255',
            'password' => 'required|string|min:6',
            'role' => 'required|in:admin,cashier',
        ]);

        KasirUser::create([
            'username' => $request->username,
            'name' => $request->name,
            'password' => Hash::make($request->password),
            'role' => $request->role,
            'is_active' => true,
            'license_id' => $request->license_id,
        ]);

        return redirect()->back()->with('success', 'Member baru berhasil ditambahkan dan disinkronkan!');
    }

    /**
     * Toggle status active/inactive for Kasir member
     */
    public function toggleMember($id)
    {
        $user = KasirUser::findOrFail($id);
        $user->is_active = !$user->is_active;
        $user->save();

        $status = $user->is_active ? 'diaktifkan' : 'dinonaktifkan';
        return redirect()->back()->with('success', "Member {$user->username} berhasil {$status}!");
    }

    /**
     * Change Kasir member password
     */
    public function changeMemberPassword(Request $request, $id)
    {
        $request->validate([
            'password' => 'required|string|min:6',
        ]);

        $user = KasirUser::findOrFail($id);
        $user->password = Hash::make($request->password);
        $user->save();

        return redirect()->back()->with('success', "Password untuk member {$user->username} berhasil diperbarui!");
    }

    /**
     * Delete Kasir member
     */
    public function deleteMember($id)
    {
        $user = KasirUser::findOrFail($id);
        $username = $user->username;
        $user->delete();

        return redirect()->back()->with('success', "Member {$username} berhasil dihapus!");
    }

    /**
     * Update/extend license key details
     */
    public function updateLicense(Request $request, $id)
    {
        $license = License::findOrFail($id);

        $request->validate([
            'device_limit' => 'required|integer|min:1',
            'price' => 'required|integer|min:0',
            'status' => 'required|in:active,inactive,expired,deactivated',
            'action_type' => 'required|string', // none, extend_month, extend_year, extend_lifetime
        ]);

        $expires = $license->expires_at;

        if ($request->input('action_type') === 'extend_month') {
            $expires = $expires ? Carbon::parse($expires)->addMonth() : now()->addMonth();
        } elseif ($request->input('action_type') === 'extend_year') {
            $expires = $expires ? Carbon::parse($expires)->addYear() : now()->addYear();
        } elseif ($request->input('action_type') === 'extend_lifetime') {
            $expires = null;
        }

        $license->update([
            'device_limit' => $request->input('device_limit'),
            'price' => $request->input('price'),
            'status' => $request->input('status'),
            'expires_at' => $expires,
        ]);

        return redirect()->back()->with('success', 'Lisensi ' . $license->license_key . ' berhasil diupdate/diperpanjang!');
    }

    /**
     * Delete license key
     */
    public function deleteLicense($id)
    {
        $license = License::findOrFail($id);
        $key = $license->license_key;
        $license->delete();

        return redirect()->back()->with('success', 'Lisensi ' . $key . ' berhasil dihapus.');
    }

    /**
     * Admin: Halaman dashboard semua toko (stores) per lisensi
     */
    public function storesDashboard()
    {
        $licenses = License::with(['stores' => function ($q) {
            $q->withCount(['products', 'transactions', 'customers', 'expenses', 'suppliers']);
        }])->latest()->get();

        $totalStores = Store::count();
        $totalProducts = \App\Models\SyncProduct::count();
        $totalTransactions = SyncTransaction::count();
        $totalRevenue = SyncTransaction::where('status', 'completed')->sum('total');

        return view('admin.stores', compact('licenses', 'totalStores', 'totalProducts', 'totalTransactions', 'totalRevenue'));
    }

    /**
     * Admin: Detail toko berdasarkan license
     */
    public function storeDetail($licenseId)
    {
        $license = License::with(['stores.products', 'stores.customers', 'kasirUsers'])->findOrFail($licenseId);
        $stores = Store::where('license_id', $licenseId)
            ->withCount(['products', 'transactions', 'customers', 'expenses', 'suppliers', 'backups'])
            ->get();

        return view('admin.store_detail', compact('license', 'stores'));
    }

    /**
     * Admin: Hapus toko
     */
    public function deleteStore($storeId)
    {
        $store = Store::findOrFail($storeId);
        $name = $store->store_name;
        $store->delete(); // cascade delete products, transactions, etc.

        return redirect()->back()->with('success', "Toko '{$name}' berhasil dihapus beserta semua datanya.");
    }

    /**
     * Admin: Lihat data toko (produk, transaksi, dll)
     */
    public function storeData($storeId)
    {
        $store = Store::with(['license'])->findOrFail($storeId);
        $products = \App\Models\SyncProduct::where('store_id', $storeId)->latest()->take(50)->get();
        $transactions = SyncTransaction::where('store_id', $storeId)->latest()->take(50)->get();
        $customers = \App\Models\SyncCustomer::where('store_id', $storeId)->latest()->take(50)->get();
        $expenses = \App\Models\SyncExpense::where('store_id', $storeId)->latest()->take(50)->get();
        $suppliers = \App\Models\SyncSupplier::where('store_id', $storeId)->latest()->take(50)->get();
        $backups = \App\Models\CloudBackup::where('store_id', $storeId)->latest()->get();

        // Summary this month
        $thisMonth = Carbon::now()->startOfMonth();
        $revenue = SyncTransaction::where('store_id', $storeId)
            ->where('status', 'completed')
            ->where('sold_at', '>=', $thisMonth)
            ->sum('total');
        $expenseTotal = \App\Models\SyncExpense::where('store_id', $storeId)
            ->where('expense_date', '>=', $thisMonth)
            ->sum('amount');

        return view('admin.store_data', compact(
            'store', 'products', 'transactions', 'customers',
            'expenses', 'suppliers', 'backups', 'revenue', 'expenseTotal'
        ));
    }
}
