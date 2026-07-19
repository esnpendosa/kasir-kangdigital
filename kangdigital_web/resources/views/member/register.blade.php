<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daftar Member Baru | Kang Digital</title>
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Outfit:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    
    <!-- FontAwesome for Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root {
            --bg-color: #fcfcfd;
            --surface-color: #ffffff;
            --surface-border: #f1f5f9;
            --primary: #0f172a; /* Slate-900 / Black */
            --accent-blue: #2563eb;
            --accent-orange: #f97316;
            --accent-pink: #ec4899;
            --accent-green: #10b981;
            --text-main: #1e293b;
            --text-muted: #64748b;
            --font-sans: 'Plus Jakarta Sans', sans-serif;
            --font-heading: 'Outfit', sans-serif;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: var(--font-sans);
            background-color: var(--bg-color);
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            overflow-x: hidden;
            padding: 20px;
        }

        /* Floating decoration shapes identical to Landing Page */
        .shape-triangle {
            position: absolute;
            width: 0;
            height: 0;
            border-left: 10px solid transparent;
            border-right: 10px solid transparent;
            border-bottom: 20px solid rgba(244, 63, 94, 0.15); /* Pink */
            transform: rotate(35deg);
            animation: float-slow 6s ease-in-out infinite;
        }
        .shape-circle {
            position: absolute;
            width: 25px;
            height: 25px;
            border: 4px solid rgba(168, 85, 247, 0.15); /* Purple */
            border-radius: 50%;
            animation: float-slow-reverse 8s ease-in-out infinite;
        }
        .shape-dots {
            position: absolute;
            width: 60px;
            height: 60px;
            background-image: radial-gradient(rgba(16, 185, 129, 0.15) 2px, transparent 2px);
            background-size: 10px 10px;
        }
        @keyframes float-slow {
            0%, 100% { transform: translateY(0) rotate(0deg); }
            50% { transform: translateY(-12px) rotate(15deg); }
        }
        @keyframes float-slow-reverse {
            0%, 100% { transform: translateY(0) rotate(0deg); }
            50% { transform: translateY(12px) rotate(-15deg); }
        }

        /* Positions of floating shapes */
        .pos-1 { top: 10%; left: 8%; }
        .pos-2 { bottom: 15%; left: 5%; }
        .pos-3 { top: 20%; right: 10%; }
        .pos-4 { bottom: 10%; right: 8%; }

        .auth-wrapper {
            position: relative;
            z-index: 10;
            display: flex;
            width: 100%;
            max-width: 1050px;
            min-height: 650px;
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(15, 23, 42, 0.05);
            border-radius: 36px;
            overflow: hidden;
            box-shadow: 0 30px 80px rgba(15, 23, 42, 0.06);
        }

        /* Left Panel - App Showcase */
        .auth-panel-left {
            width: 45%;
            background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 100%);
            padding: 48px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            color: #ffffff;
            position: relative;
            overflow: hidden;
        }

        .auth-panel-left::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: radial-gradient(circle at 80% 20%, rgba(37, 99, 235, 0.15), transparent 50%);
            pointer-events: none;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 12px;
            font-family: var(--font-heading);
            font-size: 22px;
            font-weight: 800;
            color: #ffffff;
            text-decoration: none;
            z-index: 5;
        }

        .brand img {
            width: 38px;
            height: 38px;
            border-radius: 10px;
            object-fit: cover;
            box-shadow: 0 4px 10px rgba(0,0,0,0.15);
        }

        /* Phone Mockup Style */
        .mockup-container {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 25px 0;
            z-index: 5;
        }

        .phone-frame {
            width: 210px;
            height: 310px;
            background-color: #ffffff;
            border-radius: 28px;
            border: 7px solid #000000;
            box-shadow: 0 20px 40px rgba(0,0,0,0.25);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            padding: 12px;
            position: relative;
        }

        .phone-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 8px;
            color: #94a3b8;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .phone-inner {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 6px;
            justify-content: center;
            text-align: center;
        }

        .phone-icon-big {
            font-size: 40px;
            color: var(--accent-blue);
            margin-bottom: 8px;
            animation: float-slow 4s ease-in-out infinite;
        }

        .phone-welcome-title {
            font-family: var(--font-heading);
            font-size: 14px;
            font-weight: 800;
            color: var(--primary);
            margin-bottom: 4px;
        }

        .phone-welcome-desc {
            font-size: 8.5px;
            color: var(--text-muted);
            line-height: 1.4;
            padding: 0 10px;
            margin-bottom: 12px;
        }

        .phone-btn-mock {
            background-color: var(--accent-blue);
            color: #ffffff;
            font-size: 9px;
            font-weight: 750;
            padding: 8px;
            border-radius: 8px;
            border: none;
            display: inline-block;
        }

        .panel-left-footer {
            font-size: 12px;
            color: rgba(255,255,255,0.4);
            z-index: 5;
        }

        /* Right Panel - Form */
        .auth-panel-right {
            flex: 1;
            background: #ffffff;
            padding: 48px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .auth-panel-right h1 {
            font-family: var(--font-heading);
            font-size: 32px;
            font-weight: 900;
            color: var(--primary);
            margin-bottom: 6px;
            letter-spacing: -0.5px;
        }

        .subtitle {
            font-size: 14px;
            color: var(--text-muted);
            margin-bottom: 24px;
            line-height: 1.5;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        .form-group {
            margin-bottom: 16px;
        }

        .form-group.full {
            grid-column: span 2;
        }

        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 700;
            color: var(--text-main);
            margin-bottom: 8px;
        }

        .input-wrapper {
            position: relative;
        }

        .input-wrapper i {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
            font-size: 14px;
            transition: color 0.2s;
        }

        .input-wrapper input {
            width: 100%;
            padding: 13px 16px 13px 44px;
            border: 1.5px solid var(--surface-border);
            border-radius: 12px;
            font-size: 14px;
            font-family: var(--font-sans);
            color: var(--text-main);
            background: #f8fafc;
            outline: none;
            transition: all 0.2s;
        }

        .input-wrapper input:focus {
            border-color: var(--accent-blue);
            background: #ffffff;
            box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.08);
        }

        .input-wrapper input:focus + i {
            color: var(--accent-blue);
        }

        #toggle-password:hover, #toggle-password-conf:hover {
            color: var(--accent-blue) !important;
        }

        .info-hint {
            font-size: 12px;
            color: var(--text-muted);
            margin-top: 4px;
            display: flex;
            align-items: center;
            gap: 6px;
            line-height: 1.4;
        }

        .info-hint i {
            color: var(--accent-blue);
        }

        .error-box {
            background: #fef2f2;
            border: 1px solid #fecaca;
            color: #b91c1c;
            padding: 12px 16px;
            border-radius: 12px;
            font-size: 13px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
        }

        .btn-submit {
            width: 100%;
            background: linear-gradient(135deg, #2563eb, #1d4ed8);
            color: #ffffff;
            border: none;
            padding: 14px;
            border-radius: 12px;
            font-size: 15px;
            font-weight: 700;
            font-family: var(--font-sans);
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
            box-shadow: 0 4px 14px rgba(37, 99, 235, 0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            margin-top: 10px;
        }

        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(37, 99, 235, 0.3);
        }

        .auth-switch {
            text-align: center;
            margin-top: 24px;
            font-size: 14px;
            color: var(--text-muted);
        }

        .auth-switch a {
            color: var(--accent-blue);
            font-weight: 700;
            text-decoration: none;
            transition: color 0.2s;
        }

        .auth-switch a:hover {
            color: #1d4ed8;
            text-decoration: underline;
        }

        .back-home {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 13.5px;
            color: var(--text-muted);
            text-decoration: none;
            margin-top: 20px;
            font-weight: 700;
            transition: all 0.2s;
        }

        .back-home:hover {
            color: var(--accent-blue);
            transform: translateX(-3px);
        }

        @media (max-width: 860px) {
            .auth-panel-left {
                display: none;
            }
            .auth-panel-right {
                padding: 40px 24px;
            }
            .auth-wrapper {
                border-radius: 24px;
                max-width: 480px;
                min-height: auto;
            }
            .form-row {
                grid-template-columns: 1fr;
                gap: 0;
            }
            .form-group {
                margin-bottom: 12px;
            }
            .form-group.full {
                grid-column: span 1;
            }
        }
    </style>
</head>
<body>
    <!-- Floating Background Shapes -->
    <div class="shape-triangle pos-1"></div>
    <div class="shape-circle pos-2"></div>
    <div class="shape-dots pos-3"></div>
    <div class="shape-circle pos-4"></div>

    <div class="auth-wrapper">
        <!-- Left Showcase Panel -->
        <div class="auth-panel-left">
            <a href="/" class="brand">
                <img src="{{ asset('logo.png') }}" alt="Kang Digital">
                <span>Kang Digital</span>
            </a>
            
            <div class="mockup-container">
                <!-- Pure CSS Phone Mockup representing Android Pos Activation app screen -->
                <div class="phone-frame">
                    <div class="phone-header">
                        <span>Kasir UMKM</span>
                        <div class="phone-badge" style="background-color: #fffbeb; color: #b45309;">
                            <i class="fa-solid fa-clock"></i>
                            <span>Aktivasi</span>
                        </div>
                    </div>
                    <div class="phone-inner">
                        <i class="fa-solid fa-key-skeleton phone-icon-big"></i>
                        <span class="phone-welcome-title">Aktivasi Lisensi POS</span>
                        <p class="phone-welcome-desc">Masukkan Kode Lisensi Kang Digital Anda untuk menghubungkan data kasir.</p>
                        <div class="phone-btn-mock">Hubungkan Sekarang</div>
                    </div>
                </div>
            </div>

            <p class="panel-left-footer">&copy; {{ date('Y') }} Kang Digital. Hak Cipta Dilindungi.</p>
        </div>

        <!-- Right Form Panel -->
        <div class="auth-panel-right">
            <h1>Daftar Member</h1>
            <p class="subtitle">Buat akun Anda. Sistem otomatis akan menerbitkan lisensi baru untuk disinkronkan dengan aplikasi Android POS.</p>

            @if($errors->any())
                <div class="error-box">
                    <i class="fa-solid fa-circle-exclamation"></i>
                    <span>{{ $errors->first() }}</span>
                </div>
            @endif

            <form action="{{ route('member.register.post') }}" method="POST">
                @csrf
                <div class="form-row">
                    <div class="form-group">
                        <label for="name">Nama Lengkap</label>
                        <div class="input-wrapper">
                            <i class="fa-solid fa-id-card"></i>
                            <input type="text" name="name" id="name" placeholder="Budi Santoso" value="{{ old('name') }}" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="username">Username</label>
                        <div class="input-wrapper">
                            <i class="fa-solid fa-user"></i>
                            <input type="text" name="username" id="username" placeholder="budi_kasir" value="{{ old('username') }}" required>
                        </div>
                    </div>

                    <div class="form-group full">
                        <label for="email">Alamat Email</label>
                        <div class="input-wrapper">
                            <i class="fa-solid fa-envelope"></i>
                            <input type="email" name="email" id="email" placeholder="budi@email.com" value="{{ old('email') }}" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="password">Kata Sandi</label>
                        <div class="input-wrapper">
                            <i class="fa-solid fa-lock"></i>
                            <input type="password" name="password" id="password" placeholder="Min. 6 karakter" required style="padding-right: 48px;">
                            <i class="fa-solid fa-eye" id="toggle-password" style="position: absolute; right: 16px; left: auto; cursor: pointer; color: #94a3b8; transition: color 0.2s;" onclick="togglePasswordVisibility('password', 'toggle-password')"></i>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="password_confirmation">Konfirmasi Sandi</label>
                        <div class="input-wrapper">
                            <i class="fa-solid fa-lock"></i>
                            <input type="password" name="password_confirmation" id="password_confirmation" placeholder="Ulangi sandi" required style="padding-right: 48px;">
                            <i class="fa-solid fa-eye" id="toggle-password-conf" style="position: absolute; right: 16px; left: auto; cursor: pointer; color: #94a3b8; transition: color 0.2s;" onclick="togglePasswordVisibility('password_confirmation', 'toggle-password-conf')"></i>
                        </div>
                    </div>
                </div>

                <div class="info-hint" style="margin-top: 4px; margin-bottom: 16px;">
                    <i class="fa-solid fa-circle-info"></i>
                    <span>Lisensi aktif selama 1 tahun gratis akan diterbitkan secara otomatis setelah pendaftaran.</span>
                </div>

                <button type="submit" class="btn-submit">
                    <i class="fa-solid fa-user-plus"></i>
                    <span>Daftar & Terbitkan Lisensi</span>
                </button>
            </form>

            <div class="auth-switch">
                Sudah punya akun member? <a href="{{ route('login') }}">Masuk di sini</a>
            </div>

            <div style="text-align:center;">
                <a href="/" class="back-home"><i class="fa-solid fa-arrow-left"></i> Kembali ke Beranda</a>
            </div>
        </div>
    </div>
    <script>
        function togglePasswordVisibility(fieldId, iconId) {
            const field = document.getElementById(fieldId);
            const icon = document.getElementById(iconId);
            if (field.type === 'password') {
                field.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                field.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }
    </script>
</body>
</html>
