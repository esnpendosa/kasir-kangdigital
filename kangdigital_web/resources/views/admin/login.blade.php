<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Admin | Kang Digital</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --bg-color: #f8fafc;
            --surface-color: #ffffff;
            --surface-border: #e2e8f0;
            --primary: #2563eb;
            --primary-glow: rgba(37, 99, 235, 0.08);
            --text-main: #0f172a;
            --text-muted: #64748b;
            --font-sans: 'Plus Jakarta Sans', sans-serif;
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
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            overflow: hidden;
            position: relative;
        }

        .bg-glow {
            position: absolute;
            width: 600px;
            height: 600px;
            border-radius: 50%;
            background: radial-gradient(circle, var(--primary-glow) 0%, rgba(255,255,255,0) 70%);
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: -1;
            filter: blur(85px);
        }

        .login-card {
            width: 100%;
            max-width: 420px;
            background: var(--surface-color);
            border: 1px solid var(--surface-border);
            padding: 45px 35px;
            border-radius: 28px;
            box-shadow: 0 15px 35px rgba(15, 23, 42, 0.04);
            text-align: center;
        }

        .login-logo {
            font-size: 28px;
            font-weight: 800;
            background: linear-gradient(135deg, var(--primary), #0ea5e9);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 25px;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
        }

        .login-logo i {
            -webkit-text-fill-color: var(--primary);
        }

        .login-card h2 {
            font-size: 22px;
            margin-bottom: 8px;
            font-weight: 800;
            color: var(--text-main);
        }

        .login-card p {
            font-size: 14px;
            color: var(--text-muted);
            margin-bottom: 30px;
        }

        .form-group {
            text-align: left;
            margin-bottom: 20px;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .form-group label {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-muted);
        }

        .input-wrapper {
            position: relative;
        }

        .input-wrapper i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-muted);
        }

        .form-group input {
            width: 100%;
            background-color: var(--bg-color);
            border: 1px solid var(--surface-border);
            padding: 12px 15px 12px 45px;
            border-radius: 10px;
            color: var(--text-main);
            font-size: 14px;
            outline: none;
            transition: border-color 0.3s, background-color 0.3s;
        }

        .form-group input:focus {
            border-color: var(--primary);
            background-color: #ffffff;
        }

        .btn-login {
            width: 100%;
            background: linear-gradient(135deg, var(--primary), #1d4ed8);
            color: white;
            border: none;
            padding: 14px;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
            box-shadow: 0 4px 15px rgba(37, 99, 235, 0.2);
            margin-top: 10px;
        }

        .btn-login:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 20px rgba(37, 99, 235, 0.3);
        }

        .error-box {
            background-color: rgba(239, 68, 68, 0.08);
            border: 1px solid rgba(239, 68, 68, 0.2);
            color: #b91c1c;
            padding: 12px 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 13px;
            text-align: left;
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 600;
        }

        .back-home {
            display: inline-block;
            margin-top: 25px;
            font-size: 13px;
            color: var(--text-muted);
            text-decoration: none;
            transition: color 0.3s;
            font-weight: 600;
        }

        .back-home:hover {
            color: var(--primary);
        }
    </style>
</head>
<body>

    <div class="bg-glow"></div>

    <div class="login-card">
        <a href="/" class="login-logo" style="background: none; -webkit-text-fill-color: initial;">
            <img src="{{ asset('logo.png') }}" alt="Kang Digital Logo" style="height: 38px; width: 38px; border-radius: 8px; object-fit: cover; box-shadow: 0 2px 8px rgba(0,0,0,0.08);">
            <span style="background: linear-gradient(135deg, var(--primary), #0ea5e9); -webkit-background-clip: text; -webkit-text-fill-color: transparent; font-weight: 800; font-family: var(--font-sans);">Kang Digital</span>
        </a>
        <h2>Selamat Datang Kembali</h2>
        <p>Silakan masuk ke panel admin website</p>

        @if($errors->any())
            <div class="error-box">
                <i class="fa-solid fa-circle-exclamation" style="font-size: 16px;"></i>
                <span>{{ $errors->first() }}</span>
            </div>
        @endif

        <form action="{{ route('admin.login') }}" method="POST">
            @csrf
            <div class="form-group">
                <label for="email">Alamat Email</label>
                <div class="input-wrapper">
                    <i class="fa-solid fa-envelope"></i>
                    <input type="email" name="email" id="email" placeholder="admin@kangdigital.web.id" value="{{ old('email') }}" required autofocus>
                </div>
            </div>

            <div class="form-group">
                <label for="password">Kata Sandi</label>
                <div class="input-wrapper">
                    <i class="fa-solid fa-lock"></i>
                    <input type="password" name="password" id="password" placeholder="••••••••" required>
                </div>
            </div>

            <button type="submit" class="btn-login">Masuk ke Dashboard</button>
        </form>

        <a href="/" class="back-home"><i class="fa-solid fa-arrow-left"></i> Kembali ke Beranda</a>
    </div>

</body>
</html>
