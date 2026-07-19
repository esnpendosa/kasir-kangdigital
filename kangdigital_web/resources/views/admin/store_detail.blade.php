<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detail Lisensi {{ $license->license_key }} | Kang Digital Admin</title>
    
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

        /* Top Actions and Back */
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

        /* Detail License Card */
        .detail-card {
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 24px;
            padding: 28px;
            margin-bottom: 32px;
            box-shadow: var(--shadow-subtle);
        }

        .license-title-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 16px;
        }

        .license-title {
            font-family: var(--font-heading);
            font-size: 24px;
            font-weight: 800;
            color: var(--primary);
            font-family: monospace;
        }

        .meta-row {
            margin-top: 16px;
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            font-size: 13px;
            color: var(--text-muted);
            font-weight: 500;
        }

        .meta-item {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .meta-item i {
            color: var(--primary);
        }

        /* Section Title */
        .section-title {
            font-family: var(--font-heading);
            font-size: 20px;
            font-weight: 800;
            color: var(--text-main);
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* Stores Grid */
        .stores-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 24px;
        }

        .store-card {
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 24px;
            box-shadow: var(--shadow-subtle);
            transition: var(--transition);
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .store-card:hover {
            border-color: var(--primary);
            transform: translateY(-4px);
            box-shadow: var(--shadow-medium);
        }

        .store-name-row {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 12px;
        }

        .store-title {
            font-family: var(--font-heading);
            font-size: 18px;
            font-weight: 700;
            color: var(--text-main);
        }

        .store-code {
            font-size: 12px;
            color: var(--primary);
            font-weight: 600;
            font-family: monospace;
        }

        .store-address {
            font-size: 13px;
            color: var(--text-muted);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .store-stats {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 8px;
        }

        .store-stat {
            background-color: var(--bg-panel);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 8px;
            text-align: center;
        }

        .store-stat-value {
            font-size: 15px;
            font-weight: 700;
            color: var(--text-main);
        }

        .store-stat-label {
            font-size: 9px;
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
            gap: 12px;
            margin-top: 4px;
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

        /* Buttons */
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 10px 18px;
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
            padding: 60px 20px;
            color: var(--text-muted);
            width: 100%;
        }

        .empty-state i {
            font-size: 54px;
            margin-bottom: 16px;
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

            <!-- License Detail Card -->
            <div class="detail-card">
                <div class="license-title-row">
                    <div>
                        <div style="display:flex; align-items:center; gap:12px;">
                            <span class="license-title">{{ $license->license_key }}</span>
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
                    </div>
                    
                    <div style="text-align: right;">
                        <span style="font-family: var(--font-heading); font-size: 28px; font-weight: 900; color: var(--primary);">
                            {{ $stores->count() }}
                        </span>
                        <span style="color: var(--text-muted); font-size: 13px; font-weight: 700; margin-left: 6px;">Toko Terdaftar</span>
                    </div>
                </div>

                <div class="meta-row">
                    <div class="meta-item">
                        <i class="fa-solid fa-calendar"></i>
                        <span>Durasi: <strong>{{ ucfirst($license->duration_type ?: '1_year') }}</strong></span>
                    </div>
                    <div class="meta-item">
                        <i class="fa-solid fa-mobile-screen"></i>
                        <span>Limit Perangkat: <strong>Max {{ $license->device_limit }} device</strong></span>
                    </div>
                    <div class="meta-item">
                        <i class="fa-solid fa-coins"></i>
                        <span>Harga: <strong>Rp {{ number_format($license->price ?: 0, 0, ',', '.') }}</strong></span>
                    </div>
                    <div class="meta-item">
                        <i class="fa-solid fa-hourglass-half"></i>
                        <span>Masa Berlaku: 
                            <strong>
                                @if($license->expires_at)
                                    {{ $license->expires_at->format('d/m/Y') }}
                                @else
                                    <span style="color:var(--accent-green)">Lifetime (Selamanya)</span>
                                @endif
                            </strong>
                        </span>
                    </div>
                </div>
            </div>

            <!-- Stores Section -->
            <h2 class="section-title">
                <i class="fa-solid fa-store" style="color: var(--primary);"></i> Toko dengan Lisensi ini
            </h2>

            @if($stores->isEmpty())
                <div class="empty-state">
                    <i class="fa-solid fa-store-slash"></i>
                    <p style="font-size: 15px; font-weight: 600;">Belum ada toko yang terdaftar.</p>
                    <p style="font-size: 13px; color: var(--text-light); margin-top: 8px;">Pengguna belum menghubungkan atau membuat toko melalui aplikasi Android.</p>
                </div>
            @else
                <div class="stores-grid">
                    @foreach($stores as $store)
                    <div class="store-card">
                        <div class="store-name-row">
                            <div>
                                <div class="store-title">{{ $store->store_name }}</div>
                                <div class="store-code"><i class="fa-solid fa-tag"></i> {{ $store->store_code }}</div>
                            </div>
                            <span class="badge {{ $store->is_active ? 'badge-success' : 'badge-danger' }}">
                                {{ $store->is_active ? 'Aktif' : 'Nonaktif' }}
                            </span>
                        </div>

                        @if($store->address)
                            <div class="store-address">
                                <i class="fa-solid fa-location-dot"></i>
                                <span>{{ $store->address }}</span>
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
                            <div class="store-stat">
                                <div class="store-stat-value">{{ $store->backups_count ?? 0 }}</div>
                                <div class="store-stat-label">Bkp</div>
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
                                  onsubmit="return confirm('Apakah Anda yakin ingin menghapus toko ini beserta seluruh data sinkronisasinya?')">
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
        </main>
    </div>

    <!-- Hidden logout form -->
    <form id="logout-form" action="{{ route('admin.logout') }}" method="POST" style="display: none;">
        @csrf
    </form>

    <script>
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
