<?php

namespace App\Http\Controllers;

use App\Models\KasirUser;
use App\Models\License;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Str;

class MemberAuthController extends Controller
{
    // ─── Member Login Form ────────────────────────────────────────
    public function loginForm()
    {
        if (Session::has('member_id')) {
            return redirect()->route('member.dashboard');
        }
        return view('member.login');
    }

    // ─── Member Login Handler ─────────────────────────────────────
    public function login(Request $request)
    {
        $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
        ], [
            'username.required' => 'Username wajib diisi.',
            'password.required' => 'Password wajib diisi.',
        ]);

        $user = KasirUser::where('username', $request->username)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return back()->withErrors(['username' => 'Username atau password salah.'])->withInput($request->only('username'));
        }

        if (!$user->is_active) {
            return back()->withErrors(['username' => 'Akun Anda tidak aktif. Hubungi admin.'])->withInput($request->only('username'));
        }

        Session::put('member_id', $user->id);
        Session::put('member_name', $user->name);
        Session::put('member_username', $user->username);
        Session::put('member_role', $user->role);

        return redirect()->route('member.dashboard')->with('success', 'Selamat datang, ' . $user->name . '!');
    }

    // ─── Member Register Form ─────────────────────────────────────
    public function registerForm()
    {
        if (Session::has('member_id')) {
            return redirect()->route('member.dashboard');
        }
        return view('member.register');
    }

    // ─── Member Register Handler ──────────────────────────────────
    public function register(Request $request)
    {
        $request->validate([
            'name'        => 'required|string|max:100',
            'username'    => 'required|string|min:4|max:30|unique:kasir_users,username|alpha_dash',
            'email'       => 'required|email|max:100|unique:kasir_users,email',
            'password'    => 'required|string|min:6|confirmed',
        ], [
            'name.required'        => 'Nama lengkap wajib diisi.',
            'username.required'    => 'Username wajib diisi.',
            'username.unique'      => 'Username sudah digunakan.',
            'username.min'         => 'Username minimal 4 karakter.',
            'username.alpha_dash'  => 'Username hanya boleh huruf, angka, strip, dan underscore.',
            'email.required'       => 'Alamat email wajib diisi.',
            'email.email'          => 'Format alamat email tidak valid.',
            'email.unique'         => 'Alamat email sudah terdaftar.',
            'password.required'    => 'Password wajib diisi.',
            'password.min'         => 'Password minimal 6 karakter.',
            'password.confirmed'   => 'Konfirmasi password tidak cocok.',
        ]);

        // Auto-generate a unique license key in KD-XXXX-XXXX-XXXX format
        do {
            $key = 'KD-' . strtoupper(Str::random(4)) . '-' . strtoupper(Str::random(4)) . '-' . strtoupper(Str::random(4));
        } while (License::where('license_key', $key)->exists());

        // Create the license as inactive initially
        $license = License::create([
            'license_key' => $key,
            'device_limit' => 1,
            'price'        => 249000, // Rp 249.000 for 1 year
            'duration_type'=> '1_year',
            'status'      => 'inactive',
            'expires_at'  => now()->addYear(), // default 1 year
        ]);

        // First user under this license is the admin/owner
        $role = 'admin';

        $user = KasirUser::create([
            'name'       => $request->name,
            'username'   => $request->username,
            'email'      => $request->email,
            'password'   => Hash::make($request->password),
            'role'       => $role,
            'is_active'  => true,
            'license_id' => $license->id,
        ]);

        Session::put('member_id', $user->id);
        Session::put('member_name', $user->name);
        Session::put('member_username', $user->username);
        Session::put('member_role', $user->role);

        return redirect()->route('member.dashboard')->with('success', 'Registrasi berhasil! Lisensi Anda ' . $key . ' telah terbuat.');
    }

    // ─── Member Dashboard ─────────────────────────────────────────
    public function dashboard()
    {
        if (!Session::has('member_id')) {
            return redirect()->route('member.login')->withErrors(['username' => 'Silakan login terlebih dahulu.']);
        }

        $user = KasirUser::with('license')->find(Session::get('member_id'));

        if (!$user) {
            Session::forget(['member_id', 'member_name', 'member_username', 'member_role']);
            return redirect()->route('member.login');
        }

        // Get all teammates on the same license
        $teammates = KasirUser::where('license_id', $user->license_id)
                              ->where('id', '!=', $user->id)
                              ->get();

        return view('member.dashboard', compact('user', 'teammates'));
    }

    // ─── Member Logout ────────────────────────────────────────────
    public function logout()
    {
        Session::forget(['member_id', 'member_name', 'member_username', 'member_role']);
        return redirect()->route('member.login')->with('success', 'Anda telah berhasil keluar.');
    }

    // ─── Unified Login Form ───────────────────────────────────────
    public function unifiedLoginForm(Request $request)
    {
        if (Session::has('member_id')) {
            return redirect()->route('member.dashboard');
        }
        if (\Illuminate\Support\Facades\Auth::check()) {
            return redirect()->route('admin.dashboard');
        }
        $tab = $request->query('tab', 'member');
        return view('auth.login', compact('tab'));
    }

    // ─── Unified Login Handler (Auto Role Detection) ──────────────
    public function unifiedLogin(Request $request)
    {
        $request->validate([
            'login_input' => 'required|string',
            'password'    => 'required|string',
        ], [
            'login_input.required' => 'Username atau Email wajib diisi.',
            'password.required'    => 'Password wajib diisi.',
        ]);

        $loginInput = $request->login_input;
        $password = $request->password;

        // 1. If it looks like an email, check Admin first, then Member
        if (filter_var($loginInput, FILTER_VALIDATE_EMAIL)) {
            // Check if Admin exists with this email
            $adminUser = \App\Models\User::where('email', $loginInput)->first();
            if ($adminUser) {
                // Attempt Admin Login
                if (\Illuminate\Support\Facades\Auth::attempt(['email' => $loginInput, 'password' => $password])) {
                    $request->session()->regenerate();
                    return redirect()->route('admin.dashboard')->with('success', 'Selamat datang kembali Admin, ' . $adminUser->name . '!');
                } else {
                    return back()->withErrors(['login_input' => 'Password admin salah.'])->withInput($request->only('login_input'));
                }
            }

            // Check if Member exists with this email
            $memberUser = \App\Models\KasirUser::where('email', $loginInput)->first();
            if ($memberUser) {
                // Attempt Member Login
                if (Hash::check($password, $memberUser->password)) {
                    if (!$memberUser->is_active) {
                        return back()->withErrors(['login_input' => 'Akun Member Anda tidak aktif. Hubungi admin.'])->withInput($request->only('login_input'));
                    }
                    Session::put('member_id', $memberUser->id);
                    Session::put('member_name', $memberUser->name);
                    Session::put('member_username', $memberUser->username);
                    Session::put('member_role', $memberUser->role);
                    return redirect()->route('member.dashboard')->with('success', 'Selamat datang, ' . $memberUser->name . '!');
                } else {
                    return back()->withErrors(['login_input' => 'Password member salah.'])->withInput($request->only('login_input'));
                }
            }
        } else {
            // 2. If it's not an email, it must be a Member username
            $memberUser = \App\Models\KasirUser::where('username', $loginInput)->first();
            if ($memberUser) {
                if (Hash::check($password, $memberUser->password)) {
                    if (!$memberUser->is_active) {
                        return back()->withErrors(['login_input' => 'Akun Member Anda tidak aktif. Hubungi admin.'])->withInput($request->only('login_input'));
                    }
                    Session::put('member_id', $memberUser->id);
                    Session::put('member_name', $memberUser->name);
                    Session::put('member_username', $memberUser->username);
                    Session::put('member_role', $memberUser->role);
                    return redirect()->route('member.dashboard')->with('success', 'Selamat datang, ' . $memberUser->name . '!');
                } else {
                    return back()->withErrors(['login_input' => 'Password member salah.'])->withInput($request->only('login_input'));
                }
            }
        }

        // 3. Fallback: No user found
        return back()->withErrors(['login_input' => 'Akun tidak ditemukan. Silakan periksa kembali Username atau Email Anda.'])->withInput($request->only('login_input'));
    }

    // ─── Unified Reset Password Form ──────────────────────────────
    public function forgotPasswordForm()
    {
        return view('auth.passwords.email');
    }

    // ─── Process Reset Password via Email ────────────────────────
    public function sendResetLink(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ], [
            'email.required' => 'Alamat email wajib diisi.',
            'email.email' => 'Format email tidak valid.',
        ]);

        // 1. Search in Admin (User)
        $admin = \App\Models\User::where('email', $request->email)->first();
        if ($admin) {
            // Found Admin. Generate temporary password
            $tempPassword = 'ResetAdmin' . rand(100, 999);
            $admin->password = Hash::make($tempPassword);
            $admin->save();

            // Log password reset info
            \Illuminate\Support\Facades\Log::info("Password Reset for Admin [{$request->email}]. New Password: {$tempPassword}");

            return back()->with('success', 'Link reset password / password baru telah dikirim ke email Admin Anda. Silakan cek mailbox/log.<br><strong>Password baru Anda: ' . $tempPassword . '</strong>');
        }

        // 2. Search in Member (KasirUser)
        $member = \App\Models\KasirUser::where('email', $request->email)->first();
        if ($member) {
            // Found Member. Generate temporary password
            $tempPassword = 'ResetMember' . rand(100, 999);
            $member->password = Hash::make($tempPassword);
            $member->save();

            // Log password reset info
            \Illuminate\Support\Facades\Log::info("Password Reset for Member [{$request->email}]. New Password: {$tempPassword}");

            return back()->with('success', 'Link reset password / password baru telah dikirim ke email Member Anda. Silakan cek mailbox/log.<br><strong>Password baru Anda: ' . $tempPassword . '</strong>');
        }

        return back()->withErrors(['email' => 'Alamat email tidak terdaftar di sistem kami.']);
    }
}
