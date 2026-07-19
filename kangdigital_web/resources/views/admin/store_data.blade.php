<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Data Toko {{ $store->store_name }} | Kang Digital Admin</title>
    
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

        /* Navigation */
        .back-nav {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 24px;
        }

        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: var(--primary);
            text-decoration: none;
            font-size: 14px;
            font-weight: 700;
            transition: var(--transition);
        }

        .back-btn:hover {
            color: #4D3DB5;
            transform: translateX(-4px);
        }

        /* Store Hero Card */
        .store-hero {
            background: linear-gradient(135deg, #FAF8FE 0%, #F3EFFF 100%);
            border: 1px solid var(--border-color);
            border-radius: 24px;
            padding: 28px;
            margin-bottom: 32px;
            display: flex;
            align-items: center;
            gap: 24px;
            box-shadow: var(--shadow-subtle);
        }

        .store-avatar {
            width: 64px;
            height: 64px;
            border-radius: 16px;
            background: linear-gradient(135deg, #8B5CF6, var(--primary));
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ffffff;
            font-size: 28px;
            flex-shrink: 0;
            box-shadow: 0 8px 16px rgba(108, 93, 211, 0.2);
        }

        .store-hero-info {
            flex: 1;
        }

        .store-hero-title-row {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }

        .store-hero-title {
            font-family: var(--font-heading);
            font-size: 22px;
            font-weight: 800;
            color: var(--text-main);
        }

        .store-hero-code {
            font-size: 13px;
            color: var(--primary);
            font-family: monospace;
            background: var(--primary-light);
            padding: 4px 12px;
            border-radius: 8px;
            font-weight: 700;
        }

        .store-hero-meta {
            color: var(--text-muted);
            font-size: 13px;
            margin-top: 8px;
            display: flex;
            flex-wrap: wrap;
            gap: 16px;
            font-weight: 500;
        }

        .store-hero-meta span {
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .store-hero-meta i {
            color: var(--primary);
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
            font-size: 20px;
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

        /* Tabs Navigation */
        .tabs {
            display: flex;
            gap: 8px;
            border-bottom: 2px solid var(--border-color);
            margin-bottom: 24px;
            overflow-x: auto;
            padding-bottom: 2px;
        }

        .tab {
            padding: 12px 20px;
            font-size: 14px;
            font-weight: 700;
            color: var(--text-muted);
            cursor: pointer;
            border-bottom: 3px solid transparent;
            transition: var(--transition);
            display: flex;
            align-items: center;
            gap: 8px;
            white-space: nowrap;
        }

        .tab:hover {
            color: var(--primary);
        }

        .tab.active {
            color: var(--primary);
            border-bottom-color: var(--primary);
        }

        /* Tab Content Panel */
        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: block;
        }

        /* Table Card and responsive container */
        .table-container {
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 24px;
            overflow: hidden;
            box-shadow: var(--shadow-subtle);
        }

        table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }

        th {
            background-color: var(--bg-panel);
            padding: 16px 20px;
            color: var(--text-muted);
            font-weight: 700;
            font-size: 11px;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            border-bottom: 1px solid var(--border-color);
        }

        td {
            padding: 16px 20px;
            border-bottom: 1px solid var(--border-color);
            color: var(--text-main);
            font-size: 14px;
            vertical-align: middle;
        }

        tr:last-child td {
            border-bottom: none;
        }

        tr:hover td {
            background-color: var(--primary-light);
        }

        /* Badges */
        .badge {
            padding: 4px 10px;
            border-radius: 50px;
            font-size: 11px;
            font-weight: 800;
            text-transform: uppercase;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .badge-green {
            background-color: rgba(55,209,89,0.12);
            color: var(--accent-green);
        }

        .badge-blue {
            background-color: rgba(63,140,255,0.12);
            color: var(--accent-blue);
        }

        .badge-red {
            background-color: rgba(255,90,90,0.12);
            color: #FF5A5A;
        }

        .badge-yellow {
            background-color: rgba(255,117,76,0.12);
            color: var(--secondary);
        }

        /* Backup Cards Layout */
        .backup-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }

        .backup-card {
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 20px;
            box-shadow: var(--shadow-subtle);
            transition: var(--transition);
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .backup-card:hover {
            border-color: var(--primary);
            transform: translateY(-4px);
            box-shadow: var(--shadow-medium);
        }

        .backup-name {
            font-family: var(--font-heading);
            font-size: 14px;
            font-weight: 700;
            color: var(--text-main);
            word-break: break-all;
        }

        .backup-meta {
            font-size: 12px;
            color: var(--text-muted);
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .backup-meta div {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .backup-meta i {
            color: var(--primary);
            width: 14px;
            text-align: center;
        }

        /* Button style */
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

        .empty-table {
            text-align: center;
            padding: 48px 20px;
            color: var(--text-muted);
        }

        .empty-table i {
            font-size: 44px;
            margin-bottom: 12px;
            opacity: 0.3;
            color: var(--text-light);
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
            <!-- Back Navigation -->
            <div class="back-nav">
                <a href="{{ route('admin.stores') }}" class="back-btn">
                    <i class="fa-solid fa-arrow-left"></i> Kembali ke Manajemen Toko
                </a>
            </div>

            <!-- Store Header Hero -->
            <div class="store-hero">
                <div class="store-avatar">
                    <i class="fa-solid fa-store"></i>
                </div>
                <div class="store-hero-info">
                    <div class="store-hero-title-row">
                        <h1 class="store-hero-title">{{ $store->store_name }}</h1>
                        <span class="store-hero-code">{{ $store->store_code }}</span>
                        <span class="badge {{ $store->is_active ? 'badge-green' : 'badge-red' }}">
                            {{ $store->is_active ? 'Aktif' : 'Nonaktif' }}
                        </span>
                    </div>
                    <div class="store-hero-meta">
                        <span><i class="fa-solid fa-key"></i> Lisensi: <strong>{{ $store->license->license_key }}</strong></span>
                        @if($store->address)
                            <span><i class="fa-solid fa-location-dot"></i> {{ $store->address }}</span>
                        @endif
                        @if($store->phone)
                            <span><i class="fa-solid fa-phone"></i> {{ $store->phone }}</span>
                        @endif
                        @if($store->last_synced_at)
                            <span style="color: var(--accent-green);"><i class="fa-solid fa-arrows-rotate"></i> Sync terakhir: {{ $store->last_synced_at->diffForHumans() }}</span>
                        @endif
                    </div>
                </div>
            </div>

            <!-- Stats Grid -->
            <div class="stats-grid">
                <div class="stat-card-custom">
                    <div class="stat-icon" style="background: linear-gradient(135deg, #34d399, #059669);">
                        <i class="fa-solid fa-coins"></i>
                    </div>
                    <div class="stat-info">
                        <span class="stat-value">Rp {{ number_format($revenue, 0, ',', '.') }}</span>
                        <span class="stat-label">Omzet Bulan Ini</span>
                    </div>
                </div>
                <div class="stat-card-custom">
                    <div class="stat-icon" style="background: linear-gradient(135deg, #a78bfa, #7c3aed);">
                        <i class="fa-solid fa-box"></i>
                    </div>
                    <div class="stat-info">
                        <span class="stat-value">{{ $products->count() }}</span>
                        <span class="stat-label">Produk</span>
                    </div>
                </div>
                <div class="stat-card-custom">
                    <div class="stat-icon" style="background: linear-gradient(135deg, #60a5fa, #2563eb);">
                        <i class="fa-solid fa-receipt"></i>
                    </div>
                    <div class="stat-info">
                        <span class="stat-value">{{ $transactions->count() }}</span>
                        <span class="stat-label">Transaksi (50 Terakhir)</span>
                    </div>
                </div>
                <div class="stat-card-custom">
                    <div class="stat-icon" style="background: linear-gradient(135deg, #f472b6, #db2777);">
                        <i class="fa-solid fa-wallet"></i>
                    </div>
                    <div class="stat-info">
                        <span class="stat-value">Rp {{ number_format($expenseTotal, 0, ',', '.') }}</span>
                        <span class="stat-label">Pengeluaran Bulan Ini</span>
                    </div>
                </div>
            </div>

            <!-- Tabs Navigation -->
            <div class="tabs">
                <div class="tab active" onclick="showTab('products', this)"><i class="fa-solid fa-box"></i> Produk ({{ $products->count() }})</div>
                <div class="tab" onclick="showTab('transactions', this)"><i class="fa-solid fa-receipt"></i> Transaksi</div>
                <div class="tab" onclick="showTab('customers', this)"><i class="fa-solid fa-users"></i> Pelanggan</div>
                <div class="tab" onclick="showTab('expenses', this)"><i class="fa-solid fa-wallet"></i> Pengeluaran</div>
                <div class="tab" onclick="showTab('suppliers', this)"><i class="fa-solid fa-truck"></i> Supplier</div>
                <div class="tab" onclick="showTab('backups', this)"><i class="fa-solid fa-cloud"></i> Cloud Backup ({{ $backups->count() }})</div>
            </div>

            <!-- TAB: PRODUCTS -->
            <div id="tab-products" class="tab-content active">
                @if($products->isEmpty())
                    <div class="empty-table">
                        <i class="fa-solid fa-box-open"></i>
                        <p>Belum ada produk yang tersinkronisasi.</p>
                    </div>
                @else
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th style="width: 50px;">#</th>
                                    <th>Nama Produk</th>
                                    <th>SKU/Barcode</th>
                                    <th>Harga Jual</th>
                                    <th>Harga Beli</th>
                                    <th>Stok</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($products as $i => $p)
                                <tr>
                                    <td style="color: var(--text-light);">{{ $i+1 }}</td>
                                    <td style="font-weight: 700; color: var(--text-main);">{{ $p->name }}</td>
                                    <td style="font-family: monospace; color: var(--text-muted);">{{ $p->barcode ?? $p->sku ?? '-' }}</td>
                                    <td style="color: var(--accent-green); font-weight: 700;">Rp {{ number_format($p->price, 0, ',', '.') }}</td>
                                    <td style="color: var(--secondary); font-weight: 700;">Rp {{ number_format($p->cost_price, 0, ',', '.') }}</td>
                                    <td style="{{ $p->stock <= $p->min_stock ? 'color:#FF5A5A; font-weight: 700;' : 'color:var(--text-main);' }}">
                                        {{ $p->stock }} {{ $p->unit }}
                                    </td>
                                    <td>
                                        <span class="badge {{ $p->is_active ? 'badge-green' : 'badge-red' }}">
                                            {{ $p->is_active ? 'Aktif' : 'Nonaktif' }}
                                        </span>
                                    </td>
                                </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                @endif
            </div>

            <!-- TAB: TRANSACTIONS -->
            <div id="tab-transactions" class="tab-content">
                @if($transactions->isEmpty())
                    <div class="empty-table">
                        <i class="fa-solid fa-receipt"></i>
                        <p>Belum ada transaksi yang tersinkronisasi.</p>
                    </div>
                @else
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th style="width: 50px;">#</th>
                                    <th>Invoice</th>
                                    <th>Kasir</th>
                                    <th>Total</th>
                                    <th>Metode</th>
                                    <th>Status</th>
                                    <th>Waktu</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($transactions as $i => $t)
                                <tr>
                                    <td style="color: var(--text-light);">{{ $i+1 }}</td>
                                    <td style="font-family: monospace; font-weight: 700;">{{ $t->invoice_no ?? 'TRX-'.$t->remote_id }}</td>
                                    <td>{{ $t->cashier_username ?? '-' }}</td>
                                    <td style="color: var(--accent-green); font-weight: 800;">Rp {{ number_format($t->total, 0, ',', '.') }}</td>
                                    <td><span class="badge badge-blue">{{ strtoupper($t->payment_method) }}</span></td>
                                    <td>
                                        <span class="badge {{ $t->status === 'completed' ? 'badge-green' : 'badge-red' }}">
                                            {{ ucfirst($t->status) }}
                                        </span>
                                    </td>
                                    <td style="color: var(--text-muted); font-size: 13px;">{{ $t->sold_at?->format('d/m/Y H:i') }}</td>
                                </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                @endif
            </div>

            <!-- TAB: CUSTOMERS -->
            <div id="tab-customers" class="tab-content">
                @if($customers->isEmpty())
                    <div class="empty-table">
                        <i class="fa-solid fa-users"></i>
                        <p>Belum ada pelanggan yang tersinkronisasi.</p>
                    </div>
                @else
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th style="width: 50px;">#</th>
                                    <th>Nama Pelanggan</th>
                                    <th>Telepon</th>
                                    <th>Email</th>
                                    <th>Poin</th>
                                    <th>Total Belanja</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($customers as $i => $c)
                                <tr>
                                    <td style="color: var(--text-light);">{{ $i+1 }}</td>
                                    <td style="font-weight: 700; color: var(--text-main);">{{ $c->name }}</td>
                                    <td>{{ $c->phone ?? '-' }}</td>
                                    <td style="color: var(--text-muted);">{{ $c->email ?? '-' }}</td>
                                    <td><span class="badge badge-yellow">{{ $c->points }} Poin</span></td>
                                    <td style="color: var(--accent-green); font-weight: 700;">Rp {{ number_format($c->total_spent, 0, ',', '.') }}</td>
                                </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                @endif
            </div>

            <!-- TAB: EXPENSES -->
            <div id="tab-expenses" class="tab-content">
                @if($expenses->isEmpty())
                    <div class="empty-table">
                        <i class="fa-solid fa-wallet"></i>
                        <p>Belum ada catatan pengeluaran tersinkronisasi.</p>
                    </div>
                @else
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th style="width: 50px;">#</th>
                                    <th>Kategori</th>
                                    <th>Deskripsi</th>
                                    <th>Jumlah</th>
                                    <th>Metode</th>
                                    <th>Tanggal</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($expenses as $i => $e)
                                <tr>
                                    <td style="color: var(--text-light);">{{ $i+1 }}</td>
                                    <td><span class="badge badge-yellow">{{ $e->category }}</span></td>
                                    <td style="color: var(--text-main);">{{ $e->description ?? '-' }}</td>
                                    <td style="color: var(--badge-red); font-weight: 700; color: #FF5A5A;">Rp {{ number_format($e->amount, 0, ',', '.') }}</td>
                                    <td>{{ $e->payment_method }}</td>
                                    <td style="color: var(--text-muted); font-size: 13px;">{{ $e->expense_date?->format('d/m/Y') }}</td>
                                </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                @endif
            </div>

            <!-- TAB: SUPPLIERS -->
            <div id="tab-suppliers" class="tab-content">
                @if($suppliers->isEmpty())
                    <div class="empty-table">
                        <i class="fa-solid fa-truck"></i>
                        <p>Belum ada supplier yang tersinkronisasi.</p>
                    </div>
                @else
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th style="width: 50px;">#</th>
                                    <th>Nama Supplier</th>
                                    <th>Telepon</th>
                                    <th>Email</th>
                                    <th>Kontak Person</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($suppliers as $i => $s)
                                <tr>
                                    <td style="color: var(--text-light);">{{ $i+1 }}</td>
                                    <td style="font-weight: 700; color: var(--text-main);">{{ $s->name }}</td>
                                    <td>{{ $s->phone ?? '-' }}</td>
                                    <td style="color: var(--text-muted);">{{ $s->email ?? '-' }}</td>
                                    <td>{{ $s->contact_person ?? '-' }}</td>
                                    <td>
                                        <span class="badge {{ $s->is_active ? 'badge-green' : 'badge-red' }}">
                                            {{ $s->is_active ? 'Aktif' : 'Nonaktif' }}
                                        </span>
                                    </td>
                                </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                @endif
            </div>

            <!-- TAB: BACKUPS -->
            <div id="tab-backups" class="tab-content">
                @if($backups->isEmpty())
                    <div class="empty-table">
                        <i class="fa-solid fa-cloud"></i>
                        <p>Belum ada data backup di cloud untuk toko ini.</p>
                    </div>
                @else
                    <div class="backup-grid">
                        @foreach($backups as $backup)
                        <div class="backup-card">
                            <div style="display:flex; align-items:center; gap:16px;">
                                <div style="width:48px; height:48px; background:rgba(55,209,89,0.1); border-radius:12px; display:flex; align-items:center; justify-content:center; color: var(--accent-green); font-size: 20px;">
                                    <i class="fa-solid fa-database"></i>
                                </div>
                                <div style="flex:1; min-width:0;">
                                    <div class="backup-name" title="{{ $backup->original_filename }}">{{ $backup->original_filename }}</div>
                                    <div style="font-size: 11px; color: var(--text-light); font-weight: 700; margin-top: 2px;">{{ $backup->file_size_formatted }}</div>
                                </div>
                            </div>
                            <div class="backup-meta">
                                <div><i class="fa-solid fa-calendar-days"></i> Tanggal: {{ $backup->created_at->format('d/m/Y H:i') }}</div>
                                @if($backup->app_version)
                                    <div><i class="fa-solid fa-code-branch"></i> Versi App: v{{ $backup->app_version }}</div>
                                @endif
                                @if($backup->file_hash)
                                    <div style="font-family:monospace; font-size:10px; color: var(--text-light);">MD5: {{ substr($backup->file_hash, 0, 16) }}...</div>
                                @endif
                            </div>
                            <a href="{{ url('api/backup/'.$store->id.'/download/'.$backup->id) }}" class="btn btn-outline" style="width:100%;">
                                <i class="fa-solid fa-download"></i> Unduh Database
                            </a>
                        </div>
                        @endforeach
                    </div>
                @endif
            </div>
        </main>
    </div>

    <!-- Hidden logout form -->
    <form id="logout-form" action="{{ route('admin.logout') }}" method="POST" style="display: none;">
        @csrf
    </form>

    <script>
        // Tab switching logic
        function showTab(name, el) {
            document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
            document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
            
            const targetContent = document.getElementById('tab-' + name);
            if (targetContent) {
                targetContent.classList.add('active');
            }
            if (el) {
                el.classList.add('active');
            }
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
