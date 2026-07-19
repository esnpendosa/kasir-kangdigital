<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LandingPageController;
use App\Http\Controllers\MemberAuthController;

// Public Routes
Route::get('/', [LandingPageController::class, 'index'])->name('home');
Route::post('/lead', [LandingPageController::class, 'storeLead'])->name('lead.store');

// Localized SEO (Geo AIO) Routes
Route::get('/jasa-pembuatan-website-di-{city}', [LandingPageController::class, 'seoWebsite'])->name('seo.website');
Route::get('/aplikasi-kasir-umkm-di-{city}', [LandingPageController::class, 'seoKasir'])->name('seo.kasir');
Route::get('/di/{city}', [LandingPageController::class, 'seoCity'])->name('seo.city');

// ─── Unified Auth Routes ─────────────────────────────────────────────────────
Route::get('/login', [MemberAuthController::class, 'unifiedLoginForm'])->name('login');
Route::post('/login', [MemberAuthController::class, 'unifiedLogin'])->name('login.post');
Route::get('/password/reset', [MemberAuthController::class, 'forgotPasswordForm'])->name('password.reset');
Route::post('/password/reset', [MemberAuthController::class, 'sendResetLink'])->name('password.reset.post');

// ─── Member Auth Routes ───────────────────────────────────────────────────────
Route::get('/member/login', function() { return redirect()->route('login'); })->name('member.login');
Route::post('/member/login', [MemberAuthController::class, 'login'])->name('member.login.post');
Route::get('/member/register', [MemberAuthController::class, 'registerForm'])->name('member.register');
Route::post('/member/register', [MemberAuthController::class, 'register'])->name('member.register.post');
Route::get('/member/dashboard', [MemberAuthController::class, 'dashboard'])->name('member.dashboard');
Route::post('/member/logout', [MemberAuthController::class, 'logout'])->name('member.logout');

// Admin Auth Routes
Route::get('/admin/login', function() { return redirect()->route('login', ['tab' => 'admin']); })->name('admin.login');
Route::post('/admin/login', [LandingPageController::class, 'login']);
Route::post('/admin/logout', [LandingPageController::class, 'logout'])->name('admin.logout');

// Protected Admin Routes
Route::middleware(['auth'])->group(function () {
    Route::get('/admin/dashboard', [LandingPageController::class, 'dashboard'])->name('admin.dashboard');
    Route::post('/admin/license', [LandingPageController::class, 'createLicense'])->name('admin.license.create');
    Route::post('/admin/license/{id}/update', [LandingPageController::class, 'updateLicense'])->name('admin.license.update');
    Route::delete('/admin/license/{id}', [LandingPageController::class, 'deleteLicense'])->name('admin.license.delete');
    Route::post('/admin/service', [LandingPageController::class, 'createService'])->name('admin.service.create');
    Route::delete('/admin/lead/{id}', [LandingPageController::class, 'deleteLead'])->name('admin.lead.delete');
    Route::delete('/admin/service/{id}', [LandingPageController::class, 'deleteService'])->name('admin.service.delete');

    // Setting Routes
    Route::post('/admin/setting', [LandingPageController::class, 'updateSettings'])->name('admin.setting.update');

    // Member (KasirUser) Management Routes
    Route::post('/admin/member', [LandingPageController::class, 'createMember'])->name('admin.member.create');
    Route::post('/admin/member/{id}/toggle', [LandingPageController::class, 'toggleMember'])->name('admin.member.toggle');
    Route::post('/admin/member/{id}/change-password', [LandingPageController::class, 'changeMemberPassword'])->name('admin.member.change-password');
    Route::delete('/admin/member/{id}', [LandingPageController::class, 'deleteMember'])->name('admin.member.delete');

    // ─── Store & Sync Dashboard ─────────────────────────────────────────────
    Route::get('/admin/stores', [LandingPageController::class, 'storesDashboard'])->name('admin.stores');
    Route::get('/admin/stores/{licenseId}', [LandingPageController::class, 'storeDetail'])->name('admin.store.detail');
    Route::delete('/admin/store/{storeId}', [LandingPageController::class, 'deleteStore'])->name('admin.store.delete');
    Route::get('/admin/store/{storeId}/data', [LandingPageController::class, 'storeData'])->name('admin.store.data');
});
