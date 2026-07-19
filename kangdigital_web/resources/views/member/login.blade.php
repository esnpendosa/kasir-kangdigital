<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Member | Kang Digital</title>
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
            min-height: 620px;
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
            height: 330px;
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
            gap: 8px;
        }

        .inner-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .phone-badge {
            background-color: #ecfdf5;
            color: #059669;
            font-size: 8px;
            font-weight: 700;
            padding: 3px 8px;
            border-radius: 20px;
            display: flex;
            align-items: center;
            gap: 3px;
        }

        .phone-badge i {
            font-size: 7px;
        }

        .phone-avatar {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            object-fit: cover;
            border: 1px solid var(--accent-blue);
        }

        .total-balance-label {
            font-size: 9px;
            color: #94a3b8;
            font-weight: 600;
        }

        .total-balance-value {
            font-family: var(--font-heading);
            font-size: 18px;
            font-weight: 850;
            color: var(--primary);
        }

        .balance-change {
            font-size: 8px;
            font-weight: 700;
            color: var(--accent-green);
        }

        .mock-chart-card {
            background-color: #f8fafc;
            border-radius: 12px;
            padding: 8px;
            border: 1px solid #f1f5f9;
        }

        .mock-chart-title {
            font-size: 8px;
            color: #64748b;
            font-weight: 700;
            margin-bottom: 4px;
        }

        .mock-chart-line {
            height: 25px;
            background: linear-gradient(90deg, rgba(37, 99, 235, 0.1), rgba(37, 99, 235, 0.2));
            border-radius: 6px;
            position: relative;
            overflow: hidden;
            display: flex;
            align-items: flex-end;
        }

        .mock-chart-line::after {
            content: '';
            position: absolute;
            width: 100%;
            height: 2px;
            background-color: var(--accent-blue);
            top: 40%;
            left: 0;
        }

        .mock-items-list {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .mock-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #f8fafc;
            padding: 5px 8px;
            border-radius: 8px;
            font-size: 8px;
            border: 1px solid #f1f5f9;
        }

        .mock-item-name {
            font-weight: 600;
            color: var(--primary);
        }

        .mock-item-price {
            color: var(--accent-blue);
            font-weight: 700;
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
            margin-bottom: 20px;
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

        .auth-switch {
            text-align: center;
            margin-top: 28px;
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
            margin-top: 24px;
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
                <!-- Pure CSS Phone Mockup representing Android Pos app -->
                <div class="phone-frame">
                    <div class="phone-header">
                        <span>Kasir UMKM</span>
                        <div class="phone-badge">
                            <i class="fa-solid fa-circle-check"></i>
                            <span>Lisensi Aktif</span>
                        </div>
                    </div>
                    <div class="phone-inner">
                        <div class="inner-row" style="margin-top: 5px;">
                            <span class="total-balance-label">Total Penjualan</span>
                            <img src="https://api.dicebear.com/7.x/pixel-art/svg?seed=KD" class="phone-avatar" alt="User">
                        </div>
                        <div class="inner-row">
                            <span class="total-balance-value">Rp 8.420.000</span>
                            <span class="balance-change">+12.5%</span>
                        </div>
                        
                        <!-- Mock Chart widget -->
                        <div class="mock-chart-card">
                            <div class="mock-chart-title">Statistik Penjualan Harian</div>
                            <div class="mock-chart-line"></div>
                        </div>

                        <!-- Mock Items -->
                        <div class="mock-items-list">
                            <div class="mock-item">
                                <span class="mock-item-name">Kopi Susu Gula Aren</span>
                                <span class="mock-item-price">Rp 15.000</span>
                            </div>
                            <div class="mock-item">
                                <span class="mock-item-name">Roti Bakar Cokelat</span>
                                <span class="mock-item-price">Rp 18.000</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <p class="panel-left-footer">&copy; {{ date('Y') }} Kang Digital. Hak Cipta Dilindungi.</p>
        </div>

        <!-- Right Form Panel -->
        <div class="auth-panel-right">
            <h1>Login Member</h1>
            <p class="subtitle">Masuk dengan username akun Kasir UMKM Anda.</p>

            @if($errors->any())
                <div class="error-box">
                    <i class="fa-solid fa-circle-exclamation"></i>
                    <span>{{ $errors->first() }}</span>
                </div>
            @endif

            @if(session('success'))
                <div class="success-box">
                    <i class="fa-solid fa-circle-check"></i>
                    <span>{{ session('success') }}</span>
                </div>
            @endif

            <form action="{{ route('member.login.post') }}" method="POST">
                @csrf
                <div class="form-group">
                    <label for="username">Username Member</label>
                    <div class="input-wrapper">
                        <i class="fa-solid fa-user"></i>
                        <input type="text" name="username" id="username" placeholder="username_anda" value="{{ old('username') }}" required autofocus>
                    </div>
                </div>

                <div class="form-group">
                    <label for="password">Kata Sandi</label>
                    <div class="input-wrapper">
                        <i class="fa-solid fa-lock"></i>
                        <input type="password" name="password" id="password" placeholder="••••••••" required>
                    </div>
                </div>

                <button type="submit" class="btn-submit">
                    <i class="fa-solid fa-right-to-bracket"></i>
                    <span>Masuk ke Dashboard</span>
                </button>
            </form>

            <div class="auth-switch">
                Belum punya akun member? <a href="{{ route('member.register') }}">Daftar sekarang</a>
            </div>

            <div style="text-align:center;">
                <a href="/" class="back-home"><i class="fa-solid fa-arrow-left"></i> Kembali ke Beranda</a>
            </div>
        </div>
    </div>
</body>
</html>
