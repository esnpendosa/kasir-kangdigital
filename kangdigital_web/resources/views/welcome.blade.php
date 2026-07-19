<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="{{ $seo['description'] }}">
    <meta name="keywords" content="{{ $seo['keywords'] }}">
    <title>{{ $seo['title'] }}</title>
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Outfit:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    
    <!-- FontAwesome for Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Premium Light-Theme CSS Styles (Inspired by BLUEPEAK/Monie Layout) -->
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

        html {
            scroll-behavior: smooth;
        }

        body {
            font-family: var(--font-sans);
            background-color: var(--bg-color);
            color: var(--text-main);
            overflow-x: hidden;
            line-height: 1.6;
        }

        /* Floating Decoration Shapes */
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

        /* Header Navigation */
        header {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            padding: 22px 8%;
            background: rgba(252, 252, 253, 0.85);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            z-index: 100;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid rgba(15, 23, 42, 0.04);
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
        }

        .logo img {
            height: 36px;
            width: 36px;
            border-radius: 8px;
            object-fit: cover;
            box-shadow: 0 4px 10px rgba(15, 23, 42, 0.05);
        }

        .logo span {
            font-family: var(--font-heading);
            font-size: 22px;
            font-weight: 800;
            color: var(--primary);
            letter-spacing: -0.5px;
        }

        nav a {
            color: #475569;
            text-decoration: none;
            margin: 0 16px;
            font-weight: 600;
            font-size: 14px;
            transition: color 0.2s;
        }

        nav a:hover {
            color: var(--accent-blue);
        }

        .btn-header-login {
            border: 1.5px solid var(--primary);
            color: var(--primary);
            background: transparent;
            padding: 9px 24px;
            border-radius: 50px;
            font-weight: 700;
            font-size: 13px;
            text-decoration: none;
            transition: all 0.2s;
        }

        .btn-header-login:hover {
            background-color: var(--primary);
            color: #ffffff;
        }

        /* Hero Section */
        .hero {
            padding: 180px 8% 100px 8%;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 80px;
            position: relative;
        }

        .hero-content {
            flex: 1.1;
        }

        .hero-badge {
            background: #f1f5f9;
            color: #475569;
            padding: 6px 16px;
            border-radius: 50px;
            font-size: 12px;
            font-weight: 700;
            display: inline-block;
            margin-bottom: 25px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .hero-content h1 {
            font-family: var(--font-heading);
            font-size: 58px;
            font-weight: 900;
            line-height: 1.15;
            color: var(--primary);
            margin-bottom: 25px;
            letter-spacing: -1.5px;
        }

        /* Handwritten-style Underline Highlight */
        .highlight-accent {
            position: relative;
            display: inline-block;
        }

        .highlight-accent::after {
            content: "";
            position: absolute;
            left: 0;
            bottom: -6px;
            width: 100%;
            height: 8px;
            background-image: url("data:image/svg+xml,%3Csvg width='100' height='8' viewBox='0 0 100 8' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M2 6C20 3 60 1 98 5' stroke='%232563eb' stroke-width='3' stroke-linecap='round'/%3E%3C/svg%3E");
            background-size: 100% 100%;
            z-index: -1;
        }

        .hero-content p {
            font-size: 16px;
            color: var(--text-muted);
            margin-bottom: 35px;
            max-width: 540px;
            line-height: 1.7;
        }

        .hero-actions {
            display: flex;
            align-items: center;
            gap: 25px;
            flex-wrap: wrap;
        }

        .btn-black-pill {
            background-color: var(--primary);
            color: #ffffff;
            padding: 16px 36px;
            border-radius: 50px;
            font-weight: 700;
            font-size: 15px;
            text-decoration: none;
            transition: transform 0.2s, box-shadow 0.2s;
            box-shadow: 0 4px 14px rgba(15, 23, 42, 0.15);
        }

        .btn-black-pill:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(15, 23, 42, 0.25);
        }

        /* Avatar Group */
        .avatar-group-container {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .avatar-group {
            display: flex;
            align-items: center;
        }

        .avatar-group img, .avatar-group .avatar-plus {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            border: 3px solid #ffffff;
            margin-left: -12px;
            object-fit: cover;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 11px;
            font-weight: 700;
            color: #ffffff;
        }

        .avatar-group img:first-child {
            margin-left: 0;
        }

        .avatar-group .avatar-plus {
            background-color: var(--accent-blue);
            box-shadow: 0 2px 8px rgba(37, 99, 235, 0.2);
        }

        /* Hero Right Area: Premium Card Graphics */
        .hero-image-area {
            flex: 0.9;
            position: relative;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 480px;
        }

        /* Rounded Peach Background Card */
        .peach-card {
            width: 280px;
            height: 380px;
            background-color: #fff7ed;
            border-radius: 36px;
            position: absolute;
            left: 20px;
            top: 20px;
            display: flex;
            justify-content: center;
            align-items: flex-end;
            padding-bottom: 25px;
            box-shadow: 0 20px 40px rgba(249, 115, 22, 0.03);
            transform: rotate(-3deg);
        }

        /* Simulated Phone Frame */
        .phone-frame {
            width: 230px;
            height: 340px;
            background-color: #ffffff;
            border-radius: 28px;
            border: 8px solid #000000;
            box-shadow: 0 20px 40px rgba(0,0,0,0.06);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            padding: 14px;
        }

        .phone-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 9px;
            color: #94a3b8;
            font-weight: 700;
            margin-bottom: 12px;
        }

        .phone-inner {
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .inner-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .phone-badge {
            background-color: #f1f5f9;
            color: #475569;
            font-size: 9px;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 20px;
        }

        .phone-avatar {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            object-fit: cover;
        }

        .total-balance-label {
            font-size: 10px;
            color: #94a3b8;
            margin-top: 15px;
            font-weight: 600;
        }

        .total-balance-value {
            font-family: var(--font-heading);
            font-size: 24px;
            font-weight: 900;
            color: var(--primary);
            margin-top: 2px;
        }

        .balance-change {
            font-size: 9px;
            font-weight: 700;
            color: var(--accent-green);
            margin-top: 2px;
        }

        .inner-rate-card {
            background-color: #ffedd5;
            border-radius: 16px;
            padding: 12px;
            margin-top: auto;
        }

        .rate-arrow {
            width: 20px;
            height: 20px;
            background-color: #ffffff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 8px;
            color: var(--accent-orange);
        }

        /* Floating chart card */
        .chart-card {
            position: absolute;
            right: 20px;
            top: 60px;
            width: 220px;
            background-color: #ffffff;
            border-radius: 24px;
            border: 1px solid #f1f5f9;
            padding: 20px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.04);
            transform: rotate(3deg);
        }

        .chart-svg {
            width: 100%;
            height: auto;
            margin-top: 10px;
        }

        /* Section Layouts */
        .section {
            padding: 100px 8%;
            position: relative;
        }

        .section-header {
            text-align: center;
            margin-bottom: 60px;
        }

        .section-header h2 {
            font-family: var(--font-heading);
            font-size: 38px;
            font-weight: 900;
            color: var(--primary);
            letter-spacing: -1px;
            margin-bottom: 15px;
        }

        .section-header p {
            font-size: 15px;
            color: var(--text-muted);
            max-width: 600px;
            margin: 0 auto;
        }

        /* Features/Services Cards */
        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 35px;
        }

        .feature-card {
            background-color: #ffffff;
            border: 1px solid #f1f5f9;
            padding: 45px 35px;
            border-radius: 28px;
            transition: all 0.3s;
            position: relative;
        }

        .feature-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.02);
            border-color: #e2e8f0;
        }

        .card-icon-wrapper {
            width: 48px;
            height: 48px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            margin-bottom: 25px;
        }

        .icon-orange { background-color: #fff7ed; color: var(--accent-orange); }
        .icon-blue { background-color: #eff6ff; color: var(--accent-blue); }
        .icon-pink { background-color: #fdf2f8; color: var(--accent-pink); }

        .feature-card h3 {
            font-family: var(--font-heading);
            font-size: 22px;
            font-weight: 800;
            color: var(--primary);
            margin-bottom: 15px;
        }

        .feature-card p {
            color: var(--text-muted);
            font-size: 14px;
            line-height: 1.6;
            margin-bottom: 25px;
        }

        .feature-card-link {
            font-size: 14px;
            font-weight: 700;
            color: var(--primary);
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: gap 0.2s;
        }

        .feature-card-link:hover {
            gap: 12px;
        }

        /* Section: Stats & Dashboard Mockup */
        .stats-section {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 80px;
        }

        .stats-image-area {
            flex: 0.95;
            position: relative;
            display: flex;
            justify-content: center;
        }

        .stats-content {
            flex: 1.05;
        }

        .stats-list {
            display: flex;
            gap: 45px;
            margin-top: 40px;
            flex-wrap: wrap;
        }

        .stat-item h4 {
            font-family: var(--font-heading);
            font-size: 38px;
            font-weight: 900;
            color: var(--primary);
            margin-bottom: 5px;
        }

        .stat-item p {
            font-size: 13px;
            color: var(--text-muted);
            font-weight: 700;
        }

        /* Dashboard Mockup Widget */
        .dash-widget {
            background-color: #ffffff;
            border: 1px solid #f1f5f9;
            border-radius: 24px;
            padding: 25px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.03);
            width: 100%;
            max-width: 440px;
        }

        /* Section: Detail Features Grid */
        .detail-section {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 80px;
        }

        .detail-content {
            flex: 1;
        }

        .detail-grid-area {
            flex: 1;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        /* Partners Logo List */
        .partners-section {
            padding: 60px 8%;
            border-top: 1px solid #f1f5f9;
            border-bottom: 1px solid #f1f5f9;
            background-color: #fbfbfd;
            text-align: center;
        }

        .partners-title {
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            color: #94a3b8;
            font-weight: 700;
            margin-bottom: 30px;
        }

        .partners-logos {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 60px;
            flex-wrap: wrap;
            opacity: 0.65;
        }

        .partners-logos span {
            font-size: 18px;
            color: #64748b;
            font-weight: 800;
            font-family: var(--font-heading);
            letter-spacing: -0.5px;
        }

        /* Testimonial Section */
        .testimonial-card {
            background-color: #ffffff;
            border: 1px solid #f1f5f9;
            padding: 50px 40px;
            border-radius: 32px;
            max-width: 800px;
            margin: 0 auto;
            text-align: center;
            box-shadow: 0 15px 35px rgba(0,0,0,0.02);
        }

        .testimonial-rating {
            color: #fbbf24;
            font-size: 18px;
            margin-bottom: 25px;
        }

        .testimonial-quote {
            font-size: 20px;
            font-weight: 600;
            line-height: 1.6;
            color: var(--primary);
            margin-bottom: 30px;
        }

        .testimonial-profile {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 15px;
        }

        .testimonial-profile img {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            object-fit: cover;
        }

        /* Order / Inquiry Form Section */
        .contact-container {
            max-width: 900px;
            margin: 0 auto;
            background: #ffffff;
            border: 1px solid #f1f5f9;
            padding: 50px;
            border-radius: 32px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.02);
        }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 25px;
            margin-bottom: 25px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .form-group-full {
            grid-column: span 2;
        }

        .form-group label {
            font-size: 13px;
            font-weight: 700;
            color: var(--primary);
        }

        .form-group input, .form-group textarea {
            background-color: #f8fafc;
            border: 1.5px solid #e2e8f0;
            padding: 14px 20px;
            border-radius: 12px;
            color: var(--text-main);
            font-family: var(--font-sans);
            font-size: 14px;
            outline: none;
            transition: all 0.3s;
        }

        .form-group input:focus, .form-group textarea:focus {
            border-color: var(--primary);
            background-color: #ffffff;
        }

        .form-group textarea {
            resize: vertical;
            min-height: 120px;
        }

        .btn-submit {
            background-color: var(--primary);
            color: white;
            border: none;
            padding: 16px 40px;
            font-size: 15px;
            font-weight: 700;
            border-radius: 50px;
            cursor: pointer;
            width: 100%;
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
        }

        /* Success Alert */
        .alert-success {
            background: rgba(16, 185, 129, 0.08);
            border: 1px solid var(--accent-green);
            color: #065f46;
            padding: 16px 24px;
            border-radius: 12px;
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 14px;
            font-weight: 700;
        }

        /* Local SEO Links directory block */
        .local-seo-section {
            background-color: #ffffff;
            border-top: 1px solid #f1f5f9;
            padding: 60px 8%;
        }

        .local-seo-title {
            font-family: var(--font-heading);
            font-size: 18px;
            font-weight: 800;
            margin-bottom: 25px;
            color: var(--primary);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .local-seo-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 15px;
        }

        .local-seo-link {
            font-size: 13px;
            color: var(--text-muted);
            text-decoration: none;
            transition: color 0.2s;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .local-seo-link:hover {
            color: var(--accent-blue);
        }

        /* Floating WhatsApp Icon */
        .whatsapp-float {
            position: fixed;
            bottom: 30px;
            right: 30px;
            background-color: #25d366;
            color: white;
            width: 58px;
            height: 58px;
            border-radius: 50px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            box-shadow: 0 6px 20px rgba(37, 211, 102, 0.25);
            z-index: 99;
            transition: transform 0.3s;
        }

        .whatsapp-float:hover {
            transform: scale(1.1);
        }

        /* Footer */
        footer {
            background-color: #0f172a;
            color: #94a3b8;
            padding: 80px 8% 40px 8%;
            border-top: 1px solid #1e293b;
            font-size: 14px;
        }

        .footer-grid {
            display: grid;
            grid-template-columns: 2fr 1fr 1.2fr;
            gap: 60px;
            margin-bottom: 60px;
        }

        .footer-brand h3 {
            font-family: var(--font-heading);
            font-size: 24px;
            font-weight: 800;
            color: #ffffff;
            margin-bottom: 18px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .footer-brand h3 img {
            height: 32px;
            width: 32px;
            border-radius: 6px;
            object-fit: cover;
        }

        .footer-brand p {
            line-height: 1.7;
            max-width: 340px;
            color: #94a3b8;
        }

        .footer-col h4 {
            font-family: var(--font-heading);
            color: #ffffff;
            font-size: 15px;
            font-weight: 700;
            margin-bottom: 25px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .footer-col ul {
            list-style: none;
        }

        .footer-col ul li {
            margin-bottom: 12px;
        }

        .footer-col ul li a {
            color: #94a3b8;
            text-decoration: none;
            transition: color 0.2s;
            font-weight: 500;
        }

        .footer-col ul li a:hover {
            color: #ffffff;
        }

        .footer-contact-item {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 15px;
            color: #94a3b8;
        }

        .footer-contact-item i {
            color: var(--accent-blue);
            font-size: 16px;
            width: 16px;
            text-align: center;
        }

        .footer-bottom {
            border-top: 1px solid #1e293b;
            padding-top: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }

        .footer-bottom p {
            font-size: 13px;
        }

        .footer-links {
            display: flex;
            gap: 20px;
        }

        .footer-links a {
            color: #64748b;
            text-decoration: none;
            font-size: 13px;
            transition: color 0.2s;
        }

        .footer-links a:hover {
            color: #94a3b8;
        }

        /* Responsiveness */
        @media (max-width: 992px) {
            .hero {
                flex-direction: column;
                text-align: center;
                padding-top: 140px;
                gap: 50px;
            }
            .hero-content h1 {
                font-size: 42px;
            }
            .hero-content p {
                margin: 0 auto 35px;
            }
            .hero-actions {
                justify-content: center;
            }
            .hero-image-area {
                height: 400px;
                width: 100%;
            }
            .stats-section, .detail-section {
                flex-direction: column;
                gap: 50px;
            }
            .stats-image-area, .detail-grid-area {
                justify-content: center;
                width: 100%;
            }
        }

        @media (max-width: 768px) {
            header {
                padding: 15px 5%;
            }
            nav {
                display: none;
            }
            .form-grid {
                grid-template-columns: 1fr;
            }
            .form-group-full {
                grid-column: span 1;
            }
        }
    </style>
</head>
<body>

    <!-- Floating Shapes for Background Deco -->
    <div class="shape-triangle" style="top: 220px; left: 10%;"></div>
    <div class="shape-circle" style="top: 150px; right: 8%;"></div>
    <div class="shape-dots" style="bottom: 10%; left: 5%;"></div>

    <!-- Header Navigation -->
    <header>
        <a href="#" class="logo">
            <img src="{{ asset('logo.png') }}" alt="Kang Digital Logo">
            <span>Kang Digital</span>
        </a>
        <nav>
            <a href="#services">Layanan</a>
            <a href="#kasir">Kasir UMKM</a>
            <a href="#about">Tentang</a>
            <a href="#order">Pemesanan</a>
        </nav>
        <a href="{{ route('login') }}" class="btn-header-login">Login</a>
    </header>

    <!-- Hero Section -->
    <section class="hero">
        <div class="hero-content">
            <span class="hero-badge">Jasa Pembuatan Website & Aplikasi</span>
            <h1>{!! $seo['headline'] !!}</h1>
            <p>{{ $seo['description_content'] }}</p>
            <div class="hero-actions">
                <a href="#order" class="btn-black-pill">Mulai Sekarang</a>
                <div class="avatar-group-container">
                    <div class="avatar-group">
                        <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80&fit=crop&q=60" alt="User 1">
                        <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&fit=crop&q=60" alt="User 2">
                        <img src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&fit=crop&q=60" alt="User 3">
                        <div class="avatar-plus">+12</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="hero-image-area">
            <!-- Rounded Peach Card Graphic -->
            <div class="peach-card">
                <!-- Phone Mockup Frame -->
                <div class="phone-frame">
                    <div class="phone-header">
                        <span>7:44</span>
                        <div style="display:flex; gap:4px;">
                            <i class="fa-solid fa-wifi"></i>
                            <i class="fa-solid fa-battery-full"></i>
                        </div>
                    </div>
                    <div class="phone-inner">
                        <div class="inner-row">
                            <span class="phone-badge">Savings</span>
                            <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80&fit=crop&q=60" class="phone-avatar" alt="User">
                        </div>
                        <div>
                            <div class="total-balance-label">Total Balance</div>
                            <div class="total-balance-value">Rp 33.600k</div>
                            <div class="balance-change">+5.4%</div>
                        </div>
                        <div class="inner-rate-card">
                            <div style="display:flex; justify-content:space-between; align-items:center;">
                                <span style="font-size:10px; font-weight:700; color:#4b5563;">Transaction Rate</span>
                                <div class="rate-arrow"><i class="fa-solid fa-arrow-up-right"></i></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- Floating Transaction line chart -->
            <div class="chart-card">
                <div style="display:flex; justify-content:space-between; align-items:center;">
                    <div>
                        <div style="font-size:11px; font-weight:800; color:var(--primary);">Transaction</div>
                        <div style="font-size:9px; color:#94a3b8; font-weight:600;">Target Goal</div>
                    </div>
                    <i class="fa-solid fa-ellipsis" style="color:#cbd5e1; font-size:12px;"></i>
                </div>
                <div style="font-size:9px; color:#ef4444; font-weight:700; margin-top:8px;">22 Oct-21 Nov +2.5%</div>
                <div style="font-size:10px; font-weight:700; color:var(--primary); margin-top:12px;">Progress Chart</div>
                <svg viewBox="0 0 100 42" class="chart-svg">
                    <path d="M 0 35 Q 20 20 40 28 T 80 10 T 100 15" fill="none" stroke="#2563eb" stroke-width="2.5" stroke-linecap="round" />
                    <circle cx="80" cy="10" r="3.5" fill="#2563eb" />
                    <path d="M 0 35 Q 20 20 40 28 T 80 10 T 100 15 L 100 42 L 0 42 Z" fill="url(#chart-grad)" opacity="0.1" />
                    <defs>
                        <linearGradient id="chart-grad" x1="0" y1="0" x2="0" y2="1">
                            <stop offset="0%" stop-color="#2563eb" />
                            <stop offset="100%" stop-color="#ffffff" />
                        </linearGradient>
                    </defs>
                </svg>
            </div>
        </div>
    </section>

    <!-- Services / Popular Features Section -->
    <section class="section" id="services">
        <div class="section-header">
            <h2>Layanan Populer Kami</h2>
            <p>Kami menghadirkan solusi teknologi digital terpercaya untuk pengembangan produk IT, optimasi sistem bisnis, serta digitalisasi toko retail UMKM.</p>
        </div>

        <div class="features-grid">
            @forelse($services as $key => $service)
                @php
                    $colors = ['icon-orange', 'icon-blue', 'icon-pink'];
                    $colorClass = $colors[$key % count($colors)];
                @endphp
                <div class="feature-card">
                    <div class="card-icon-wrapper {{ $colorClass }}">
                        @if($service->icon == 'globe')
                            <i class="fa-solid fa-globe"></i>
                        @elseif($service->icon == 'smartphone')
                            <i class="fa-solid fa-mobile-screen-button"></i>
                        @elseif($service->icon == 'shopping-cart')
                            <i class="fa-solid fa-cart-shopping"></i>
                        @else
                            <i class="fa-solid fa-chart-line"></i>
                        @endif
                    </div>
                    <h3>{{ $service->title }}</h3>
                    <p>{{ $service->description }}</p>
                    <a href="#order" class="feature-card-link">Pelajari Selengkapnya <i class="fa-solid fa-arrow-right"></i></a>
                </div>
            @empty
                <p style="grid-column: span 3; text-align: center; color: var(--text-muted);">Layanan sedang disiapkan.</p>
            @endforelse
        </div>
    </section>

    <!-- Stats & Web Dashboard Section -->
    <section class="section" id="about" style="background-color: #fbfbfd; border-top: 1px solid #f1f5f9; border-bottom: 1px solid #f1f5f9;">
        <div class="stats-section">
            <div class="stats-image-area">
                <!-- Custom Dashboard UI Mock Widget -->
                <div class="dash-widget">
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 20px;">
                        <span style="font-size: 13px; font-weight:800; color:var(--primary);">Cashier Management</span>
                        <span style="font-size: 11px; color:#3b82f6; font-weight:700;">This Week <i class="fa-solid fa-chevron-down" style="font-size:8px;"></i></span>
                    </div>
                    
                    <div style="background-color:#f8fafc; border-radius:16px; padding:15px; display:flex; justify-content:space-between; align-items:center; margin-bottom: 18px;">
                        <div>
                            <div style="font-size: 10px; color:#64748b; font-weight:600;">Total Omset</div>
                            <div style="font-size: 18px; font-weight:900; color:var(--primary);">Rp 15.420.500</div>
                        </div>
                        <div style="background-color:#10b981; color:#ffffff; font-size: 9px; font-weight:700; padding: 4px 10px; border-radius:20px;">+18%</div>
                    </div>
                    
                    <div style="font-size:11px; font-weight:700; color:#475569; margin-bottom: 12px;">Transaksi Terakhir</div>
                    
                    <div style="display:flex; flex-direction:column; gap:12px;">
                        <div style="display:flex; justify-content:space-between; align-items:center;">
                            <div style="display:flex; align-items:center; gap:10px;">
                                <div style="width:30px; height:30px; border-radius:50%; background-color:#eff6ff; display:flex; align-items:center; justify-content:center; color:#3b82f6; font-size:11px;"><i class="fa-solid fa-cart-shopping"></i></div>
                                <div>
                                    <div style="font-size:11px; font-weight:700; color:var(--primary);">Resto Bakso Kita</div>
                                    <div style="font-size: 8px; color:#94a3b8;">14:32 WIB</div>
                                </div>
                            </div>
                            <span style="font-size:11px; font-weight:800; color:#10b981;">+Rp 120.000</span>
                        </div>
                        
                        <div style="display:flex; justify-content:space-between; align-items:center;">
                            <div style="display:flex; align-items:center; gap:10px;">
                                <div style="width:30px; height:30px; border-radius:50%; background-color:#fff7ed; display:flex; align-items:center; justify-content:center; color:#f97316; font-size:11px;"><i class="fa-solid fa-store"></i></div>
                                <div>
                                    <div style="font-size:11px; font-weight:700; color:var(--primary);">Toko Kelontong Berkah</div>
                                    <div style="font-size: 8px; color:#94a3b8;">12:05 WIB</div>
                                </div>
                            </div>
                            <span style="font-size:11px; font-weight:800; color:#10b981;">+Rp 45.000</span>
                        </div>
                        
                        <div style="display:flex; justify-content:space-between; align-items:center;">
                            <div style="display:flex; align-items:center; gap:10px;">
                                <div style="width:30px; height:30px; border-radius:50%; background-color:#fdf2f8; display:flex; align-items:center; justify-content:center; color:#ec4899; font-size:11px;"><i class="fa-solid fa-mug-hot"></i></div>
                                <div>
                                    <div style="font-size:11px; font-weight:700; color:var(--primary);">Kopi Santai</div>
                                    <div style="font-size: 8px; color:#94a3b8;">09:12 WIB</div>
                                </div>
                            </div>
                            <span style="font-size:11px; font-weight:800; color:#10b981;">+Rp 85.000</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="stats-content">
                <span class="hero-badge" style="background:#eff6ff; color:var(--accent-blue);">SISTEM MANAJEMEN DIGITAL</span>
                <h2 style="font-family:var(--font-heading); font-size:36px; font-weight:900; line-height:1.2; margin-bottom:20px; color:var(--primary);">Optimalkan Manajemen Penjualan Bisnis Anda</h2>
                <p style="color:var(--text-muted); font-size:15px; line-height:1.7;">
                    Kelola data produk, catat transaksi secara realtime, dan pantau perkembangan keuangan outlet retail/UMKM Anda dalam satu platform yang terintegrasi penuh. Sistem offline-first handal kami tetap dapat diakses kapan saja tanpa koneksi internet, lalu disinkronkan secara aman ketika terhubung.
                </p>
                <div class="stats-list">
                    <div class="stat-item">
                        <h4>7+</h4>
                        <p>Tahun Pengalaman</p>
                    </div>
                    <div class="stat-item">
                        <h4>300+</h4>
                        <p>Lisensi Aktif</p>
                    </div>
                    <div class="stat-item">
                        <h4>2K+</h4>
                        <p>Mitra Mitra UMKM</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Detailed Features Grid Section -->
    <section class="section" id="kasir">
        <div class="detail-section">
            <div class="detail-content">
                <span class="hero-badge" style="background:#fdf2f8; color:var(--accent-pink);">ANDROID POS PLATFORM</span>
                <h2 style="font-family:var(--font-heading); font-size:36px; font-weight:900; line-height:1.2; margin-bottom:20px; color:var(--primary);">Identifikasi & Catat Semua Transaksi Praktis</h2>
                <p style="color:var(--text-muted); font-size:15px; line-height:1.7; margin-bottom:30px;">
                    Sistem aplikasi kasir kami dikembangkan secara native untuk Android menggunakan database SQLite lokal guna menjamin performa cepat, efisiensi resource handphone, serta proteksi data transaksi offline secara penuh.
                </p>
                <a href="#order" class="btn-black-pill" style="display:inline-block;">Unduh Aplikasi</a>
            </div>
            <div class="detail-grid-area">
                <!-- Circular saving target -->
                <div style="background-color:#ffffff; border:1px solid #f1f5f9; border-radius:24px; padding:20px; box-shadow:0 10px 30px rgba(0,0,0,0.02); text-align:center; display:flex; flex-direction:column; align-items:center;">
                    <div style="font-size:11px; font-weight:700; color:#64748b; margin-bottom:12px;">Pencapaian Target</div>
                    <div style="position:relative; width:70px; height:70px; margin-bottom:12px; display:flex; align-items:center; justify-content:center;">
                        <svg viewBox="0 0 36 36" style="width:70px; height:70px;">
                            <path d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" fill="none" stroke="#e2e8f0" stroke-width="3" />
                            <path d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" fill="none" stroke="#2563eb" stroke-dasharray="75, 100" stroke-width="3" stroke-linecap="round" />
                        </svg>
                        <span style="position:absolute; font-size:12px; font-weight:900; color:var(--primary);">75%</span>
                    </div>
                    <div style="font-size:10px; color:#94a3b8; font-weight:700;">Selengkapnya <i class="fa-solid fa-chevron-right" style="font-size:6px;"></i></div>
                </div>

                <!-- Print feature icon card -->
                <div style="background-color:#ffffff; border:1px solid #f1f5f9; border-radius:24px; padding:20px; box-shadow:0 10px 30px rgba(0,0,0,0.02); text-align:center; display:flex; flex-direction:column; align-items:center; justify-content:center;">
                    <div style="width:40px; height:40px; border-radius:50%; background-color:#f0fdf4; display:flex; align-items:center; justify-content:center; color:#10b981; font-size:18px; margin-bottom:12px;"><i class="fa-solid fa-money-bill-wave"></i></div>
                    <div style="font-size:12px; font-weight:800; color:var(--primary);">Cetak Struk</div>
                    <div style="font-size:9px; color:#64748b; margin-top:4px; font-weight:600;">Koneksi Bluetooth</div>
                </div>

                <!-- Blue payment mockup card -->
                <div style="background-color:#2563eb; color:#ffffff; border-radius:24px; padding:20px; box-shadow:0 10px 30px rgba(37,99,235,0.15);">
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:30px;">
                        <i class="fa-solid fa-shield-halved" style="font-size:18px;"></i>
                        <span style="font-size:8px; letter-spacing:1px; font-weight:700;">SECURE</span>
                    </div>
                    <div style="font-size:8px; opacity:0.8; margin-bottom:2px; font-weight:700;">KANG DIGITAL</div>
                    <div style="font-size:12px; font-weight:700; letter-spacing:1px;">•••• 5882</div>
                </div>

                <!-- User profile card -->
                <div style="background-color:#ffffff; border:1px solid #f1f5f9; border-radius:24px; padding:15px; box-shadow:0 10px 30px rgba(0,0,0,0.02); display:flex; align-items:center; gap:10px; justify-content:center;">
                    <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&fit=crop&q=60" style="width:36px; height:36px; border-radius:50%; object-fit:cover;" alt="User">
                    <div style="text-align:left;">
                        <div style="font-size:11px; font-weight:800; color:var(--primary);">Budi Santoso</div>
                        <div style="font-size:8px; color:#94a3b8; font-weight:600;">Merchant Member</div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Partners Logo Section -->
    <section class="partners-section">
        <div class="partners-title">Teknologi & Infrastruktur yang Kami Gunakan</div>
        <div class="partners-logos">
            <span>Laravel</span>
            <span>Flutter</span>
            <span>SQLite</span>
            <span>Hostinger Cloud</span>
            <span>Tailwind CSS</span>
            <span>MySQL</span>
        </div>
    </section>

    <!-- Testimonial Section -->
    <section class="section" style="background-color: #fcfcfd;">
        <div class="testimonial-card">
            <div class="testimonial-rating">
                <i class="fa-solid fa-star"></i>
                <i class="fa-solid fa-star"></i>
                <i class="fa-solid fa-star"></i>
                <i class="fa-solid fa-star"></i>
                <i class="fa-solid fa-star"></i>
            </div>
            <p class="testimonial-quote">
                "Menggunakan sistem kasir dari Kang Digital sangat mempermudah operasional kafe kami. Transaksi tetap lancar dicatat meskipun internet mati karena sistem offline-first, dan struk belanjaan langsung tercetak rapi dari printer thermal bluetooth."
            </p>
            <div class="testimonial-profile">
                <img src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&fit=crop&q=60" alt="Client Avatar">
                <div style="text-align:left;">
                    <div style="font-size:14px; font-weight:800; color:var(--primary);">Joko Susilo</div>
                    <div style="font-size:11px; color:var(--text-muted); font-weight:600;">Owner Resto & Cafe</div>
                </div>
            </div>
        </div>
    </section>

    <!-- Pemesanan Form Section -->
    <section class="section" id="order">
        <div class="section-header">
            <h2>Hubungi Kami & Pemesanan</h2>
            <p>Tertarik memesan layanan pembuatan website, aplikasi Android custom, atau membutuhkan lisensi sistem Kasir UMKM? Isi formulir di bawah ini.</p>
        </div>

        <div class="contact-container">
            @if(session('success'))
                <div class="alert-success">
                    <i class="fa-solid fa-circle-check" style="font-size: 20px;"></i>
                    <span>{{ session('success') }}</span>
                </div>
            @endif

            <form id="order-form" action="{{ route('lead.store') }}" method="POST">
                @csrf
                <div class="form-grid">
                    <div class="form-group">
                        <label for="name">Nama Lengkap</label>
                        <input type="text" name="name" id="name" placeholder="Masukkan nama Anda" required>
                    </div>
                    <div class="form-group">
                        <label for="email">Alamat Email</label>
                        <input type="email" name="email" id="email" placeholder="nama@email.com" required>
                    </div>
                    <div class="form-group">
                        <label for="phone">Nomor Telepon (WhatsApp)</label>
                        <input type="text" name="phone" id="phone" placeholder="Contoh: 081234567890" required>
                    </div>
                    <div class="form-group">
                        <label for="service_type">Layanan yang Diminati</label>
                        <input type="text" name="service_type" id="service_type" placeholder="Contoh: Website / Aplikasi / Lisensi Kasir" required>
                    </div>
                    <div class="form-group form-group-full">
                        <label for="message">Detail Kebutuhan / Pesan Anda</label>
                        <textarea name="message" id="message" placeholder="Tuliskan spesifikasi website, aplikasi, atau kendala bisnis yang ingin Anda solusikan..." required></textarea>
                    </div>
                </div>
                <button type="submit" class="btn-submit">Kirim Permintaan Pemesanan</button>
            </form>
        </div>
    </section>

    <!-- Localized Geo SEO directory links (Geo AIO) -->
    <section class="local-seo-section" style="background-color: #ffffff; border-top: 1px solid #f1f5f9; padding: 80px 8%; text-align: center;">
        <div style="max-width: 700px; margin: 0 auto;">
            <span class="hero-badge" style="background:#eff6ff; color:var(--accent-blue);">CAKUPAN LAYANAN</span>
            <h2 style="font-family: var(--font-heading); font-size: 36px; font-weight: 900; color: var(--primary); margin-bottom: 20px; letter-spacing: -1px;">
                Melayani Jasa IT & Kasir di <span class="highlight-accent">Seluruh Indonesia</span>
            </h2>
            <p style="color: var(--text-muted); font-size: 15px; line-height: 1.8; margin-bottom: 30px;">
                Kami menghadirkan layanan pembuatan website profesional, pengembangan aplikasi kustom, dan penyediaan lisensi sistem Kasir UMKM untuk pelaku usaha di seluruh kota dan kabupaten di Indonesia secara online (remote) dengan jaminan dukungan penuh.
            </p>
            <div style="display: flex; justify-content: center; gap: 12px; flex-wrap: wrap;">
                <span style="background: #f8fafc; color: #475569; border: 1px solid #e2e8f0; padding: 8px 18px; border-radius: 50px; font-size: 13px; font-weight: 700;">Sumatera</span>
                <span style="background: #f8fafc; color: #475569; border: 1px solid #e2e8f0; padding: 8px 18px; border-radius: 50px; font-size: 13px; font-weight: 700;">Jawa & Bali</span>
                <span style="background: #f8fafc; color: #475569; border: 1px solid #e2e8f0; padding: 8px 18px; border-radius: 50px; font-size: 13px; font-weight: 700;">Kalimantan</span>
                <span style="background: #f8fafc; color: #475569; border: 1px solid #e2e8f0; padding: 8px 18px; border-radius: 50px; font-size: 13px; font-weight: 700;">Sulawesi</span>
                <span style="background: #f8fafc; color: #475569; border: 1px solid #e2e8f0; padding: 8px 18px; border-radius: 50px; font-size: 13px; font-weight: 700;">Nusa Tenggara</span>
                <span style="background: #f8fafc; color: #475569; border: 1px solid #e2e8f0; padding: 8px 18px; border-radius: 50px; font-size: 13px; font-weight: 700;">Maluku & Papua</span>
            </div>
        </div>
    </section>

    <!-- Floating WhatsApp Button -->
    <a href="https://wa.me/{{ $settings['whatsapp_number'] }}?text={{ urlencode($settings['whatsapp_text']) }}" class="whatsapp-float" target="_blank" rel="noopener noreferrer">
        <i class="fa-brands fa-whatsapp"></i>
    </a>

    <!-- Footer -->
    <footer>
        <div class="footer-grid">
            <div class="footer-brand">
                <h3>
                    <img src="{{ asset('logo.png') }}" alt="Kang Digital Logo">
                    <span>Kang Digital</span>
                </h3>
                <p>Mitra terpercaya untuk digitalisasi bisnis Anda melalui jasa pembuatan website profesional, aplikasi mobile kustom, dan sistem Kasir UMKM modern.</p>
            </div>
            <div class="footer-col">
                <h4>Layanan Kami</h4>
                <ul>
                    <li><a href="#services">Website Developer</a></li>
                    <li><a href="#kasir">Kasir UMKM Android</a></li>
                    <li><a href="#services">Optimasi SEO & IT</a></li>
                </ul>
            </div>
            <div class="footer-col">
                <h4>Hubungi Kami</h4>
                <div class="footer-contact-item">
                    <i class="fa-solid fa-phone"></i>
                    <span>+62 857-3030-2827</span>
                </div>
                <div class="footer-contact-item">
                    <i class="fa-solid fa-envelope"></i>
                    <span>marketing@kangdigital.web.id</span>
                </div>
                <div class="footer-contact-item">
                    <i class="fa-solid fa-location-dot"></i>
                    <span>Indonesia</span>
                </div>
            </div>
        </div>
        <div class="footer-bottom">
            <p>&copy; {{ date('Y') }} <strong>Kang Digital</strong>. Hak Cipta Dilindungi.</p>
            <div class="footer-links">
                <a href="#about">Tentang Kami</a>
                <a href="#order">Hubungi Kami</a>
            </div>
        </div>
    </footer>

    <!-- WhatsApp Order Submission Script -->
    <script>
        document.getElementById('order-form').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const name = document.getElementById('name').value;
            const email = document.getElementById('email').value;
            const phone = document.getElementById('phone').value;
            const serviceType = document.getElementById('service_type').value;
            const rawMessage = document.getElementById('message').value;
            
            // Format WhatsApp Message details
            const waMessage = `Halo Kang Digital, saya ingin memesan layanan berikut:\n\n` +
                              `*Nama:* ${name}\n` +
                              `*Email:* ${email}\n` +
                              `*No. WA:* ${phone}\n` +
                              `*Layanan:* ${serviceType}\n` +
                              `*Pesan:* ${rawMessage}`;
            
            const encodedMessage = encodeURIComponent(waMessage);
            const waNumber = '6285730302827';
            const waUrl = `https://api.whatsapp.com/send?phone=${waNumber}&text=${encodedMessage}`;
            
            // Combine fields to store under message column in database
            const dbMessage = `[Layanan Diminati: ${serviceType}]\n\n${rawMessage}`;
            
            // Temporary replacement to submit form data via AJAX
            const messageInput = document.getElementById('message');
            const originalVal = messageInput.value;
            messageInput.value = dbMessage;
            
            const formData = new FormData(this);
            
            // Send to database asynchronously
            fetch(this.action, {
                method: 'POST',
                body: formData,
                headers: {
                    'X-Requested-With': 'XMLHttpRequest'
                }
            })
            .then(() => {
                // Restore form state
                messageInput.value = originalVal;
            })
            .catch(err => {
                console.error('Database Sync Error:', err);
                messageInput.value = originalVal;
            });
            
            // Open WhatsApp
            window.open(waUrl, '_blank');
            
            // Show Success Notification & Reset Form
            alert('Permintaan Pemesanan berhasil dikirim ke database dan diarahkan ke WhatsApp Owner!');
            this.reset();
        });
    </script>

</body>
</html>
