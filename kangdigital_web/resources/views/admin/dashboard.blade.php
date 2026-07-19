<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Admin | Kang Digital</title>
    
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

        /* App Wrapper simulating the desktop application screen */
        .app-wrapper {
            width: 100%;
            max-width: 100%;
            background-color: var(--bg-card);
            border-radius: 0px;
            overflow: hidden;
            box-shadow: none;
            display: flex;
            position: relative;
            min-height: 100vh;
            border: none;
        }

        /* Hamburger Menu Trigger for Mobile */
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

        .menu-toggle, .panel-toggle {
            background: none;
            border: none;
            font-size: 24px;
            color: var(--text-main);
            cursor: pointer;
        }

        /* SIDEBAR (Left Column) */
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

        .logo-icon {
            width: 38px;
            height: 38px;
            background: linear-gradient(135deg, #8B5CF6, var(--primary));
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ffffff;
            font-size: 18px;
            box-shadow: 0 8px 16px rgba(108, 93, 211, 0.3);
        }

        .logo-text {
            font-family: var(--font-heading);
            font-size: 22px;
            font-weight: 800;
            color: var(--text-main);
            letter-spacing: -0.5px;
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

        /* Licenses Section inside Sidebar */
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

        /* MAIN CONTENT AREA (Middle Column) */
        main.main-content {
            flex: 1;
            padding: 40px;
            overflow-y: auto;
            height: 100vh;
            max-height: 100vh;
        }

        /* Top Bar styling */
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
            position: relative;
            transition: var(--transition);
        }

        .action-btn:hover {
            border-color: var(--primary);
            color: var(--primary);
            background-color: var(--primary-light);
        }

        .action-btn .badge-dot {
            position: absolute;
            top: 12px;
            right: 12px;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background-color: #FF5A5A;
            border: 2px solid var(--bg-card);
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

        .profile-avatar {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #ffffff;
            box-shadow: 0 4px 8px rgba(0,0,0,0.05);
        }

        .profile-name {
            font-size: 14px;
            font-weight: 700;
            color: var(--text-main);
        }

        .profile-arrow {
            font-size: 12px;
            color: var(--text-muted);
        }

        /* Banner Card */
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
            margin-bottom: 24px;
        }

        .banner-btn {
            background-color: #ffffff;
            color: var(--text-main);
            border: none;
            padding: 12px 24px;
            border-radius: 16px;
            font-weight: 700;
            font-size: 14px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 12px;
            transition: var(--transition);
            box-shadow: 0 10px 20px rgba(0,0,0,0.08);
        }

        .banner-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 24px rgba(0,0,0,0.15);
        }

        .btn-arrow {
            width: 24px;
            height: 24px;
            background-color: var(--text-main);
            color: #ffffff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 10px;
        }

        .banner-btn:hover .btn-arrow {
            background-color: var(--primary);
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

        .sparkle-small {
            position: absolute;
            right: 0;
            top: 10px;
            animation: float 4s ease-in-out infinite alternate;
        }

        @keyframes float {
            0% { transform: translateY(0px) scale(0.9); }
            100% { transform: translateY(-10px) scale(1.1); }
        }

        /* Progress Chips Grid */
        .progress-chips-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 32px;
        }

        .progress-chip {
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 16px 20px;
            display: flex;
            align-items: center;
            gap: 16px;
            position: relative;
            transition: var(--transition);
            cursor: pointer;
        }

        .progress-chip:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-subtle);
            border-color: var(--primary);
        }

        .chip-icon {
            width: 44px;
            height: 44px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            color: #ffffff;
            flex-shrink: 0;
        }

        .icon-purple {
            background: linear-gradient(135deg, #a78bfa, #7c3aed);
            box-shadow: 0 6px 12px rgba(124, 58, 237, 0.15);
        }

        .icon-pink {
            background: linear-gradient(135deg, #f472b6, #db2777);
            box-shadow: 0 6px 12px rgba(219, 39, 119, 0.15);
        }

        .icon-blue {
            background: linear-gradient(135deg, #60a5fa, #2563eb);
            box-shadow: 0 6px 12px rgba(37, 99, 235, 0.15);
        }

        .chip-content {
            display: flex;
            flex-direction: column;
            flex-grow: 1;
        }

        .chip-subtitle {
            font-size: 11px;
            color: var(--text-muted);
            font-weight: 500;
        }

        .chip-title {
            font-size: 14px;
            font-weight: 700;
            color: var(--text-main);
            margin-top: 2px;
        }

        .chip-more {
            background: none;
            border: none;
            color: var(--text-light);
            cursor: pointer;
            font-size: 14px;
            padding: 4px;
        }

        .chip-more:hover {
            color: var(--text-main);
        }

        /* Section Container */
        .section-container {
            margin-bottom: 32px;
        }

        .section-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
        }

        .section-header h2 {
            font-family: var(--font-heading);
            font-size: 20px;
            font-weight: 800;
            color: var(--text-main);
        }

        .see-all-link {
            font-size: 13px;
            font-weight: 700;
            color: var(--primary);
            text-decoration: none;
            transition: var(--transition);
        }

        .see-all-link:hover {
            color: #4D3DB5;
        }

        /* Form elements inside dashboard */
        .dash-form {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .form-group label {
            font-size: 12px;
            font-weight: 700;
            color: var(--text-muted);
        }

        .form-group input, .form-group select, .form-group textarea {
            padding: 12px 16px;
            border-radius: 12px;
            border: 1px solid var(--border-color);
            background-color: var(--bg-card);
            font-family: var(--font-sans);
            font-size: 14px;
            color: var(--text-main);
            outline: none;
            transition: var(--transition);
        }

        .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px var(--primary-glow);
        }

        .btn-action {
            background-color: var(--primary);
            color: #ffffff;
            border: none;
            padding: 12px 20px;
            border-radius: 12px;
            font-weight: 700;
            font-size: 14px;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            transition: var(--transition);
        }

        .btn-action:hover {
            background-color: #4D3DB5;
            transform: translateY(-1px);
        }

        /* Modern Table Card style */
        .table-card {
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 24px;
            overflow: hidden;
            box-shadow: var(--shadow-subtle);
            margin-bottom: 24px;
        }

        .table-responsive {
            width: 100%;
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }

        th {
            padding: 18px 24px;
            background-color: var(--bg-panel);
            color: var(--text-muted);
            font-weight: 700;
            font-size: 12px;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            border-bottom: 1px solid var(--border-color);
        }

        td {
            padding: 18px 24px;
            border-bottom: 1px solid var(--border-color);
            color: var(--text-main);
            font-size: 14px;
            vertical-align: middle;
        }

        tr:last-child td {
            border-bottom: none;
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

        /* Buttons in table */
        .btn-delete {
            background-color: rgba(255,90,90,0.08);
            border: 1px solid rgba(255,90,90,0.12);
            color: #FF5A5A;
            padding: 8px 14px;
            border-radius: 10px;
            font-weight: 700;
            font-size: 12px;
            cursor: pointer;
            transition: var(--transition);
        }

        .btn-delete:hover {
            background-color: #FF5A5A;
            color: #ffffff;
        }

        .btn-toggle {
            background-color: rgba(108, 93, 211, 0.08);
            border: 1px solid rgba(108, 93, 211, 0.12);
            color: var(--primary);
            padding: 8px 14px;
            border-radius: 10px;
            font-weight: 700;
            font-size: 12px;
            cursor: pointer;
            transition: var(--transition);
        }

        .btn-toggle:hover {
            background-color: var(--primary);
            color: #ffffff;
        }

        /* Member Info Box */
        .member-info {
            background-color: var(--bg-panel);
            border-radius: 16px;
            padding: 16px;
            margin-top: 10px;
            font-size: 12px;
            border: 1px solid var(--border-color);
        }

        .member-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px solid rgba(0,0,0,0.04);
        }

        .member-row:last-child {
            border-bottom: none;
        }

        .member-meta {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .member-actions {
            display: flex;
            gap: 6px;
        }

        /* RIGHT PANEL (Third Column) */
        aside.right-panel {
            width: 320px;
            background-color: var(--bg-panel);
            border-left: 1px solid var(--border-color);
            padding: 40px 24px;
            display: flex;
            flex-direction: column;
            gap: 32px;
            flex-shrink: 0;
            z-index: 10;
            height: 100vh;
            overflow-y: auto;
        }

        .panel-section-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
        }

        .panel-section-header h3 {
            font-family: var(--font-heading);
            font-size: 16px;
            font-weight: 800;
            color: var(--text-main);
        }

        /* Circular progress widget */
        .stat-card {
            background-color: var(--bg-card);
            border-radius: 24px;
            padding: 24px;
            border: 1px solid var(--border-color);
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
        }

        .circle-progress-wrapper {
            position: relative;
            margin-bottom: 20px;
        }

        .circular-progress {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background: conic-gradient(var(--primary) 0deg, #e2e8f0 0deg);
        }

        .avatar-inside {
            width: 84px;
            height: 84px;
            background-color: var(--bg-card);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }

        .memoji-avatar {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .progress-val-badge {
            position: absolute;
            top: -5px;
            right: -5px;
            background-color: var(--primary);
            color: #ffffff;
            font-size: 11px;
            font-weight: 800;
            padding: 4px 8px;
            border-radius: 10px;
            border: 2px solid var(--bg-card);
        }

        .stat-welcome-text {
            font-family: var(--font-heading);
            font-size: 16px;
            font-weight: 800;
            color: var(--text-main);
            margin-bottom: 4px;
        }

        .stat-subtitle-text {
            font-size: 12px;
            color: var(--text-muted);
            margin-bottom: 20px;
        }

        /* Bar Chart Widget */
        .bar-chart-container {
            width: 100%;
            padding-top: 15px;
            border-top: 1px solid var(--border-color);
        }

        .chart-bars {
            display: flex;
            justify-content: space-around;
            align-items: flex-end;
            height: 80px;
            margin-top: 10px;
        }

        .bar-group {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
            cursor: pointer;
        }

        .bar-column {
            width: 12px;
            height: 50px;
            background-color: #f1f5f9;
            border-radius: 6px;
            overflow: hidden;
            display: flex;
            align-items: flex-end;
        }

        .bar-fill {
            width: 100%;
            border-radius: 6px;
            transition: var(--transition);
        }

        .bar-fill-purple {
            background-color: var(--primary);
        }

        .bar-label {
            font-size: 10px;
            color: var(--text-muted);
            font-weight: 600;
        }

        /* Alerts & notifications */
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

        /* Tab panels visibility control */
        .tab-panel-content {
            display: none;
        }

        .tab-panel-content.active {
            display: block;
        }

        /* Stats Grid — same as stores page */
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

        /* Lead Card */
        .lead-card {
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 20px 24px;
            display: flex;
            align-items: flex-start;
            gap: 16px;
            margin-bottom: 16px;
            transition: var(--transition);
            box-shadow: var(--shadow-subtle);
        }

        .lead-card:hover {
            border-color: var(--primary);
            transform: translateY(-2px);
            box-shadow: var(--shadow-medium);
        }

        .lead-avatar {
            width: 44px;
            height: 44px;
            border-radius: 14px;
            background: linear-gradient(135deg, #6C5DD3, #3F8CFF);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-size: 18px;
            font-weight: 800;
            flex-shrink: 0;
            font-family: var(--font-heading);
        }

        .lead-body {
            flex: 1;
            min-width: 0;
        }

        .lead-name {
            font-family: var(--font-heading);
            font-size: 15px;
            font-weight: 800;
            color: var(--text-main);
            margin-bottom: 2px;
        }

        .lead-email {
            font-size: 12px;
            color: var(--text-muted);
            margin-bottom: 6px;
        }

        .lead-message {
            font-size: 13px;
            color: var(--text-main);
            background: var(--bg-panel);
            border-radius: 10px;
            padding: 8px 12px;
            border: 1px solid var(--border-color);
            line-height: 1.5;
            margin-bottom: 10px;
        }

        .lead-meta {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }

        /* License Collapsible Card — same as stores page */
        .license-card {
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 24px;
            margin-bottom: 20px;
            overflow: hidden;
            box-shadow: var(--shadow-subtle);
            transition: var(--transition);
        }

        .license-card:hover {
            border-color: var(--primary-glow);
            box-shadow: var(--shadow-medium);
        }

        .license-header-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 20px 24px;
            background-color: var(--bg-panel);
            border-bottom: 1px solid var(--border-color);
            cursor: pointer;
            transition: var(--transition);
        }

        .license-header-row:hover {
            background-color: var(--primary-light);
        }

        /* Service Card Grid */
        .services-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 32px;
        }

        .service-card-item {
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 24px;
            display: flex;
            flex-direction: column;
            gap: 12px;
            box-shadow: var(--shadow-subtle);
            transition: var(--transition);
        }

        .service-card-item:hover {
            border-color: var(--primary);
            transform: translateY(-4px);
            box-shadow: var(--shadow-medium);
        }

        .service-icon-box {
            width: 52px;
            height: 52px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
        }

        .empty-state {
            text-align: center;
            padding: 48px 24px;
            color: var(--text-muted);
        }

        .empty-state i {
            font-size: 48px;
            margin-bottom: 16px;
            opacity: 0.4;
            color: var(--text-light);
            display: block;
        }

        @media (max-width: 1200px) {
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
            .services-grid { grid-template-columns: 1fr; }
        }

        /* Responsive styling */
        @media (max-width: 1200px) {
            .app-wrapper {
                flex-direction: column;
                border-radius: 0;
                border: none;
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

            aside.right-panel {
                width: 100%;
                border-left: none;
                border-top: 1px solid var(--border-color);
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
        <button class="panel-toggle" id="panel-toggle">
            <i class="fa-solid fa-chart-pie"></i>
        </button>
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
                    <div class="menu-item active" data-tab="leads">
                        <i class="fa-solid fa-inbox"></i>
                        <span>Leads / Pesanan</span>
                    </div>
                    <div class="menu-item" data-tab="licenses">
                        <i class="fa-solid fa-key"></i>
                        <span>Lisensi & Member</span>
                    </div>
                    <div class="menu-item" data-tab="services">
                        <i class="fa-solid fa-list-check"></i>
                        <span>Layanan Dinamis</span>
                    </div>
                    <a href="{{ route('admin.stores') }}" class="menu-item" style="text-decoration:none; color: inherit;">
                        <i class="fa-solid fa-store"></i>
                        <span>Manajemen Toko</span>
                    </a>
                </nav>
            </div>
            
            <div class="menu-section">
                <span class="menu-title">LISENSI TERBARU</span>
                <ul class="friends-list">
                    @forelse($licenses->take(3) as $lic)
                        <li class="friend-item" onclick="switchTab('licenses')">
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
                    <div class="menu-item" data-tab="settings">
                        <i class="fa-solid fa-gears"></i>
                        <span>Setting Landing</span>
                    </div>
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
                    <input type="text" id="admin-search" placeholder="Cari data leads, lisensi, atau layanan....">
                </div>
                
                <div class="top-actions">
                    <button class="action-btn" onclick="switchTab('leads')">
                        <i class="fa-solid fa-envelope"></i>
                        @if($leads->count() > 0)
                            <span class="badge-dot"></span>
                        @endif
                    </button>
                    
                    <div class="user-profile" onclick="switchTab('settings')">
                        <div style="background: var(--primary); width: 38px; height: 38px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; border: 2px solid white; box-shadow: 0 4px 8px rgba(0,0,0,0.05);">
                            {{ strtoupper(substr(Auth::user()->name, 0, 1)) }}
                        </div>
                        <span class="profile-name">{{ Auth::user()->name }}</span>
                        <i class="fa-solid fa-chevron-down profile-arrow"></i>
                    </div>
                </div>
            </header>

            @if(session('success'))
                <div class="alert-success" style="margin-bottom: 24px;">
                    <i class="fa-solid fa-circle-check" style="font-size: 18px; color: var(--accent-green);"></i>
                    <span>{{ session('success') }}</span>
                </div>
            @endif

            <!-- TAB: LEADS / PESANAN -->
            <div id="tab-leads" class="tab-panel-content active">
                <section class="banner-card">
                    <div class="banner-info">
                        <span class="banner-tag">KANG DIGITAL ADMIN</span>
                        <h1 class="banner-title">Kelola Pesanan & Konsultasi Website, POS, dan Aplikasi</h1>
                        <button class="banner-btn" onclick="switchTab('services')">
                            <span>Layanan Dinamis</span>
                            <div class="btn-arrow">
                                <i class="fa-solid fa-arrow-right"></i>
                            </div>
                        </button>
                    </div>
                    <div class="banner-graphic">
                        <svg width="120" height="120" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path d="M50 0C50 27.6142 27.6142 50 0 50C27.6142 50 50 72.3858 50 100C50 72.3858 72.3858 50 100 50C72.3858 50 50 27.6142 50 0Z" fill="white" fill-opacity="0.25"/>
                        </svg>
                    </div>
                </section>

                <!-- Stats Grid for Leads -->
                <div class="stats-grid">
                    <div class="stat-card-custom">
                        <div class="stat-icon" style="background: linear-gradient(135deg, #a78bfa, #7c3aed);">
                            <i class="fa-solid fa-inbox"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-value">{{ $leads->count() }}</span>
                            <span class="stat-label">Total Leads</span>
                        </div>
                    </div>
                    <div class="stat-card-custom">
                        <div class="stat-icon" style="background: linear-gradient(135deg, #f472b6, #db2777);">
                            <i class="fa-solid fa-calendar-day"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-value">
                                {{ $leads->filter(fn($l) => $l->created_at && \Illuminate\Support\Carbon::parse($l->created_at)->isToday())->count() }}
                            </span>
                            <span class="stat-label">Hari Ini</span>
                        </div>
                    </div>
                    <div class="stat-card-custom">
                        <div class="stat-icon" style="background: linear-gradient(135deg, #60a5fa, #2563eb);">
                            <i class="fa-solid fa-calendar-week"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-value">
                                {{ $leads->filter(fn($l) => $l->created_at && \Illuminate\Support\Carbon::parse($l->created_at)->isAfter(now()->subWeek()))->count() }}
                            </span>
                            <span class="stat-label">7 Hari Terakhir</span>
                        </div>
                    </div>
                    <div class="stat-card-custom">
                        <div class="stat-icon" style="background: linear-gradient(135deg, #34d399, #059669);">
                            <i class="fa-brands fa-whatsapp"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-value">
                                {{ $leads->filter(fn($l) => !empty($l->phone))->count() }}
                            </span>
                            <span class="stat-label">Kontak WA</span>
                        </div>
                    </div>
                </div>

                <div class="section-container">
                    <div class="section-header">
                        <h2>Daftar Pesanan & Konsultasi Masuk</h2>
                    </div>
                    
                    <div id="leads-list-container">
                        @forelse($leads as $lead)
                            <div class="lead-card" data-name="{{ strtolower($lead->name) }}" data-email="{{ strtolower($lead->email) }}">
                                <div class="lead-avatar" style="background: linear-gradient(135deg, var(--primary), var(--accent-blue));">
                                    {{ strtoupper(substr($lead->name, 0, 1)) }}
                                </div>
                                <div class="lead-body">
                                    <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 12px; margin-bottom: 8px;">
                                        <div>
                                            <h3 class="lead-name" style="font-size: 16px; font-weight: 700; color: var(--text-main);">{{ $lead->name }}</h3>
                                            <div class="lead-email" style="font-size: 12px; color: var(--text-muted); margin-top: 2px;">
                                                <i class="fa-solid fa-envelope"></i> {{ $lead->email }}
                                            </div>
                                        </div>
                                        <form action="{{ route('admin.lead.delete', $lead->id) }}" method="POST" onsubmit="return confirm('Apakah Anda yakin ingin menghapus lead ini?')">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="btn btn-danger" style="padding: 6px 12px; font-size: 11px;">
                                                <i class="fa-solid fa-trash"></i> Hapus
                                            </button>
                                        </form>
                                    </div>
                                    <div class="lead-message" style="margin-bottom: 12px;">
                                        {{ $lead->message }}
                                    </div>
                                    <div class="lead-meta" style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 10px;">
                                        <a href="https://wa.me/{{ preg_replace('/[^0-9]/', '', $lead->phone) }}" target="_blank" class="btn btn-outline" style="padding: 6px 12px; font-size: 12px; color: var(--accent-green); border-color: rgba(55,209,89,0.2); background: rgba(55,209,89,0.04);">
                                            <i class="fa-brands fa-whatsapp" style="font-size: 14px;"></i> Hubungi via WhatsApp ({{ $lead->phone }})
                                        </a>
                                        <span style="font-size: 12px; color: var(--text-muted);">
                                            <i class="fa-solid fa-clock"></i> {{ $lead->created_at->format('d M Y, H:i') }} ({{ $lead->created_at->diffForHumans() }})
                                        </span>
                                    </div>
                                </div>
                            </div>
                        @empty
                            <div class="empty-state" style="background-color: var(--bg-card); border: 1px solid var(--border-color); border-radius: 20px;">
                                <i class="fa-solid fa-inbox"></i>
                                <p style="font-size: 15px; font-weight: 600;">Belum ada pesanan masuk.</p>
                            </div>
                        @endforelse
                    </div>
                </div>
            </div>

            <!-- TAB: LICENSES & MEMBER -->
            <div id="tab-licenses" class="tab-panel-content">
                <section class="banner-card">
                    <div class="banner-info">
                        <span class="banner-tag">KANG DIGITAL ADMIN</span>
                        <h1 class="banner-title">Kelola Kunci Lisensi & Member Pengguna Aplikasi Kasir</h1>
                    </div>
                    <div class="banner-graphic">
                        <svg width="120" height="120" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path d="M50 0C50 27.6142 27.6142 50 0 50C27.6142 50 50 72.3858 50 100C50 72.3858 72.3858 50 100 50C72.3858 50 50 27.6142 50 0Z" fill="white" fill-opacity="0.25"/>
                        </svg>
                    </div>
                </section>

                <!-- Stats Grid for Licenses -->
                <div class="stats-grid">
                    <div class="stat-card-custom">
                        <div class="stat-icon" style="background: linear-gradient(135deg, #a78bfa, #7c3aed);">
                            <i class="fa-solid fa-key"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-value">{{ $licenses->count() }}</span>
                            <span class="stat-label">Total Lisensi</span>
                        </div>
                    </div>
                    <div class="stat-card-custom">
                        <div class="stat-icon" style="background: linear-gradient(135deg, #34d399, #059669);">
                            <i class="fa-solid fa-circle-check"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-value">{{ $licenses->where('status', 'active')->count() }}</span>
                            <span class="stat-label">Lisensi Aktif</span>
                        </div>
                    </div>
                    <div class="stat-card-custom">
                        <div class="stat-icon" style="background: linear-gradient(135deg, #60a5fa, #2563eb);">
                            <i class="fa-solid fa-users"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-value">{{ $licenses->sum(fn($lic) => $lic->kasirUsers->count()) }}</span>
                            <span class="stat-label">Total Member</span>
                        </div>
                    </div>
                    <div class="stat-card-custom">
                        <div class="stat-icon" style="background: linear-gradient(135deg, #f472b6, #db2777);">
                            <i class="fa-solid fa-wallet"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-value">Rp {{ number_format($licenses->sum('price') / 1000, 0, ',', '.') }}K</span>
                            <span class="stat-label">Estimasi Omzet</span>
                        </div>
                    </div>
                </div>

                <div class="section-container" style="display: grid; grid-template-columns: 2fr 1.1fr; gap: 24px; align-items: start;">
                    <!-- Licenses Cards List -->
                    <div>
                        <div class="section-header">
                            <h2>Daftar Lisensi Kasir UMKM</h2>
                        </div>
                        
                        <div id="licenses-list-container">
                            @forelse($licenses as $lic)
                                <div class="license-card" data-key="{{ strtolower($lic->license_key) }}">
                                    <div class="license-header-row" onclick="toggleLicenseDetails('license-details-{{ $lic->id }}')" style="display: flex; align-items: center; justify-content: space-between; padding: 20px 24px; background-color: var(--bg-panel); border-bottom: 1px solid var(--border-color); cursor: pointer;">
                                        <div class="license-info">
                                            <div style="display:flex; align-items:center; gap:12px; flex-wrap: wrap;">
                                                <span style="font-size:16px; font-weight:800; color:var(--primary); font-family:monospace;">
                                                    {{ $lic->license_key }}
                                                </span>
                                                @if($lic->status === 'active')
                                                    <span class="badge badge-success">Aktif</span>
                                                @elseif($lic->status === 'inactive')
                                                    <span class="badge badge-warning">Belum Aktif</span>
                                                @elseif($lic->status === 'expired')
                                                    <span class="badge badge-danger">Expired</span>
                                                @else
                                                    <span class="badge badge-info">{{ $lic->status }}</span>
                                                @endif
                                            </div>
                                            <div style="font-size:12px; color:var(--text-muted); margin-top:6px; font-weight: 500; display: flex; flex-wrap: wrap; gap: 8px; align-items: center;">
                                                <span>Durasi: <strong>{{ ucfirst($lic->duration_type ?: '1_year') }}</strong></span> •
                                                <span>Device: <strong>{{ !empty($lic->device_id) ? count(explode(',', $lic->device_id)) : 0 }} / {{ $lic->device_limit }}</strong></span> •
                                                <span>Harga: <strong>Rp {{ number_format($lic->price ?: 0, 0, ',', '.') }}</strong></span> •
                                                <span>Member: <strong>{{ $lic->kasirUsers->count() }} User</strong></span>
                                                @if($lic->expires_at)
                                                    • <span>Exp: <strong>{{ $lic->expires_at->format('d/m/Y') }}</strong></span>
                                                @else
                                                    • <span style="color:var(--accent-green); font-weight:700;">Lifetime</span>
                                                @endif
                                            </div>
                                        </div>
                                        <div style="display:flex; align-items:center; gap:16px;">
                                            <button class="btn btn-outline" onclick="event.stopPropagation(); toggleLicenseDetails('license-details-{{ $lic->id }}')">
                                                <i class="fa-solid fa-users-gear"></i> Kelola
                                            </button>
                                            <i class="fa-solid fa-chevron-down" style="color: var(--text-light); transition: transform 0.3s;" id="arrow-lic-{{ $lic->id }}"></i>
                                        </div>
                                    </div>

                                    <!-- License details / member management (collapsible) -->
                                    <div id="license-details-{{ $lic->id }}" style="display: none;">
                                        <!-- Member Grid -->
                                        <div style="padding: 20px 24px 10px; background-color: #fafbfc; border-bottom: 1px solid var(--border-color);">
                                            <h4 style="font-size: 13px; font-weight: 800; margin-bottom: 12px; color: var(--text-main);"><i class="fa-solid fa-users"></i> Pengguna Terdaftar (Member)</h4>
                                            @if($lic->kasirUsers->isEmpty())
                                                <div class="empty-state" style="padding: 20px;">
                                                    <i class="fa-solid fa-user-slash" style="font-size: 32px; display: block; margin: 0 auto 10px;"></i>
                                                    <p style="font-size: 13px;">Belum ada member terdaftar.</p>
                                                </div>
                                            @else
                                                <div class="members-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 16px; margin-bottom: 12px;">
                                                    @foreach($lic->kasirUsers as $ku)
                                                    <div style="background-color: var(--bg-card); border: 1px solid var(--border-color); border-radius: 16px; padding: 16px; display: flex; flex-direction: column; gap: 12px; box-shadow: var(--shadow-subtle);">
                                                        <div style="display: flex; align-items: center; justify-content: space-between;">
                                                            <div style="display: flex; align-items: center; gap: 8px;">
                                                                @if($ku->is_active)
                                                                    <span class="badge badge-success" style="padding: 4px 8px; font-size: 9px;"><i class="fa-solid fa-circle"></i> Aktif</span>
                                                                @else
                                                                    <span class="badge badge-danger" style="padding: 4px 8px; font-size: 9px;"><i class="fa-solid fa-circle"></i> Nonaktif</span>
                                                                @endif
                                                                <span class="badge badge-info" style="padding: 4px 8px; font-size: 9px; text-transform: uppercase;">{{ $ku->role }}</span>
                                                            </div>
                                                        </div>
                                                        <div>
                                                            <div style="font-weight: 700; font-size: 14px; color: var(--text-main);">{{ $ku->name }}</div>
                                                            <div style="font-size: 12px; color: var(--text-muted); font-family: monospace; margin-top: 2px;">@ {{ $ku->username }}</div>
                                                        </div>
                                                        <div style="display: flex; gap: 8px; margin-top: auto; border-top: 1px solid var(--border-color); padding-top: 12px;">
                                                            <form action="{{ route('admin.member.toggle', $ku->id) }}" method="POST" style="flex: 1; margin: 0;">
                                                                @csrf
                                                                <button type="submit" class="btn btn-outline" style="width: 100%; padding: 6px; font-size: 11px;" title="Aktif/Nonaktifkan Member">
                                                                    <i class="fa-solid fa-power-off"></i> Toggle
                                                                </button>
                                                            </form>
                                                            
                                                            <button type="button" onclick="togglePasswordBox('pwd-box-{{ $ku->id }}')" class="btn btn-outline" style="flex: 1; padding: 6px; font-size: 11px;" title="Ganti Password">
                                                                <i class="fa-solid fa-key"></i> Sandi
                                                            </button>

                                                            <form action="{{ route('admin.member.delete', $ku->id) }}" method="POST" onsubmit="return confirm('Hapus member {{ $ku->username }}?')" style="display:inline; margin: 0;">
                                                                @csrf
                                                                @method('DELETE')
                                                                <button type="submit" class="btn btn-danger" style="padding: 6px 10px; font-size: 11px;" title="Hapus Member">
                                                                    <i class="fa-solid fa-trash"></i>
                                                                </button>
                                                            </form>
                                                        </div>
                                                        
                                                        <div id="pwd-box-{{ $ku->id }}" style="display: none; margin-top: 8px; background-color: var(--bg-panel); padding: 10px; border: 1px solid var(--border-color); border-radius: 10px;">
                                                            <form action="{{ route('admin.member.change-password', $ku->id) }}" method="POST" style="display: flex; gap: 6px; margin: 0;">
                                                                @csrf
                                                                <input type="password" name="password" placeholder="Sandi baru" style="padding: 6px 10px; font-size: 11px; flex-grow:1; border: 1px solid var(--border-color); border-radius: 8px; width: 60%;" required>
                                                                <button type="submit" class="btn btn-primary" style="padding: 6px 12px; font-size: 11px; border-radius: 8px;">Simpan</button>
                                                            </form>
                                                        </div>
                                                    </div>
                                                    @endforeach
                                                </div>
                                            @endif
                                        </div>

                                        <!-- Add member and edit license parameters -->
                                        <div style="background-color: #fafbfc; border-top: 1px solid var(--border-color); padding: 20px 24px; display: grid; grid-template-columns: 1.2fr 1fr; gap: 20px;">
                                            <!-- Column 1: Add member -->
                                            <div style="background-color: var(--bg-card); border: 1px dashed var(--primary); border-radius: 16px; padding: 20px; box-shadow: var(--shadow-subtle);">
                                                <h4 style="font-size: 13px; font-weight: 800; margin-bottom: 12px; color: var(--primary);"><i class="fa-solid fa-plus-circle"></i> Tambah Member Baru</h4>
                                                <form action="{{ route('admin.member.create') }}" method="POST" style="display:flex; flex-direction:column; gap:12px; margin: 0;">
                                                    @csrf
                                                    <input type="hidden" name="license_id" value="{{ $lic->id }}">
                                                    <div style="display:grid; grid-template-columns:1fr 1fr; gap:10px;">
                                                        <div class="form-group" style="gap:2px;">
                                                            <label style="font-size:10px;">Username</label>
                                                            <input type="text" name="username" placeholder="Username" style="padding: 8px 10px; font-size: 12px;" required>
                                                        </div>
                                                        <div class="form-group" style="gap:2px;">
                                                            <label style="font-size:10px;">Nama Tampilan</label>
                                                            <input type="text" name="name" placeholder="Nama Lengkap" style="padding: 8px 10px; font-size: 12px;" required>
                                                        </div>
                                                    </div>
                                                    <div style="display:grid; grid-template-columns:1fr 1fr; gap:10px;">
                                                        <div class="form-group" style="gap:2px;">
                                                            <label style="font-size:10px;">Password</label>
                                                            <input type="password" name="password" placeholder="Min 6 karakter" style="padding: 8px 10px; font-size: 12px;" required>
                                                        </div>
                                                        <div class="form-group" style="gap:2px;">
                                                            <label style="font-size:10px;">Role</label>
                                                            <select name="role" style="padding: 8px 10px; font-size: 12px;" required>
                                                                <option value="cashier">Cashier (Kasir)</option>
                                                                <option value="admin">Admin Toko (Owner)</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <button type="submit" class="btn btn-primary" style="padding:10px; font-size:12px; width: 100%;">Simpan Member Baru</button>
                                                </form>
                                            </div>

                                            <!-- Column 2: Edit license parameters -->
                                            <div style="background-color: var(--bg-card); border: 1px solid var(--border-color); border-radius: 16px; padding: 20px; box-shadow: var(--shadow-subtle);">
                                                <h4 style="font-size: 13px; font-weight: 800; margin-bottom: 12px; color: var(--accent-blue);"><i class="fa-solid fa-pen-to-square"></i> Edit Parameter Lisensi</h4>
                                                <form action="{{ route('admin.license.update', $lic->id) }}" method="POST" style="display: flex; flex-direction:column; gap: 12px; margin: 0;">
                                                    @csrf
                                                    <div style="display:grid; grid-template-columns:1fr 1fr; gap:10px;">
                                                        <div class="form-group" style="gap:2px;">
                                                            <label style="font-size:10px;">Limit Device</label>
                                                            <input type="number" name="device_limit" value="{{ $lic->device_limit }}" min="1" style="padding:8px; font-size:12px;" required>
                                                        </div>
                                                        <div class="form-group" style="gap:2px;">
                                                            <label style="font-size:10px;">Harga (Rp)</label>
                                                            <input type="number" name="price" value="{{ $lic->price }}" min="0" style="padding:8px; font-size:12px;" required>
                                                        </div>
                                                    </div>
                                                    <div style="display:grid; grid-template-columns:1fr 1fr; gap:10px;">
                                                        <div class="form-group" style="gap:2px;">
                                                            <label style="font-size:10px;">Status</label>
                                                            <select name="status" style="padding:8px; font-size:12px;" required>
                                                                    <option value="active" {{ $lic->status == 'active' ? 'selected' : '' }}>Aktif</option>
                                                                    <option value="inactive" {{ $lic->status == 'inactive' ? 'selected' : '' }}>Belum Aktif</option>
                                                                    <option value="expired" {{ $lic->status == 'expired' ? 'selected' : '' }}>Expired</option>
                                                                    <option value="deactivated" {{ $lic->status == 'deactivated' ? 'selected' : '' }}>Deactivated</option>
                                                            </select>
                                                        </div>
                                                        <div class="form-group" style="gap:2px;">
                                                            <label style="font-size:10px;">Perpanjang</label>
                                                            <select name="action_type" style="padding:8px; font-size:12px;" required>
                                                                <option value="none">Tidak Perlu</option>
                                                                <option value="extend_month">+1 Bulan</option>
                                                                <option value="extend_year">+1 Tahun</option>
                                                                <option value="extend_lifetime">Lifetime</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div style="display: flex; gap: 8px; margin-top: 4px;">
                                                        <button type="submit" class="btn btn-primary" style="flex: 1; padding: 10px; font-size: 12px;">Simpan</button>
                                                        <button type="button" class="btn btn-danger" style="padding: 10px; font-size: 12px;" onclick="if(confirm('Hapus lisensi {{ $lic->license_key }}? Semua member di bawah lisensi ini akan terhapus.')) { document.getElementById('delete-lic-form-{{ $lic->id }}').submit(); }">
                                                            <i class="fa-solid fa-trash"></i>
                                                        </button>
                                                    </div>
                                                </form>
                                                <form id="delete-lic-form-{{ $lic->id }}" action="{{ route('admin.license.delete', $lic->id) }}" method="POST" style="display:none;">
                                                    @csrf
                                                    @method('DELETE')
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            @empty
                                <div class="empty-state" style="background-color: var(--bg-card); border: 1px solid var(--border-color); border-radius: 20px;">
                                    <i class="fa-solid fa-key"></i>
                                    <p style="font-size: 15px; font-weight: 600;">Belum ada lisensi terdaftar.</p>
                                </div>
                            @endforelse
                        </div>
                    </div>

                    <!-- Create License Card -->
                    <div>
                        <div class="section-header">
                            <h2>Buat Lisensi</h2>
                        </div>
                        
                        <div class="table-card" style="padding: 24px;">
                            <form action="{{ route('admin.license.create') }}" method="POST" class="dash-form" style="margin: 0;">
                                @csrf
                                <div class="form-group">
                                    <label for="custom_key">Kunci Lisensi Kustom</label>
                                    <input type="text" name="custom_key" id="custom_key" placeholder="Contoh: KASIR-UMKM-TOKO-A">
                                    <span style="font-size: 11px; color: var(--text-muted); margin-top:4px;">Kosongkan untuk auto-generate.</span>
                                </div>
 
                                <div class="form-group">
                                    <label for="duration">Durasi Lisensi</label>
                                    <select name="duration" id="duration" onchange="updateLicenseDefaults()" required>
                                        <option value="1_month">Sewa Bulanan (Rp 29.000)</option>
                                        <option value="1_year" selected>Sewa Tahunan (Rp 249.000)</option>
                                        <option value="lifetime">Premium Lifetime (Rp 499.000)</option>
                                    </select>
                                </div>

                                <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
                                    <div class="form-group">
                                        <label for="device_limit">Batas Device</label>
                                        <input type="number" name="device_limit" id="device_limit" value="1" min="1" required>
                                    </div>
                                    <div class="form-group">
                                        <label for="price">Harga Lisensi (Rp)</label>
                                        <input type="number" name="price" id="price" value="249000" min="0" required>
                                    </div>
                                </div>
 
                                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 10px; padding: 12px;">Buat Lisensi Baru</button>
                            </form>
                            
                            <div style="margin-top: 16px; font-size: 11px; color: var(--text-muted); border-top: 1px solid var(--border-color); padding-top: 12px; line-height: 1.4;">
                                <strong>Info:</strong> Pembuatan lisensi baru otomatis membuatkan satu akun member bertipe <em>Admin (Owner)</em> dengan password default <code>password123</code>.
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- TAB: DYNAMIC SERVICES -->
            <div id="tab-services" class="tab-panel-content">
                <section class="banner-card">
                    <div class="banner-info">
                        <span class="banner-tag">KANG DIGITAL ADMIN</span>
                        <h1 class="banner-title">Kelola Layanan Dinamis di Landing Page</h1>
                    </div>
                    <div class="banner-graphic">
                        <svg width="120" height="120" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path d="M50 0C50 27.6142 27.6142 50 0 50C27.6142 50 50 72.3858 50 100C50 72.3858 72.3858 50 100 50C72.3858 50 50 27.6142 50 0Z" fill="white" fill-opacity="0.25"/>
                        </svg>
                    </div>
                </section>

                <!-- Stats Grid for Services -->
                <div class="stats-grid">
                    <div class="stat-card-custom">
                        <div class="stat-icon" style="background: linear-gradient(135deg, #a78bfa, #7c3aed);">
                            <i class="fa-solid fa-list-check"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-value">{{ $services->count() }}</span>
                            <span class="stat-label">Total Layanan</span>
                        </div>
                    </div>
                    <div class="stat-card-custom">
                        <div class="stat-icon" style="background: linear-gradient(135deg, #34d399, #059669);">
                            <i class="fa-solid fa-tags"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-value">
                                {{ $services->filter(fn($s) => !empty($s->price) && strtolower($s->price) !== 'gratis')->count() }}
                            </span>
                            <span class="stat-label">Layanan Premium</span>
                        </div>
                    </div>
                    <div class="stat-card-custom">
                        <div class="stat-icon" style="background: linear-gradient(135deg, #60a5fa, #2563eb);">
                            <i class="fa-solid fa-gift"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-value">
                                {{ $services->filter(fn($s) => empty($s->price) || strtolower($s->price) === 'gratis')->count() }}
                            </span>
                            <span class="stat-label">Layanan Gratis</span>
                        </div>
                    </div>
                    <div class="stat-card-custom">
                        <div class="stat-icon" style="background: linear-gradient(135deg, #f472b6, #db2777);">
                            <i class="fa-solid fa-icons"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-value">
                                {{ $services->pluck('icon')->unique()->count() }}
                            </span>
                            <span class="stat-label">Kategori Ikon</span>
                        </div>
                    </div>
                </div>

                <div class="section-container" style="display: grid; grid-template-columns: 2fr 1.1fr; gap: 24px; align-items: start;">
                    <!-- Services Grid List -->
                    <div>
                        <div class="section-header">
                            <h2>Daftar Layanan Dinamis</h2>
                        </div>
                        
                        <div class="services-grid">
                            @forelse($services as $serv)
                                <div class="service-card-item" data-title="{{ strtolower($serv->title) }}">
                                    <div style="display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-bottom: 8px;">
                                        <div class="service-icon-box" style="background-color: var(--primary-light); color: var(--primary); width: 52px; height: 52px; border-radius: 16px; display: flex; align-items: center; justify-content: center; font-size: 22px;">
                                            @if($serv->icon == 'globe')
                                                <i class="fa-solid fa-globe"></i>
                                            @elseif($serv->icon == 'smartphone')
                                                <i class="fa-solid fa-mobile-screen-button"></i>
                                            @elseif($serv->icon == 'shopping-cart')
                                                <i class="fa-solid fa-cart-shopping" style="color: var(--secondary);"></i>
                                            @else
                                                <i class="fa-solid fa-chart-line"></i>
                                            @endif
                                        </div>
                                        <form action="{{ route('admin.service.delete', $serv->id) }}" method="POST" onsubmit="return confirm('Hapus layanan ini dari landing page?')" style="margin: 0;">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="btn btn-danger" style="padding: 8px 12px; font-size: 11px;">
                                                <i class="fa-solid fa-trash"></i> Hapus
                                            </button>
                                        </form>
                                    </div>
                                    
                                    <h3 style="font-family: var(--font-heading); font-size: 18px; font-weight: 700; color: var(--text-main); margin-bottom: 8px;">{{ $serv->title }}</h3>
                                    
                                    <p style="font-size: 13px; color: var(--text-muted); line-height: 1.5; flex-grow: 1; margin-bottom: 12px;">
                                        {{ $serv->description }}
                                    </p>
                                    
                                    <div style="display: flex; align-items: center; justify-content: space-between; border-top: 1px solid var(--border-color); padding-top: 12px; margin-top: auto;">
                                        <span style="font-size: 11px; text-transform: uppercase; font-weight: 700; color: var(--text-light);">Estimasi Biaya</span>
                                        <span style="font-size: 14px; font-weight: 800; color: var(--accent-green);">
                                            {{ $serv->price ?: 'Gratis / Konsultasi' }}
                                        </span>
                                    </div>
                                </div>
                            @empty
                                <div class="empty-state" style="grid-column: 1 / -1; background-color: var(--bg-card); border: 1px solid var(--border-color); border-radius: 20px;">
                                    <i class="fa-solid fa-list-check"></i>
                                    <p style="font-size: 15px; font-weight: 600;">Belum ada layanan dinamis.</p>
                                </div>
                            @endforelse
                        </div>
                    </div>

                    <!-- Add Service Card -->
                    <div>
                        <div class="section-header">
                            <h2>Tambah Layanan</h2>
                        </div>
                        
                        <div class="table-card" style="padding: 24px;">
                            <form action="{{ route('admin.service.create') }}" method="POST" class="dash-form" style="margin: 0;">
                                @csrf
                                <div class="form-group">
                                    <label for="title">Judul Layanan</label>
                                    <input type="text" name="title" id="title" placeholder="Contoh: Jasa SEO Web" required>
                                </div>

                                <div class="form-group">
                                    <label for="icon">Ikon Layanan</label>
                                    <select name="icon" id="icon" required>
                                        <option value="globe">Globe (Web/Domain)</option>
                                        <option value="smartphone">Smartphone (App Android/iOS)</option>
                                        <option value="shopping-cart">Shopping Cart (POS/Toko)</option>
                                        <option value="chart-line">Chart Line (Optimasi/SEO)</option>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label for="price">Harga Tampilan (Opsional)</label>
                                    <input type="text" name="price" id="price" placeholder="Contoh: Mulai Rp 500.000">
                                </div>

                                <div class="form-group">
                                    <label for="description">Deskripsi Layanan</label>
                                    <textarea name="description" id="description" placeholder="Jelaskan detail layanan..." required></textarea>
                                </div>

                                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 10px; padding: 12px;">Tambah Layanan</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <!-- TAB: SETTINGS -->
            <div id="tab-settings" class="tab-panel-content">
                <div class="section-container">
                    <div class="section-header">
                        <h2>Pengaturan Landing Page & SEO</h2>
                    </div>
                    
                    <div class="table-card" style="padding: 30px;">
                        <form action="{{ route('admin.setting.update') }}" method="POST" class="dash-form" style="margin: 0;">
                            @csrf
                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 30px;">
                                
                                <!-- Col 1: SEO & Identity -->
                                <div style="display:flex; flex-direction:column; gap:16px;">
                                    <h3 style="font-size:14px; font-weight:800; border-bottom:1px solid var(--border-color); padding-bottom:8px; color:var(--primary);"><i class="fa-solid fa-bullhorn"></i> Identitas & SEO Metadata</h3>
                                    
                                    <div class="form-group">
                                        <label for="site_title">Meta Title Website</label>
                                        <input type="text" name="site_title" id="site_title" value="{{ $settings['site_title'] }}" required>
                                    </div>
                                    
                                    <div class="form-group">
                                        <label for="site_description">Meta Description Website</label>
                                        <textarea name="site_description" id="site_description" rows="3" required>{{ $settings['site_description'] }}</textarea>
                                    </div>

                                    <div class="form-group">
                                        <label for="site_keywords">Meta Keywords Website</label>
                                        <input type="text" name="site_keywords" id="site_keywords" value="{{ $settings['site_keywords'] }}" required>
                                    </div>

                                    <div class="form-group">
                                        <label for="seo_cities">Geotargeting Kota (Geo AIO)</label>
                                        <textarea name="seo_cities" id="seo_cities" rows="3" required>{{ $settings['seo_cities'] }}</textarea>
                                        <span style="font-size:11px; color:var(--text-muted); margin-top:4px;">Pemisah koma. Sistem mendukung route lokal SEO seperti: <code>/aplikasi-kasir-umkm-di-gresik</code></span>
                                    </div>

                                    <div class="form-group">
                                        <label for="seo_geotargeting_enabled">Aktifkan Dynamic Geotargeting SEO</label>
                                        <select name="seo_geotargeting_enabled" id="seo_geotargeting_enabled" required>
                                            <option value="1" {{ $settings['seo_geotargeting_enabled'] == '1' ? 'selected' : '' }}>Ya (Sangat Direkomendasikan)</option>
                                            <option value="0" {{ $settings['seo_geotargeting_enabled'] == '0' ? 'selected' : '' }}>Tidak</option>
                                        </select>
                                    </div>
                                </div>

                                <!-- Col 2: Content & WhatsApp -->
                                <div style="display:flex; flex-direction:column; gap:16px;">
                                    <h3 style="font-size:14px; font-weight:800; border-bottom:1px solid var(--border-color); padding-bottom:8px; color:var(--primary);"><i class="fa-solid fa-comment-dots"></i> Konten Halaman & Kontak</h3>

                                    <div class="form-group">
                                        <label for="whatsapp_number">Nomor WhatsApp (Kode Negara: 62xxxx)</label>
                                        <input type="text" name="whatsapp_number" id="whatsapp_number" value="{{ $settings['whatsapp_number'] }}" required>
                                    </div>

                                    <div class="form-group">
                                        <label for="whatsapp_text">Default Pesan Hubungi Kami WhatsApp</label>
                                        <textarea name="whatsapp_text" id="whatsapp_text" rows="2" required>{{ $settings['whatsapp_text'] }}</textarea>
                                    </div>

                                    <div class="form-group">
                                        <label for="hero_title">Judul Hero (Headline Utama)</label>
                                        <input type="text" name="hero_title" id="hero_title" value="{{ $settings['hero_title'] }}" required>
                                    </div>

                                    <div class="form-group">
                                        <label for="hero_description">Deskripsi Hero</label>
                                        <textarea name="hero_description" id="hero_description" rows="3" required>{{ $settings['hero_description'] }}</textarea>
                                    </div>

                                    <h3 style="font-size:14px; font-weight:800; border-bottom:1px solid var(--border-color); padding-bottom:8px; margin-top:10px; color:var(--secondary);"><i class="fa-solid fa-mobile"></i> Mockup Aplikasi Android & Link Unduh</h3>

                                    <div style="display:grid; grid-template-columns: 2fr 1fr; gap:10px;">
                                        <div class="form-group">
                                            <label for="app_mockup_title">Nama Aplikasi Mockup</label>
                                            <input type="text" name="app_mockup_title" id="app_mockup_title" value="{{ $settings['app_mockup_title'] }}" required>
                                        </div>
                                        <div class="form-group">
                                            <label for="app_mockup_version">Versi APK</label>
                                            <input type="text" name="app_mockup_version" id="app_mockup_version" value="{{ $settings['app_mockup_version'] }}" required>
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label for="app_mockup_description">Deskripsi Aplikasi Mockup</label>
                                        <input type="text" name="app_mockup_description" id="app_mockup_description" value="{{ $settings['app_mockup_description'] }}" required>
                                    </div>

                                    <div class="form-group">
                                        <label for="app_download_url">Link Download File APK Kasir</label>
                                        <input type="url" name="app_download_url" id="app_download_url" value="{{ $settings['app_download_url'] }}" required>
                                    </div>
                                </div>

                             </div>

                            <button type="submit" class="btn btn-primary" style="margin-top: 20px; padding: 12px 30px;">
                                <i class="fa-solid fa-floppy-disk"></i> Simpan Semua Perubahan Pengaturan
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Hidden logout form -->
    <form id="logout-form" action="{{ route('admin.logout') }}" method="POST" style="display: none;">
        @csrf
    </form>

    <!-- JavaScript interactions -->
    <script>
        // Tab switching logic
        const menuItems = document.querySelectorAll('.menu-item');
        const tabPanels = document.querySelectorAll('.tab-panel-content');
        const searchInput = document.getElementById('admin-search');

        function switchTab(tabId) {
            if (!tabId) return;

            // Deactivate all menu items and panels
            menuItems.forEach(mi => mi.classList.remove('active'));
            tabPanels.forEach(tp => tp.classList.remove('active'));

            // Activate selected menu item & tab panel
            const targetMenuItem = document.querySelector(`.menu-item[data-tab="${tabId}"]`);
            if (targetMenuItem) {
                targetMenuItem.classList.add('active');
            }
            const targetPanel = document.getElementById('tab-' + tabId);
            if (targetPanel) {
                targetPanel.classList.add('active');
            }

            // Clear search on tab switch
            if (searchInput) {
                searchInput.value = '';
                // Reset visibility of elements
                const activeTabEl = document.querySelector('.tab-panel-content.active');
                if (activeTabEl) {
                    activeTabEl.querySelectorAll('.lead-card, .license-card, .service-card-item').forEach(el => {
                        el.style.display = (el.classList.contains('license-card') ? 'block' : 'flex');
                    });
                }
            }
            
            // Update URL query parameter without page reload
            const url = new URL(window.location);
            url.searchParams.set('tab', tabId);
            window.history.pushState({}, '', url);
        }

        menuItems.forEach(item => {
            item.addEventListener('click', () => {
                const tabId = item.getAttribute('data-tab');
                switchTab(tabId);
            });
        });

        // Load tab from URL query param if present
        const urlParams = new URLSearchParams(window.location.search);
        const activeTab = urlParams.get('tab');
        if (activeTab) {
            switchTab(activeTab);
        }

        // Search Filter
        if (searchInput) {
            searchInput.addEventListener('input', function() {
                const query = this.value.toLowerCase().trim();
                const activeTabEl = document.querySelector('.tab-panel-content.active');
                if (!activeTabEl) return;
                
                const tabId = activeTabEl.id;
                if (tabId === 'tab-leads') {
                    const leadCards = activeTabEl.querySelectorAll('.lead-card');
                    leadCards.forEach(card => {
                        const name = card.getAttribute('data-name') || '';
                        const email = card.getAttribute('data-email') || '';
                        if (name.includes(query) || email.includes(query)) {
                            card.style.display = 'flex';
                        } else {
                            card.style.display = 'none';
                        }
                    });
                } else if (tabId === 'tab-licenses') {
                    const licCards = activeTabEl.querySelectorAll('.license-card');
                    licCards.forEach(card => {
                        const key = card.getAttribute('data-key') || '';
                        if (key.includes(query)) {
                            card.style.display = 'block';
                        } else {
                            card.style.display = 'none';
                        }
                    });
                } else if (tabId === 'tab-services') {
                    const serviceCards = activeTabEl.querySelectorAll('.service-card-item');
                    serviceCards.forEach(card => {
                        const title = card.getAttribute('data-title') || '';
                        if (title.includes(query)) {
                            card.style.display = 'flex';
                        } else {
                            card.style.display = 'none';
                        }
                    });
                }
            });
        }

        // Collapsible License Details control
        function toggleLicenseDetails(id) {
            const el = document.getElementById(id);
            const licId = id.replace('license-details-', '');
            const arrow = document.getElementById('arrow-lic-' + licId);
            if (el.style.display === 'none' || el.style.display === '') {
                el.style.display = 'block';
                if(arrow) arrow.style.transform = 'rotate(180deg)';
            } else {
                el.style.display = 'none';
                if(arrow) arrow.style.transform = 'rotate(0)';
            }
        }

        // Mobile responsiveness sidebar toggles
        const menuToggle = document.getElementById('menu-toggle');
        const sidebar = document.getElementById('sidebar');

        if (menuToggle) {
            menuToggle.addEventListener('click', (e) => {
                e.stopPropagation();
                sidebar.classList.toggle('active');
            });
        }

        // Close sidebars on clicking outside
        document.addEventListener('click', () => {
            if (sidebar) sidebar.classList.remove('active');
        });

        // Prevent closing when clicking inside sidebar
        if (sidebar) {
            sidebar.addEventListener('click', (e) => e.stopPropagation());
        }

        function togglePasswordBox(boxId) {
            const box = document.getElementById(boxId);
            if (box) {
                box.style.display = box.style.display === 'none' ? 'block' : 'none';
            }
        }

        function updateLicenseDefaults() {
            const duration = document.getElementById('duration').value;
            const deviceLimit = document.getElementById('device_limit');
            const price = document.getElementById('price');
            if (duration === '1_month') {
                deviceLimit.value = 1;
                price.value = 29000;
            } else if (duration === '1_year') {
                deviceLimit.value = 1;
                price.value = 249000;
            } else if (duration === 'lifetime') {
                deviceLimit.value = 5;
                price.value = 499000;
            }
        }
    </script>
</body>
</html>
