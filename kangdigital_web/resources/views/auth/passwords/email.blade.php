<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password | Kang Digital</title>
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
            max-width: 1000px;
            min-height: 580px;
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
            width: 48%;
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
            margin: 30px 0;
            z-index: 5;
        }

        .phone-frame {
            width: 220px;
            height: 280px;
            background-color: #ffffff;
            border-radius: 28px;
            border: 7px solid #000000;
            box-shadow: 0 20px 40px rgba(0,0,0,0.25);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            padding: 16px;
            position: relative;
            justify-content: center;
            text-align: center;
        }

        .phone-icon-big {
            font-size: 44px;
            color: #f59e0b;
            margin-bottom: 12px;
            animation: float-slow 5s ease-in-out infinite;
        }

        .phone-welcome-title {
            font-family: var(--font-heading);
            font-size: 13px;
            font-weight: 800;
            color: var(--primary);
            margin-bottom: 6px;
        }

        .phone-welcome-desc {
            font-size: 8.5px;
            color: var(--text-muted);
            line-height: 1.4;
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
            padding: 56px 48px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .auth-panel-right h1 {
            font-family: var(--font-heading);
            font-size: 32px;
            font-weight: 900;
            color: var(--primary);
            margin-bottom: 8px;
            letter-spacing: -0.5px;
        }

        .subtitle {
            font-size: 14px;
            color: var(--text-muted);
            margin-bottom: 32px;
            line-height: 1.5;
        }

        .form-group {
            margin-bottom: 24px;
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
            padding: 14px 16px 14px 46px;
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

        .error-box {
            background: #fef2f2;
            border: 1px solid #fecaca;
            color: #b91c1c;
            padding: 14px 18px;
            border-radius: 12px;
            font-size: 13.5px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 24px;
        }

        .success-box {
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            color: #15803d;
            padding: 14px 18px;
            border-radius: 12px;
            font-size: 13.5px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 24px;
        }

        .btn-submit {
            width: 100%;
            background: linear-gradient(135deg, #2563eb, #1d4ed8);
            color: #ffffff;
            border: none;
            padding: 15px;
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
        }

        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(37, 99, 235, 0.3);
        }

        .back-login {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 13.5px;
            color: var(--accent-blue);
            text-decoration: none;
            margin-top: 24px;
            font-weight: 700;
            transition: all 0.2s;
        }

        .back-login:hover {
            color: #1d4ed8;
            transform: translateX(-3px);
        }

        @media (max-width: 860px) {
            .auth-panel-left {
                display: none;
            }
            .auth-panel-right {
                padding: 48px 32px;
            }
            .auth-wrapper {
                border-radius: 24px;
                max-width: 480px;
                min-height: auto;
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
                <div class="phone-frame">
                    <i class="fa-solid fa-shield-halved phone-icon-big"></i>
                    <span class="phone-welcome-title">Pemulihan Akun</span>
                    <p class="phone-welcome-desc">Proses verifikasi email aman untuk memperbarui sandi akun kasir Anda.</p>
                </div>
            </div>

            <p class="panel-left-footer">&copy; {{ date('Y') }} Kang Digital. Hak Cipta Dilindungi.</p>
        </div>

        <!-- Right Form Panel -->
        <div class="auth-panel-right">
            <h1>Lupa Kata Sandi</h1>
            <p class="subtitle">Sistem akan memverifikasi email Anda dan memberikan password akses baru.</p>

            @if($errors->any())
                <div class="error-box">
                    <i class="fa-solid fa-circle-exclamation"></i>
                    <span>{{ $errors->first() }}</span>
                </div>
            @endif

            @if(session('success'))
                <div class="success-box">
                    <i class="fa-solid fa-circle-check"></i>
                    <span>{!! session('success') !!}</span>
                </div>
            @endif

            <form action="{{ route('password.reset.post') }}" method="POST">
                @csrf
                <div class="form-group">
                    <label for="email">Alamat Email Terdaftar</label>
                    <div class="input-wrapper">
                        <i class="fa-solid fa-envelope"></i>
                        <input type="email" name="email" id="email" placeholder="nama@email.com" value="{{ old('email') }}" required autofocus>
                    </div>
                </div>

                <button type="submit" class="btn-submit">
                    <i class="fa-solid fa-paper-plane"></i>
                    <span>Reset Password Saya</span>
                </button>
            </form>

            <div style="text-align:center;">
                <a href="{{ route('login') }}" class="back-login"><i class="fa-solid fa-arrow-left"></i> Kembali ke Halaman Login</a>
            </div>
        </div>
    </div>
</body>
</html>
