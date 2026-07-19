<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manajemen Toko | Kang Digital Admin</title>
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Outfit:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root {
            --primary: #6C5DD3;
            --primary-light: #f3f0ff;
            --primary-glow: rgba(108, 93, 211, 0.15);
            --secondary: #FF754C;
            --accent-pink: #FF75B5;
            --accent-blue: #3F8CFF;
            --accent-green: #37D159;
            --bg-body: #e3e6ed;
            --bg-card: #ffffff;
            --bg-panel: #FAF8FE;
            --text-main: #11142D;
            --text-muted: #808191;
            --text-light: #B2B3BD;
            --border-color: #E4E6EF;
            --font-sans: 'Plus Jakarta Sans', sans-serif;
            --font-heading: 'Outfit', sans-serif;
            --shadow-subtle: 0 10px 30px rgba(0, 0, 0, 0.02);
            --shadow-medium: 0 15px 40px rgba(108, 93, 211, 0.08);
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: var(--font-sans);
            background-color: var(--bg-body);
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: stretch;
            padding: 0;
            margin: 0;
            overflow-x: hidden;
        }

        .app-wrapper {
            width: 100%;
            max-width: 100%;
            background-color: var(--bg-card);
            border-radius: 0px;
            overflow: hidden;
            display: flex;
            position: relative;
            min-height: 100vh;
            border: none;
        }

        /* Mobile Header */
        .mobile-header {
            display: none;
            width: 100%;
            height: 64px;
            background-color: var(--bg-card);
            border-bottom: 1px solid var(--border-color);
            padding: 0 20px;
            align-items: center;
            justify-content: space-between;
            position: fixed;
            top: 0;
            left: 0;
            z-index: 99;
        }

        .menu-toggle {
            background: none;
            border: none;
            font-size: 24px;
            color: var(--text-main);
            cursor: pointer;
        }

        /* SIDEBAR */
        aside.sidebar {
            width: 256px;
            background-color: var(--bg-card);
            border-right: 1px solid var(--border-color);
            padding: 40px 24px;
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
            z-index: 10;
            height: 100vh;
            overflow-y: auto;
        }

        .logo-container {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 40px;
            text-decoration: none;
        }

        .logo-text {
            font-family: var(--font-heading);
            font-size: 20px;
            font-weight: 800;
            color: var(--text-main);
        }

        .menu-section {
            margin-bottom: 32px;
        }

        .menu-section.settings-section {
            margin-top: auto;
            margin-bottom: 0;
        }

        .menu-title {
            font-size: 11px;
            font-weight: 700;
            color: var(--text-light);
            letter-spacing: 1.5px;
            text-transform: uppercase;
            margin-bottom: 16px;
            display: block;
        }

        .menu-list {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .menu-item {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 12px 16px;
            border-radius: 16px;
            color: var(--text-muted);
            font-weight: 600;
            font-size: 14px;
            text-decoration: none;
            cursor: pointer;
            transition: var(--transition);
        }

        .menu-item i {
            font-size: 18px;
            width: 24px;
            text-align: center;
            transition: var(--transition);
        }

        .menu-item:hover {
            color: var(--text-main);
            background-color: var(--primary-light);
        }

        .menu-item.active {
            background-color: var(--primary-light);
            color: var(--primary);
            font-weight: 700;
        }

        .menu-item.active i {
            color: var(--primary);
        }

        .friends-list {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .friend-item {
            display: flex;
            align-items: center;
            gap: 12px;
            cursor: pointer;
            padding: 6px;
            border-radius: 12px;
            transition: var(--transition);
        }

        .friend-item:hover {
            background-color: var(--bg-panel);
        }

        .friend-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            font-weight: 700;
            color: #ffffff;
            border: 2px solid #ffffff;
            box-shadow: 0 4px 8px rgba(0,0,0,0.05);
        }

        .friend-info {
            display: flex;
            flex-direction: column;
            max-width: 140px;
        }

        .friend-name {
            font-size: 12px;
            font-weight: 700;
            color: var(--text-main);
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .friend-status {
            font-size: 10px;
            color: var(--text-muted);
        }

        .logout-btn {
            color: #FF5A5A;
        }

        .logout-btn:hover {
            background-color: #FFF0F0;
            color: #FF5A5A;
        }

        /* MAIN CONTENT AREA */
        main.main-content {
            flex: 1;
            padding: 40px;
            overflow-y: auto;
            height: 100vh;
            max-height: 100vh;
        }

        /* Top Bar */
        .top-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 32px;
            gap: 20px;
        }

        .search-wrapper {
            position: relative;
            flex: 1;
            max-width: 480px;
        }

        .search-wrapper i {
            position: absolute;
            left: 20px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-muted);
            font-size: 16px;
        }

        .search-wrapper input {
            width: 100%;
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            padding: 14px 20px 14px 54px;
            border-radius: 20px;
            font-size: 14px;
            font-family: var(--font-sans);
            color: var(--text-main);
            outline: none;
            transition: var(--transition);
        }

        .search-wrapper input:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 4px var(--primary-glow);
        }

        .top-actions {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .action-btn {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            border: 1px solid var(--border-color);
            background-color: var(--bg-card);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--text-main);
            font-size: 18px;
            cursor: pointer;
            transition: var(--transition);
            text-decoration: none;
        }

        .action-btn:hover {
            border-color: var(--primary);
            color: var(--primary);
            background-color: var(--primary-light);
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 6px 16px;
            border-radius: 24px;
            cursor: pointer;
            transition: var(--transition);
        }

        .user-profile:hover {
            background-color: var(--bg-panel);
        }

        .profile-name {
            font-size: 14px;
            font-weight: 700;
            color: var(--text-main);
        }

        /* Banner Header */
        .banner-card {
            background: linear-gradient(135deg, #6C5DD3 0%, #4D3DB5 100%);
            border-radius: 28px;
            padding: 40px;
            color: #ffffff;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: relative;
            overflow: hidden;
            margin-bottom: 32px;
            box-shadow: var(--shadow-medium);
        }

        .banner-info {
            max-width: 60%;
            position: relative;
            z-index: 2;
        }

        .banner-tag {
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 1.5px;
            color: rgba(255, 255, 255, 0.7);
            text-transform: uppercase;
            margin-bottom: 12px;
            display: block;
        }

        .banner-title {
            font-family: var(--font-heading);
            font-size: 28px;
            font-weight: 700;
            line-height: 1.3;
        }

        .banner-graphic {
            position: absolute;
            right: 40px;
            top: 50%;
            transform: translateY(-50%);
            width: 140px;
            height: 140px;
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0.85;
            z-index: 1;
        }

        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 32px;
        }

        .stat-card-custom {
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 20px;
            display: flex;
            align-items: center;
            gap: 16px;
            transition: var(--transition);
            box-shadow: var(--shadow-subtle);
        }

        .stat-card-custom:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-medium);
            border-color: var(--primary);
        }

        .stat-card-custom .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            color: #ffffff;
            flex-shrink: 0;
        }

        .stat-card-custom .stat-info {
            display: flex;
            flex-direction: column;
        }

        .stat-card-custom .stat-value {
            font-family: var(--font-heading);
            font-size: 24px;
            font-weight: 800;
            color: var(--text-main);
            line-height: 1.2;
        }

        .stat-card-custom .stat-label {
            font-size: 11px;
            color: var(--text-muted);
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-top: 2px;
        }

        /* License Collapsible Card */
        .license-card {
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 24px;
            margin-bottom: 24px;
            overflow: hidden;
            box-shadow: var(--shadow-subtle);
            transition: var(--transition);
        }

        .license-card:hover {
            border-color: var(--primary-glow);
            box-shadow: var(--shadow-medium);
        }

        .license-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 20px 24px;
            background-color: var(--bg-panel);
            border-bottom: 1px solid var(--border-color);
            cursor: pointer;
            transition: var(--transition);
        }

        .license-header:hover {
            background-color: var(--primary-light);
        }

        .license-info {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        /* Badges */
        .badge {
            padding: 6px 12px;
            border-radius: 50px;
            font-size: 11px;
            font-weight: 800;
            text-transform: uppercase;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .badge-success {
            background-color: rgba(55,209,89,0.12);
            color: var(--accent-green);
        }

        .badge-warning {
            background-color: rgba(255,117,76,0.12);
            color: var(--secondary);
        }

        .badge-danger {
            background-color: rgba(255,90,90,0.12);
            color: #FF5A5A;
        }

        .badge-info {
            background-color: rgba(63,140,255,0.12);
            color: var(--accent-blue);
        }

        /* Stores Grid */
        .stores-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            padding: 24px;
            background-color: #fafbfc;
            border-top: 1px solid var(--border-color);
        }

        .store-card {
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 20px;
            box-shadow: var(--shadow-subtle);
            transition: var(--transition);
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .store-card:hover {
            border-color: var(--primary);
            transform: translateY(-4px);
            box-shadow: var(--shadow-medium);
        }

        .store-name {
            font-family: var(--font-heading);
            font-size: 16px;
            font-weight: 700;
            color: var(--text-main);
        }

        .store-code {
            font-size: 12px;
            color: var(--primary);
            font-weight: 600;
            font-family: monospace;
        }

        .store-stats {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
            margin: 8px 0;
        }

        .store-stat {
            background-color: var(--bg-panel);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 10px;
            text-align: center;
            transition: var(--transition);
        }

        .store-stat-value {
            font-size: 16px;
            font-weight: 700;
            color: var(--text-main);
        }

        .store-stat-label {
            font-size: 10px;
            color: var(--text-muted);
            text-transform: uppercase;
            font-weight: 600;
            margin-top: 2px;
        }

        .sync-time {
            font-size: 11px;
            color: var(--text-muted);
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .store-actions {
            display: flex;
            gap: 10px;
            margin-top: 8px;
        }

        /* Buttons */
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 10px 16px;
            border-radius: 12px;
            font-size: 13px;
            font-weight: 700;
            text-decoration: none;
            border: none;
            cursor: pointer;
            transition: var(--transition);
        }

        .btn-primary {
            background-color: var(--primary);
            color: #ffffff;
        }

        .btn-primary:hover {
            background-color: #4D3DB5;
            transform: translateY(-1px);
        }

        .btn-outline {
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            color: var(--text-main);
        }

        .btn-outline:hover {
            background-color: var(--primary-light);
            border-color: var(--primary);
            color: var(--primary);
        }

        .btn-danger {
            background-color: rgba(255,90,90,0.08);
            border: 1px solid rgba(255,90,90,0.12);
            color: #FF5A5A;
        }

        .btn-danger:hover {
            background-color: #FF5A5A;
            color: #ffffff;
        }

        .empty-state {
            text-align: center;
            padding: 48px 24px;
            color: var(--text-muted);
            width: 100%;
        }

        .empty-state i {
            font-size: 48px;
            margin-bottom: 16px;
            opacity: 0.4;
            color: var(--text-light);
        }

        /* Alert success */
        .alert-success {
            background-color: rgba(55,209,89,0.08);
            border: 1px solid rgba(55,209,89,0.15);
            color: var(--accent-green);
            padding: 16px 20px;
            border-radius: 16px;
            margin-bottom: 24px;
            font-weight: 600;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* Responsive styling */
        @media (max-width: 1200px) {
            .app-wrapper {
                flex-direction: column;
                margin-top: 64px;
            }

            .mobile-header {
                display: flex;
            }

            aside.sidebar {
                position: fixed;
                left: -256px;
                top: 64px;
                height: calc(100vh - 64px);
                width: 256px;
                box-shadow: 10px 0 30px rgba(0,0,0,0.05);
                transition: var(--transition);
            }

            aside.sidebar.active {
                left: 0;
            }

            main.main-content {
                padding: 24px;
            }

            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
    </style>
</head>
<body>

    <!-- Mobile Header -->
    <div class="mobile-header">
        <button class="menu-toggle" id="menu-toggle">
            <i class="fa-solid fa-bars"></i>
        </button>
        <a href="/" class="logo-container" style="margin-bottom: 0; display: flex; align-items: center; gap: 8px; text-decoration: none;">
            <img src="{{ asset('logo.png') }}" alt="Kang Digital Logo" style="width: 28px; height: 28px; border-radius: 6px; object-fit: cover;">
            <span class="logo-text" style="font-size:18px; font-weight: 800; color: var(--text-main);">Kang Digital</span>
        </a>
        <div style="width: 24px;"></div> <!-- spacer -->
    </div>

    <div class="app-wrapper">
        <!-- SIDEBAR -->
        <aside class="sidebar" id="sidebar">
            <a href="/" class="logo-container" style="display: flex; align-items: center; gap: 10px; text-decoration: none;">
                <img src="{{ asset('logo.png') }}" alt="Kang Digital Logo" style="width: 32px; height: 32px; border-radius: 8px; object-fit: cover;">
                <span class="logo-text" style="font-family: var(--font-heading); font-size: 20px; font-weight: 800; color: var(--text-main);">Kang Digital</span>
            </a>
            
            <div class="menu-section">
                <span class="menu-title">MANAGEMENT</span>
                <nav class="menu-list">
                    <a href="{{ route('admin.dashboard', ['tab' => 'leads']) }}" class="menu-item" style="text-decoration:none; color: inherit;">
                        <i class="fa-solid fa-inbox"></i>
                        <span>Leads / Pesanan</span>
                    </a>
                    <a href="{{ route('admin.dashboard', ['tab' => 'licenses']) }}" class="menu-item" style="text-decoration:none; color: inherit;">
                        <i class="fa-solid fa-key"></i>
                        <span>Lisensi & Member</span>
                    </a>
                    <a href="{{ route('admin.dashboard', ['tab' => 'services']) }}" class="menu-item" style="text-decoration:none; color: inherit;">
                        <i class="fa-solid fa-list-check"></i>
                        <span>Layanan Dinamis</span>
                    </a>
                    <a href="{{ route('admin.stores') }}" class="menu-item active" style="text-decoration:none; color: inherit;">
                        <i class="fa-solid fa-store"></i>
                        <span>Manajemen Toko</span>
                    </a>
                </nav>
            </div>
            
            <div class="menu-section">
                <span class="menu-title">LISENSI TERBARU</span>
                <ul class="friends-list">
                    @forelse($licenses->take(3) as $lic)
                        <li class="friend-item" onclick="window.location.href='{{ route('admin.dashboard', ['tab' => 'licenses']) }}'">
                            <div class="friend-avatar" style="background: linear-gradient(135deg, #6C5DD3, #3F8CFF);">
                                <i class="fa-solid fa-key" style="font-size: 11px;"></i>
                            </div>
                            <div class="friend-info">
                                <span class="friend-name">{{ $lic->license_key }}</span>
                                <span class="friend-status">{{ ucfirst($lic->status) }}</span>
                            </div>
                        </li>
                    @empty
                        <li class="friend-item">
                            <div class="friend-avatar" style="background: #ccc;"><i class="fa-solid fa-key"></i></div>
                            <div class="friend-info">
                                <span class="friend-name">Belum ada</span>
                                <span class="friend-status">Offline</span>
                            </div>
                        </li>
                    @endforelse
                </ul>
            </div>
            
            <div class="menu-section settings-section">
                <span class="menu-title">SETTINGS</span>
                <nav class="menu-list">
                    <a href="{{ route('admin.dashboard', ['tab' => 'settings']) }}" class="menu-item" style="text-decoration:none; color: inherit;">
                        <i class="fa-solid fa-gears"></i>
                        <span>Setting Landing</span>
                    </a>
                    <a href="#" class="menu-item logout-btn" onclick="event.preventDefault(); document.getElementById('logout-form').submit();">
                        <i class="fa-solid fa-right-from-bracket"></i>
                        <span>Keluar Panel</span>
                    </a>
                </nav>
            </div>
        </aside>

        <!-- MAIN CONTENT AREA -->
        <main class="main-content">
            <!-- Header bar -->
            <header class="top-bar">
                <div class="search-wrapper">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" id="store-search" placeholder="Cari toko atau lisensi....">
                </div>
                
                <div class="top-actions">
                    <a href="{{ route('admin.dashboard', ['tab' => 'leads']) }}" class="action-btn">
                        <i class="fa-solid fa-envelope"></i>
                    </a>
                    
                    <div class="user-profile" onclick="window.location.href='{{ route('admin.dashboard', ['tab' => 'settings']) }}'">
                        <div style="background: var(--primary); width: 38px; height: 38px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; border: 2px solid white; box-shadow: 0 4px 8px rgba(0,0,0,0.05);">
                            A
                        </div>
                        <span class="profile-name">{{ Auth::user()->name }}</span>
                    </div>
                </div>
            </header>

            @if(session('success'))
                <div class="alert-success">
                    <i class="fa-solid fa-circle-check" style="font-size: 18px; color: var(--accent-green);"></i>
                    <span>{{ session('success') }}</span>
                </div>
            @endif

            <!-- Banner Card -->
            <section class="banner-card">
                <div class="banner-info">
                    <span class="banner-tag">MONITORING TOKO</span>
                    <h1 class="banner-title">Kelola & Sinkronkan Data Penjualan dari Aplikasi Kasir Android</h1>
                </div>
                <div class="banner-graphic">
                    <svg width="120" height="120" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M50 0C50 27.6142 27.6142 50 0 50C27.6142 50 50 72.3858 50 100C50 72.3858 72.3858 50 100 50C72.3858 50 50 27.6142 50 0Z" fill="white" fill-opacity="0.25"/>
                    </svg>
                </div>
            </section>

            <!-- Stats Overview -->
            <div class="stats-grid">
                <div class="stat-card-custom">
                    <div class="stat-icon" style="background: linear-gradient(135deg, #a78bfa, #7c3aed);">
                        <i class="fa-solid fa-store"></i>
                    </div>
                    <div class="stat-info">
                        <span class="stat-value">{{ $totalStores }}</span>
                        <span class="stat-label">Total Toko</span>
                    </div>
                </div>
                <div class="stat-card-custom">
                    <div class="stat-icon" style="background: linear-gradient(135deg, #f472b6, #db2777);">
                        <i class="fa-solid fa-box"></i>
                    </div>
                    <div class="stat-info">
                        <span class="stat-value">{{ number_format($totalProducts) }}</span>
                        <span class="stat-label">Produk Sync</span>
                    </div>
                </div>
                <div class="stat-card-custom">
                    <div class="stat-icon" style="background: linear-gradient(135deg, #60a5fa, #2563eb);">
                        <i class="fa-solid fa-receipt"></i>
                    </div>
                    <div class="stat-info">
                        <span class="stat-value">{{ number_format($totalTransactions) }}</span>
                        <span class="stat-label">Transaksi</span>
                    </div>
                </div>
                <div class="stat-card-custom">
                    <div class="stat-icon" style="background: linear-gradient(135deg, #34d399, #059669);">
                        <i class="fa-solid fa-coins"></i>
                    </div>
                    <div class="stat-info">
                        <span class="stat-value">Rp {{ number_format($totalRevenue / 1000000, 1) }}M</span>
                        <span class="stat-label">Total Omzet</span>
                    </div>
                </div>
            </div>

            <!-- Licenses & Stores List -->
            <div id="licenses-container">
                @forelse($licenses as $license)
                <div class="license-card" data-key="{{ strtolower($license->license_key) }}">
                    <div class="license-header" onclick="toggleStores('stores-{{ $license->id }}')">
                        <div class="license-info">
                            <div>
                                <div style="display:flex; align-items:center; gap:12px;">
                                    <span style="font-size:16px; font-weight:800; color:var(--primary); font-family:monospace;">
                                        {{ $license->license_key }}
                                    </span>
                                    @if($license->status === 'active')
                                        <span class="badge badge-success">Aktif</span>
                                    @elseif($license->status === 'inactive')
                                        <span class="badge badge-warning">Belum Aktif</span>
                                    @elseif($license->status === 'expired')
                                        <span class="badge badge-danger">Expired</span>
                                    @else
                                        <span class="badge badge-info">{{ $license->status }}</span>
                                    @endif
                                </div>
                                <div style="font-size:12px; color:var(--text-muted); margin-top:6px; font-weight: 500;">
                                    <span>Durasi: {{ ucfirst($license->duration_type ?: '1_year') }}</span> •
                                    <span>{{ $license->stores->count() }} Toko terhubung</span> •
                                    <span>Max {{ $license->device_limit }} Device</span>
                                    @if($license->expires_at)
                                        • <span>Exp: {{ $license->expires_at->format('d/m/Y') }}</span>
                                    @else
                                        • <span style="color:var(--accent-green); font-weight:700;">Lifetime</span>
                                    @endif
                                </div>
                            </div>
                        </div>
                        <div style="display:flex; align-items:center; gap:16px;">
                            <a href="{{ route('admin.store.detail', $license->id) }}" class="btn btn-outline" onclick="event.stopPropagation();">
                                <i class="fa-solid fa-eye"></i> Detail
                            </a>
                            <i class="fa-solid fa-chevron-down" style="color: var(--text-light); transition: transform 0.3s;" id="arrow-{{ $license->id }}"></i>
                        </div>
                    </div>

                    <!-- Store Cards (Collapsible) -->
                    <div id="stores-{{ $license->id }}" style="display:none;">
                        @if($license->stores->isEmpty())
                            <div class="empty-state">
                                <i class="fa-solid fa-store-slash"></i>
                                <p>Belum ada toko yang terhubung untuk lisensi ini.</p>
                            </div>
                        @else
                            <div class="stores-grid">
                                @foreach($license->stores as $store)
                                <div class="store-card" data-name="{{ strtolower($store->store_name) }}">
                                    <div style="display:flex; align-items:flex-start; justify-content:space-between;">
                                        <div>
                                            <div class="store-name">{{ $store->store_name }}</div>
                                            <div class="store-code"><i class="fa-solid fa-tag"></i> {{ $store->store_code }}</div>
                                        </div>
                                        <span class="badge {{ $store->is_active ? 'badge-success' : 'badge-danger' }}">
                                            {{ $store->is_active ? 'Aktif' : 'Nonaktif' }}
                                        </span>
                                    </div>

                                    @if($store->address)
                                    <div style="font-size:12px; color:var(--text-muted); margin-bottom:4px;">
                                        <i class="fa-solid fa-location-dot" style="margin-right: 4px;"></i> {{ $store->address }}
                                    </div>
                                    @endif

                                    <div class="store-stats">
                                        <div class="store-stat">
                                            <div class="store-stat-value">{{ $store->products_count ?? 0 }}</div>
                                            <div class="store-stat-label">Produk</div>
                                        </div>
                                        <div class="store-stat">
                                            <div class="store-stat-value">{{ $store->transactions_count ?? 0 }}</div>
                                            <div class="store-stat-label">Trx</div>
                                        </div>
                                        <div class="store-stat">
                                            <div class="store-stat-value">{{ $store->customers_count ?? 0 }}</div>
                                            <div class="store-stat-label">Plg</div>
                                        </div>
                                    </div>

                                    @if($store->last_synced_at)
                                    <div class="sync-time">
                                        <i class="fa-solid fa-arrows-rotate"></i>
                                        <span>Sync terakhir: {{ $store->last_synced_at->diffForHumans() }}</span>
                                    </div>
                                    @else
                                    <div class="sync-time" style="color: var(--secondary);">
                                        <i class="fa-solid fa-triangle-exclamation"></i> Belum pernah sync
                                    </div>
                                    @endif

                                    <div class="store-actions">
                                        <a href="{{ route('admin.store.data', $store->id) }}" class="btn btn-primary" style="flex:1;">
                                            <i class="fa-solid fa-database"></i> Lihat Data
                                        </a>
                                        <form method="POST" action="{{ route('admin.store.delete', $store->id) }}"
                                              onsubmit="return confirm('Hapus toko {{ $store->store_name }}? Semua data sinkronisasi akan hilang permanen!')"
                                              style="display:inline;">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="btn btn-danger">
                                                <i class="fa-solid fa-trash"></i>
                                            </button>
                                        </form>
                                    </div>
                                </div>
                                @endforeach
                            </div>
                        @endif
                    </div>
                </div>
                @empty
                <div style="text-align:center; padding:80px 20px; color:var(--text-muted);">
                    <i class="fa-solid fa-key" style="font-size:64px; margin-bottom:20px; opacity:0.3; color: var(--text-light)"></i>
                    <p style="font-size: 15px; font-weight: 600;">Belum ada lisensi terdaftar.</p>
                    <p style="font-size: 13px; color: var(--text-light); margin-top: 8px;">Silakan buat lisensi terlebih dahulu di <a href="{{ route('admin.dashboard', ['tab' => 'licenses']) }}" style="color:var(--primary); font-weight:700; text-decoration: none;">Dashboard Admin</a>.</p>
                </div>
                @endforelse
            </div>
        </main>
    </div>

    <!-- Hidden logout form -->
    <form id="logout-form" action="{{ route('admin.logout') }}" method="POST" style="display: none;">
        @csrf
    </form>

    <script>
        // Collapsible stores toggle
        function toggleStores(id) {
            const el = document.getElementById(id);
            const licId = id.replace('stores-', '');
            const arrow = document.getElementById('arrow-' + licId);
            if (el.style.display === 'none' || el.style.display === '') {
                el.style.display = 'block';
                if(arrow) arrow.style.transform = 'rotate(180deg)';
            } else {
                el.style.display = 'none';
                if(arrow) arrow.style.transform = 'rotate(0)';
            }
        }

        // Search Filter
        const searchInput = document.getElementById('store-search');
        if (searchInput) {
            searchInput.addEventListener('input', function() {
                const query = this.value.toLowerCase().trim();
                const cards = document.querySelectorAll('.license-card');

                cards.forEach(card => {
                    const licKey = card.getAttribute('data-key') || '';
                    const storeCards = card.querySelectorAll('.store-card');
                    let hasMatchingStore = false;

                    // If license matches
                    if (licKey.includes(query)) {
                        card.style.display = 'block';
                        // Show all stores under this card
                        storeCards.forEach(sc => sc.style.display = 'flex');
                    } else {
                        // Otherwise search inside store names
                        storeCards.forEach(sc => {
                            const name = sc.getAttribute('data-name') || '';
                            if (name.includes(query)) {
                                sc.style.display = 'flex';
                                hasMatchingStore = true;
                            } else {
                                sc.style.display = 'none';
                            }
                        });

                        if (hasMatchingStore) {
                            card.style.display = 'block';
                            // Open collapsed element if not open
                            const collapseEl = card.querySelector('[id^="stores-"]');
                            if(collapseEl && collapseEl.style.display === 'none') {
                                collapseEl.style.display = 'block';
                                const arrow = card.querySelector('[id^="arrow-"]');
                                if(arrow) arrow.style.transform = 'rotate(180deg)';
                            }
                        } else {
                            card.style.display = 'none';
                        }
                    }
                });
            });
        }

        // Sidebar mobile toggle
        const menuToggle = document.getElementById('menu-toggle');
        const sidebar = document.getElementById('sidebar');
        if (menuToggle && sidebar) {
            menuToggle.addEventListener('click', (e) => {
                e.stopPropagation();
                sidebar.classList.toggle('active');
            });
            document.addEventListener('click', () => {
                sidebar.classList.remove('active');
            });
            sidebar.addEventListener('click', (e) => e.stopPropagation());
        }
    </script>
</body>
</html>
