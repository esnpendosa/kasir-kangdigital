<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Member | Kang Digital</title>
    
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

        .menu-toggle {
            background: none;
            border: none;
            font-size: 24px;
            color: var(--text-main);
            cursor: pointer;
        }

        .panel-toggle {
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
            background-color: var(--bg-card);
            color: var(--text-main);
            font-weight: 700;
        }

        .menu-item.active i {
            color: var(--primary);
        }

        /* Friends Section inside Sidebar */
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
            object-fit: cover;
            border: 2px solid #ffffff;
            box-shadow: 0 4px 8px rgba(0,0,0,0.05);
        }

        .friend-info {
            display: flex;
            flex-direction: column;
        }

        .friend-name {
            font-size: 13px;
            font-weight: 700;
            color: var(--text-main);
        }

        .friend-status {
            font-size: 11px;
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
            font-size: 15px;
            font-weight: 700;
            color: var(--text-main);
            margin-top: 2px;
        }

        .chip-more {
            background: none;
            border: none;
            color: var(--text-light);
            cursor: pointer;
            padding: 4px;
            transition: var(--transition);
        }

        .chip-more:hover {
            color: var(--text-main);
        }

        /* Standard Section Container */
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
            font-weight: 700;
            color: var(--text-main);
        }

        .slider-controls {
            display: flex;
            gap: 8px;
        }

        .slider-btn {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            border: 1px solid var(--border-color);
            background-color: var(--bg-card);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            color: var(--text-muted);
            cursor: pointer;
            transition: var(--transition);
        }

        .slider-btn:hover, .slider-btn.active {
            border-color: var(--primary);
            color: #ffffff;
            background-color: var(--primary);
        }

        .see-all-link {
            font-size: 13px;
            font-weight: 700;
            color: var(--primary);
            text-decoration: none;
            transition: var(--transition);
        }

        .see-all-link:hover {
            text-decoration: underline;
        }

        /* Course Cards Grid */
        .cards-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
        }

        .course-card {
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 24px;
            overflow: hidden;
            transition: var(--transition);
            cursor: pointer;
        }

        .course-card:hover {
            transform: translateY(-6px);
            box-shadow: var(--shadow-medium);
            border-color: var(--border-color);
        }

        .card-image-wrapper {
            position: relative;
            height: 160px;
            overflow: hidden;
        }

        .course-thumb {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: var(--transition);
        }

        .course-card:hover .course-thumb {
            transform: scale(1.05);
        }

        .fav-btn {
            position: absolute;
            top: 16px;
            right: 16px;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.25);
            backdrop-filter: blur(8px);
            border: 1px solid rgba(255, 255, 255, 0.3);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: var(--transition);
        }

        .fav-btn:hover {
            background: rgba(255, 255, 255, 0.4);
            transform: scale(1.1);
        }

        .fav-btn.favorited {
            color: #FF5A5A;
            background: #ffffff;
        }

        .card-body {
            padding: 20px;
        }

        .badge {
            font-size: 9px;
            font-weight: 800;
            letter-spacing: 1px;
            padding: 6px 12px;
            border-radius: 50px;
            display: inline-block;
            margin-bottom: 12px;
            text-transform: uppercase;
        }

        .badge-blue {
            background-color: #E8F2FF;
            color: var(--accent-blue);
        }

        .badge-purple {
            background-color: var(--primary-light);
            color: var(--primary);
        }

        .badge-pink {
            background-color: #FFEBF5;
            color: var(--accent-pink);
        }

        .course-title {
            font-size: 14px;
            font-weight: 700;
            color: var(--text-main);
            line-height: 1.4;
            margin-bottom: 16px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            height: 40px;
        }

        .mentor-info {
            display: flex;
            align-items: center;
            gap: 12px;
            border-top: 1px solid var(--border-color);
            padding-top: 12px;
        }

        .mentor-avatar {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            object-fit: cover;
        }

        .mentor-details {
            display: flex;
            flex-direction: column;
        }

        .mentor-name {
            font-size: 12px;
            font-weight: 700;
            color: var(--text-main);
        }

        .mentor-role {
            font-size: 10px;
            color: var(--text-muted);
        }

        /* Lessons Table styling */
        .table-card {
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 24px;
            padding: 16px 24px;
            overflow-x: auto;
        }

        .lessons-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }

        .lessons-table th {
            font-size: 11px;
            font-weight: 700;
            color: var(--text-light);
            letter-spacing: 1px;
            padding: 12px 16px;
            border-bottom: 1px solid var(--border-color);
        }

        .lessons-table td {
            padding: 16px;
            vertical-align: middle;
            font-size: 13px;
        }

        .table-mentor-cell {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .mentor-avatar-small {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            object-fit: cover;
        }

        .mentor-table-details {
            display: flex;
            flex-direction: column;
        }

        .mentor-name-small {
            font-size: 13px;
            font-weight: 700;
            color: var(--text-main);
        }

        .mentor-date-small {
            font-size: 11px;
            color: var(--text-muted);
        }

        .desc-cell {
            font-weight: 600;
            color: var(--text-main);
        }

        .action-arrow-btn {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background-color: var(--primary-light);
            border: none;
            color: var(--primary);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            cursor: pointer;
            transition: var(--transition);
        }

        .action-arrow-btn:hover {
            background-color: var(--primary);
            color: #ffffff;
            transform: scale(1.05);
        }

        /* RIGHT PANEL (Third Column) */
        aside.right-panel {
            width: 340px;
            background-color: var(--bg-panel);
            border-left: 1px solid var(--border-color);
            padding: 40px 24px;
            display: flex;
            flex-direction: column;
            gap: 32px;
            flex-shrink: 0;
            overflow-y: auto;
            height: 100vh;
            max-height: 100vh;
        }

        .panel-section {
            display: flex;
            flex-direction: column;
        }

        .panel-section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .panel-section-header h3 {
            font-family: var(--font-heading);
            font-size: 18px;
            font-weight: 700;
            color: var(--text-main);
        }

        .more-btn, .add-mentor-btn {
            background: none;
            border: none;
            color: var(--text-light);
            font-size: 16px;
            cursor: pointer;
            transition: var(--transition);
        }

        .more-btn:hover, .add-mentor-btn:hover {
            color: var(--text-main);
        }

        /* Stat Card widget */
        .stat-card {
            background-color: var(--bg-card);
            border-radius: 28px;
            padding: 24px;
            border: 1px solid var(--border-color);
            display: flex;
            flex-direction: column;
            align-items: center;
            box-shadow: var(--shadow-subtle);
        }

        .circle-progress-wrapper {
            position: relative;
            width: 120px;
            height: 120px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* Pure CSS Conic Gradient Circle Progress */
        .circular-progress {
            width: 108px;
            height: 108px;
            border-radius: 50%;
            background: conic-gradient(var(--primary) 32%, #EAEAEF 0);
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }

        .circular-progress::before {
            content: "";
            position: absolute;
            width: 96px;
            height: 96px;
            background-color: var(--bg-card);
            border-radius: 50%;
            z-index: 1;
        }

        .avatar-inside {
            position: relative;
            z-index: 2;
            width: 86px;
            height: 86px;
            border-radius: 50%;
            overflow: hidden;
            background-color: #F8F9FA;
            border: 2px solid #ffffff;
            box-shadow: inset 0 2px 10px rgba(0,0,0,0.06);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .memoji-avatar {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transform: scale(1.05);
        }

        .progress-val-badge {
            position: absolute;
            top: 2px;
            right: 2px;
            background-color: var(--primary);
            color: #ffffff;
            font-size: 10px;
            font-weight: 800;
            padding: 4px 8px;
            border-radius: 50px;
            box-shadow: 0 4px 8px rgba(108, 93, 211, 0.3);
            border: 2px solid var(--bg-card);
            z-index: 3;
        }

        .stat-welcome-text {
            font-size: 16px;
            font-weight: 800;
            color: var(--text-main);
            text-align: center;
            margin-bottom: 6px;
        }

        .stat-subtitle-text {
            font-size: 12px;
            color: var(--text-muted);
            text-align: center;
            line-height: 1.4;
            max-width: 200px;
            margin-bottom: 24px;
        }

        /* Bar Chart styles */
        .bar-chart-container {
            width: 100%;
            border-top: 1px solid var(--border-color);
            padding-top: 20px;
        }

        .chart-bars {
            display: flex;
            justify-content: space-between;
            gap: 20px;
            height: 100px;
            align-items: flex-end;
        }

        .bar-group {
            display: flex;
            gap: 4px;
            align-items: flex-end;
            height: 80px;
            position: relative;
            flex: 1;
            justify-content: center;
        }

        .bar-column {
            width: 14px;
            height: 100%;
            background-color: #F3F4F8;
            border-radius: 4px;
            position: relative;
            overflow: hidden;
            display: flex;
            align-items: flex-end;
        }

        .bar-fill {
            width: 100%;
            border-radius: 4px;
            transition: height 1s ease-in-out;
        }

        .bar-fill-gray {
            background-color: var(--text-light);
            opacity: 0.3;
        }

        .bar-fill-purple {
            background-color: var(--primary);
        }

        .bar-label {
            position: absolute;
            bottom: -22px;
            left: 50%;
            transform: translateX(-50%);
            font-size: 9px;
            font-weight: 700;
            color: var(--text-muted);
            white-space: nowrap;
        }

        /* Mentors List Section */
        .mentors-list {
            display: flex;
            flex-direction: column;
            gap: 16px;
            margin-bottom: 20px;
        }

        .mentor-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            padding: 12px 16px;
            border-radius: 20px;
            transition: var(--transition);
        }

        .mentor-item:hover {
            box-shadow: var(--shadow-subtle);
            transform: translateY(-2px);
        }

        .mentor-profile-left {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .mentor-list-details {
            display: flex;
            flex-direction: column;
        }

        .mentor-list-name {
            font-size: 13px;
            font-weight: 700;
            color: var(--text-main);
        }

        .mentor-list-role {
            font-size: 11px;
            color: var(--text-muted);
        }

        .follow-btn {
            background-color: transparent;
            border: 1px solid var(--border-color);
            color: var(--text-muted);
            padding: 6px 12px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 700;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 6px;
            transition: var(--transition);
        }

        .follow-btn:hover {
            background-color: var(--primary-light);
            color: var(--primary);
            border-color: var(--primary);
        }

        .follow-btn.following {
            background-color: var(--primary);
            color: #ffffff;
            border-color: var(--primary);
        }

        .follow-btn.following i {
            display: inline-block;
            transform: scale(0.9);
        }

        .see-all-mentors-btn {
            background-color: var(--primary-light);
            color: var(--primary);
            border: none;
            padding: 12px;
            border-radius: 16px;
            font-weight: 700;
            font-size: 13px;
            cursor: pointer;
            transition: var(--transition);
            width: 100%;
            text-align: center;
        }

        .see-all-mentors-btn:hover {
            background-color: var(--primary);
            color: #ffffff;
        }

        /* DYNAMIC TABS OR MODALS */
        .tab-panel-content {
            display: none;
        }

        .tab-panel-content.active {
            display: block;
        }

        /* Dynamic styling for license info */
        .license-card {
            background: linear-gradient(135deg, #1f2937 0%, #111827 100%);
            color: #ffffff;
            border-radius: 20px;
            padding: 24px;
            margin-bottom: 24px;
            position: relative;
            overflow: hidden;
            box-shadow: 0 10px 20px rgba(0,0,0,0.1);
        }

        .license-card h3 {
            font-family: var(--font-heading);
            font-size: 16px;
            font-weight: 700;
            margin-bottom: 16px;
            color: #a78bfa;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .license-key {
            font-family: monospace;
            font-size: 18px;
            font-weight: 700;
            background: rgba(255,255,255,0.1);
            padding: 8px 12px;
            border-radius: 10px;
            display: inline-block;
            letter-spacing: 1px;
            margin-bottom: 16px;
        }

        .license-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            font-size: 12px;
        }

        .license-item {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .license-label {
            color: rgba(255,255,255,0.5);
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .license-value {
            font-weight: 600;
        }

        /* Success dialog box */
        .dialog-box {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) scale(0.9);
            background-color: var(--bg-card);
            border-radius: 28px;
            padding: 40px;
            max-width: 420px;
            width: 90%;
            box-shadow: 0 20px 60px rgba(0,0,0,0.15);
            z-index: 1000;
            opacity: 0;
            pointer-events: none;
            transition: var(--transition);
            text-align: center;
        }

        .dialog-box.active {
            transform: translate(-50%, -50%) scale(1);
            opacity: 1;
            pointer-events: auto;
        }

        .dialog-backdrop {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.4);
            backdrop-filter: blur(4px);
            z-index: 999;
            opacity: 0;
            pointer-events: none;
            transition: var(--transition);
        }

        .dialog-backdrop.active {
            opacity: 1;
            pointer-events: auto;
        }

        .dialog-icon {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            background-color: var(--primary-light);
            color: var(--primary);
            font-size: 28px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
        }

        .dialog-title {
            font-family: var(--font-heading);
            font-size: 22px;
            font-weight: 800;
            margin-bottom: 12px;
        }

        .dialog-text {
            color: var(--text-muted);
            font-size: 14px;
            line-height: 1.5;
            margin-bottom: 24px;
        }

        .dialog-btn {
            background-color: var(--primary);
            color: #ffffff;
            border: none;
            padding: 12px 32px;
            border-radius: 16px;
            font-weight: 700;
            font-size: 14px;
            cursor: pointer;
            transition: var(--transition);
        }

        .dialog-btn:hover {
            box-shadow: 0 8px 16px rgba(108, 93, 211, 0.3);
        }

        /* RESPONSIVE LAYOUTS */
        @media (max-width: 1200px) {
            aside.right-panel {
                width: 100%;
                border-left: none;
                border-top: 1px solid var(--border-color);
                max-height: none;
            }

            .app-wrapper {
                flex-direction: column;
                min-height: auto;
            }

            main.main-content {
                max-height: none;
            }
        }

        @media (max-width: 992px) {
            .progress-chips-grid {
                grid-template-columns: 1fr;
            }
            .cards-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            body {
                padding: 0;
                background-color: var(--bg-card);
            }

            .app-wrapper {
                border-radius: 0;
                border: none;
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

            .top-bar {
                flex-direction: column;
                align-items: stretch;
            }

            .top-actions {
                justify-content: space-between;
            }

            .banner-card {
                flex-direction: column;
                padding: 24px;
                text-align: center;
                align-items: center;
            }

            .banner-info {
                max-width: 100%;
                margin-bottom: 24px;
            }

            .banner-btn {
                margin: 0 auto;
            }

            .banner-graphic {
                display: none;
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
                <span class="menu-title">OVERVIEW</span>
                <nav class="menu-list">
                    <div class="menu-item active" data-tab="dashboard">
                        <i class="fa-solid fa-chart-line"></i>
                        <span>Dashboard</span>
                    </div>
                    <div class="menu-item" data-tab="tasks">
                        <i class="fa-solid fa-book-open"></i>
                        <span>Panduan Kasir</span>
                    </div>
                    <div class="menu-item" data-tab="group">
                        <i class="fa-solid fa-key"></i>
                        <span>Lisensi & Sewa</span>
                    </div>
                </nav>
            </div>
            
            
            <div class="menu-section settings-section">
                <span class="menu-title">SETTINGS</span>
                <nav class="menu-list">
                    <div class="menu-item" data-tab="settings">
                        <i class="fa-solid fa-sliders"></i>
                        <span>Setting</span>
                    </div>
                    <a href="#" class="menu-item logout-btn" onclick="event.preventDefault(); document.getElementById('logout-form').submit();">
                        <i class="fa-solid fa-right-from-bracket"></i>
                        <span>Logout</span>
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
                    <input type="text" id="course-search" placeholder="Search your course....">
                </div>
                
                <div class="top-actions">
                    <button class="action-btn" onclick="switchTab('inbox')">
                        <i class="fa-solid fa-envelope"></i>
                    </button>
                    <button class="action-btn notification-btn" onclick="showNotification()">
                        <i class="fa-solid fa-bell"></i>
                        <span class="badge-dot"></span>
                    </button>
                    
                    <div class="user-profile" onclick="switchTab('settings')">
                        <img src="https://api.dicebear.com/7.x/pixel-art/svg?seed={{ urlencode($user->username) }}" alt="Avatar" class="profile-avatar">
                        <span class="profile-name">{{ $user->name }}</span>
                        <i class="fa-solid fa-chevron-down profile-arrow"></i>
                    </div>
                </div>
            </header>

            <!-- TAB: DASHBOARD -->
            <div id="tab-dashboard" class="tab-panel-content active">
                <!-- Course Banner -->
                <section class="banner-card">
                    <div class="banner-info">
                        <span class="banner-tag">KANG DIGITAL POS</span>
                        <h1 class="banner-title">Kelola Transaksi Toko UMKM Anda dengan Mudah & Cepat</h1>
                        <button class="banner-btn" onclick="switchTab('group')">
                            <span>Mulai Integrasi</span>
                            <div class="btn-arrow">
                                <i class="fa-solid fa-arrow-right"></i>
                            </div>
                        </button>
                    </div>
                    <div class="banner-graphic">
                        <svg width="120" height="120" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path d="M50 0C50 27.6142 27.6142 50 0 50C27.6142 50 50 72.3858 50 100C50 72.3858 72.3858 50 100 50C72.3858 50 50 27.6142 50 0Z" fill="white" fill-opacity="0.25"/>
                        </svg>
                        <svg width="50" height="50" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg" class="sparkle-small">
                            <path d="M50 0C50 27.6142 27.6142 50 0 50C27.6142 50 50 72.3858 50 100C50 72.3858 72.3858 50 100 50C72.3858 50 50 27.6142 50 0Z" fill="white" fill-opacity="0.15"/>
                        </svg>
                    </div>
                </section>

                <!-- Fitur Unggulan POS -->
                <section class="progress-chips-grid">
                    <div class="progress-chip">
                        <div class="chip-icon icon-purple">
                            <i class="fa-solid fa-bolt"></i>
                        </div>
                        <div class="chip-content">
                            <span class="chip-subtitle">Offline-First</span>
                            <span class="chip-title">Bekerja Tanpa Internet</span>
                        </div>
                    </div>
                    
                    <div class="progress-chip">
                        <div class="chip-icon icon-pink">
                            <i class="fa-solid fa-print"></i>
                        </div>
                        <div class="chip-content">
                            <span class="chip-subtitle">Thermal Printer</span>
                            <span class="chip-title">Cetak Struk Bluetooth</span>
                        </div>
                    </div>
                    
                    <div class="progress-chip">
                        <div class="chip-icon icon-blue">
                            <i class="fa-solid fa-cloud-arrow-up"></i>
                        </div>
                        <div class="chip-content">
                            <span class="chip-subtitle">Cloud Sync</span>
                            <span class="chip-title">Cadangkan Transaksi</span>
                        </div>
                    </div>
                </section>

                <!-- Panduan Langkah Awal -->
                <section class="section-container">
                    <div class="section-header">
                        <h2>Langkah Memulai Kasir Digital</h2>
                    </div>
                    
                    <div class="cards-grid">
                        <!-- Step 1 Card -->
                        <article class="course-card" onclick="switchTab('group')">
                            <div class="card-image-wrapper">
                                <img src="https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=400&q=80" alt="Download APK" class="course-thumb">
                            </div>
                            <div class="card-body">
                                <span class="badge badge-blue">LANGKAH 1</span>
                                <h3 class="course-title">Unduh file aplikasi (APK) dan install di HP Android POS Anda</h3>
                            </div>
                        </article>

                        <!-- Step 2 Card -->
                        <article class="course-card" onclick="switchTab('group')">
                            <div class="card-image-wrapper">
                                <img src="https://images.unsplash.com/photo-1581291518633-83b4ebd1d83e?auto=format&fit=crop&w=400&q=80" alt="Activate License" class="course-thumb">
                            </div>
                            <div class="card-body">
                                <span class="badge badge-purple">LANGKAH 2</span>
                                <h3 class="course-title">Salin Kode Lisensi Anda dan lakukan aktivasi perangkat</h3>
                            </div>
                        </article>

                        <!-- Step 3 Card -->
                        <article class="course-card" onclick="switchTab('group')">
                            <div class="card-image-wrapper">
                                <img src="https://images.unsplash.com/photo-1434030216411-0b793f4b4173?auto=format&fit=crop&w=400&q=80" alt="Start Selling" class="course-thumb">
                            </div>
                            <div class="card-body">
                                <span class="badge badge-pink">LANGKAH 3</span>
                                <h3 class="course-title">Mulai mencatat penjualan dan sinkronisasikan laporan ke web</h3>
                            </div>
                        </article>
                    </div>
                </section>
            </div>

            <!-- TAB: PANDUAN KASIR -->
            <div id="tab-tasks" class="tab-panel-content">
                <div class="section-header">
                    <h2>Panduan Kasir & Aktivasi</h2>
                </div>
                <div class="table-card" style="padding:30px;">
                    <h3 style="margin-bottom:16px; font-family:var(--font-heading); font-size:16px;">Tips Penggunaan Aplikasi Android POS</h3>
                    <div style="display:flex; flex-direction:column; gap:16px;">
                        <div style="display:flex; align-items:center; gap:12px; font-weight:600;">
                            <i class="fa-solid fa-circle-check" style="color:var(--primary); font-size:18px;"></i>
                            <span>Pastikan bluetooth HP aktif untuk menghubungkan printer thermal pencetak struk belanja.</span>
                        </div>
                        <div style="display:flex; align-items:center; gap:12px; font-weight:600;">
                            <i class="fa-solid fa-circle-check" style="color:var(--primary); font-size:18px;"></i>
                            <span>Lakukan sinkronisasi data secara berkala dari aplikasi android agar laporan tercadangkan ke cloud.</span>
                        </div>
                        <div style="display:flex; align-items:center; gap:12px; font-weight:600;">
                            <i class="fa-solid fa-circle-check" style="color:var(--primary); font-size:18px;"></i>
                            <span>Gunakan menu Manajemen Pengguna untuk mendaftarkan akun kasir karyawan toko Anda.</span>
                        </div>
                        <div style="display:flex; align-items:center; gap:12px; font-weight:600;">
                            <i class="fa-solid fa-circle-check" style="color:var(--primary); font-size:18px;"></i>
                            <span>Jika masa berlaku lisensi habis, Anda dapat menyewa perpanjangan lisensi di tab "Lisensi & Sewa".</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- TAB: GROUP -->
            <div id="tab-group" class="tab-panel-content">
                <div class="section-header">
                    <h2>License Team & Members</h2>
                </div>
                
                <div class="license-card">
                    <h3><i class="fa-solid fa-key"></i> LISENSI KASIR UMKM ANDA</h3>
                    <div style="display:flex; align-items:center; gap:12px; margin-bottom:16px; flex-wrap: wrap;">
                        <div class="license-key" id="license-key-text" style="margin-bottom:0;">{{ $user->license->license_key ?? 'KASIR-TRIAL-KEY-DEMO' }}</div>
                        <button class="btn-copy-license" onclick="copyLicense()" style="background: rgba(255,255,255,0.15); border: none; color: #fff; padding: 10px 14px; border-radius: 10px; font-weight: 700; font-size: 12px; cursor: pointer; transition: all 0.2s; display: inline-flex; align-items: center; gap: 6px;">
                            <i class="fa-regular fa-copy"></i> <span id="copy-btn-text">Salin</span>
                        </button>
                    </div>
                    
                    @php
                        $activeDevices = !empty($user->license->device_id) ? explode(',', $user->license->device_id) : [];
                        $deviceLimit = $user->license->device_limit ?? 1;
                    @endphp

                    <div class="license-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 16px; margin-bottom: 16px;">
                        <div class="license-item">
                            <span class="license-label" style="display:block; font-size:11px; color:#a78bfa; margin-bottom:4px;">Status Lisensi</span>
                            @if(($user->license->status ?? '') === 'active')
                                <span class="license-value" style="color:#37D159; font-weight:700;">AKTIF (PREMIUM)</span>
                            @elseif(($user->license->status ?? '') === 'expired')
                                <span class="license-value" style="color:#FF5A5A; font-weight:700;">EXPIRED</span>
                            @else
                                <span class="license-value" style="color:#FF754C; font-weight:700;">BELUM AKTIF</span>
                            @endif
                        </div>
                        <div class="license-item">
                            <span class="license-label" style="display:block; font-size:11px; color:#a78bfa; margin-bottom:4px;">Masa Berlaku</span>
                            <span class="license-value" style="font-weight:600;">{{ $user->license->expires_at ? \Carbon\Carbon::parse($user->license->expires_at)->format('d M Y') : 'Lifetime (Selamanya)' }}</span>
                        </div>
                        <div class="license-item">
                            <span class="license-label" style="display:block; font-size:11px; color:#a78bfa; margin-bottom:4px;">Limit Perangkat</span>
                            <span class="license-value" style="font-weight:600; color:#3F8CFF;">{{ count($activeDevices) }} / {{ $deviceLimit }} Perangkat</span>
                        </div>
                        <div class="license-item">
                            <span class="license-label" style="display:block; font-size:11px; color:#a78bfa; margin-bottom:4px;">Biaya Terdaftar</span>
                            <span class="license-value" style="font-weight:600; color:#FF754C;">Rp {{ number_format($user->license->price ?? 0, 0, ',', '.') }}</span>
                        </div>
                    </div>

                    @if(count($activeDevices) > 0)
                        <div>
                            <h4 style="font-size: 12px; font-weight: 700; color:#a78bfa; margin-bottom: 8px; font-family:var(--font-heading);">
                                <i class="fa-solid fa-mobile-screen"></i> Perangkat Terdaftar Aplikasi:
                            </h4>
                            <div style="display:flex; flex-wrap:wrap; gap:8px;">
                                @foreach($activeDevices as $device)
                                    <span style="font-size:11px; background:rgba(255,255,255,0.08); padding:6px 12px; border-radius:8px; font-family:monospace; display:inline-flex; align-items:center; gap:6px; border: 1px solid rgba(255,255,255,0.12);">
                                        <i class="fa-solid fa-check-circle" style="color:#37D159;"></i> {{ $device }}
                                    </span>
                                @endforeach
                            </div>
                        </div>
                    @else
                        <div style="font-size:12px; color:#d1d5db; font-style:italic;">
                            *Belum ada perangkat Android POS terhubung. Lakukan aktivasi menggunakan kunci lisensi di atas di aplikasi POS.
                        </div>
                    @endif
                </div>

                <!-- APK Download and Connection Guide -->
                <div class="download-guide-card" style="background: #f8fafc; border: 1px solid var(--border-color); border-radius: 20px; padding: 24px; margin-bottom: 24px;">
                    <h3 style="font-family: var(--font-heading); font-size: 16px; font-weight: 700; margin-bottom: 12px; color: var(--text-main); display: flex; align-items: center; gap: 8px;">
                        <i class="fa-brands fa-android" style="color: #3ddc84; font-size: 20px;"></i> Integrasi Android POS
                    </h3>
                    <p style="font-size: 13px; color: var(--text-muted); margin-bottom: 16px; line-height: 1.5;">
                        Hubungkan perangkat Android kasir Anda dengan akun member ini menggunakan langkah-langkah berikut.
                    </p>

                    <!-- Steps -->
                    <div style="display:flex; flex-direction:column; gap:12px; font-size: 12.5px; color: var(--text-main); line-height: 1.5; margin-bottom: 20px;">
                        <div style="display:flex; gap:10px;">
                            <span style="background: var(--primary-light); color: var(--primary); font-weight: 800; width: 22px; height: 22px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink:0;">1</span>
                            <span>Unduh file aplikasi (APK) resmi Kang Digital di bawah ini dan instal di HP Android Anda.</span>
                        </div>
                        <div style="display:flex; gap:10px;">
                            <span style="background: var(--primary-light); color: var(--primary); font-weight: 800; width: 22px; height: 22px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink:0;">2</span>
                            <span>Buka aplikasi, lalu masukkan <strong>Kode Lisensi</strong> di atas untuk proses aktivasi perangkat.</span>
                        </div>
                        <div style="display:flex; gap:10px;">
                            <span style="background: var(--primary-light); color: var(--primary); font-weight: 800; width: 22px; height: 22px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink:0;">3</span>
                            <span>Setelah aktif, data produk dan transaksi kasir Anda akan langsung tersinkronisasi otomatis dengan server.</span>
                        </div>
                    </div>

                    <!-- Action Button to Download APK -->
                    <a href="{{ \App\Models\Setting::getValue('app_download_url', 'https://kangdigital.web.id/downloads/kasir_umkm.apk') }}" target="_blank" style="background: linear-gradient(135deg, #2563eb, #1d4ed8); color: #ffffff; text-decoration: none; padding: 12px; border-radius: 12px; font-weight: 700; font-size: 13.5px; display: flex; align-items: center; justify-content: center; gap: 8px; transition: all 0.2s; box-shadow: 0 4px 12px rgba(37, 99, 235, 0.15);">
                        <i class="fa-solid fa-download"></i> Unduh Aplikasi Android (APK)
                    </a>
                </div>

                <!-- Rental System & License Pricing Plans -->
                <div class="pricing-section-card" style="background: #ffffff; border: 1px solid var(--border-color); border-radius: 20px; padding: 28px; margin-bottom: 24px; box-shadow: var(--shadow-subtle);">
                    <h3 style="font-family: var(--font-heading); font-size: 16px; font-weight: 700; margin-bottom: 6px; color: var(--text-main); display: flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-tags" style="color: var(--primary);"></i> Paket Sewa Sistem & Lisensi
                    </h3>
                    <p style="font-size: 13px; color: var(--text-muted); margin-bottom: 24px; line-height: 1.5;">
                        Pilih paket sewa lisensi murah untuk mengaktifkan fitur premium Android POS Anda secara penuh.
                    </p>

                    <!-- Pricing Grid -->
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; margin-bottom: 20px;">
                        
                        <!-- Plan 1: Bulanan -->
                        <div class="pricing-card-item" style="border: 1px solid var(--border-color); border-radius: 16px; padding: 20px; display: flex; flex-direction: column; transition: var(--transition); background: #fafafa; position: relative; overflow: hidden;">
                            <div style="font-size: 12px; font-weight: 800; color: var(--text-muted); text-transform: uppercase; margin-bottom: 8px;">Sewa Bulanan</div>
                            <div style="margin-bottom: 12px;">
                                <span style="font-family: var(--font-heading); font-size: 24px; font-weight: 800; color: var(--text-main);">Rp 29.000</span>
                                <span style="font-size: 12px; color: var(--text-muted);">/bln</span>
                            </div>
                            <ul style="list-style: none; padding: 0; margin: 0 0 20px 0; font-size: 12px; color: var(--text-main); display: flex; flex-direction: column; gap: 8px; flex-grow: 1;">
                                <li><i class="fa-solid fa-check" style="color:var(--accent-green); margin-right: 6px;"></i> 1 Perangkat Android POS</li>
                                <li><i class="fa-solid fa-check" style="color:var(--accent-green); margin-right: 6px;"></i> Transaksi Tanpa Batas</li>
                                <li><i class="fa-solid fa-check" style="color:var(--accent-green); margin-right: 6px;"></i> Sinkronisasi Cloud Otomatis</li>
                                <li><i class="fa-solid fa-check" style="color:var(--accent-green); margin-right: 6px;"></i> Laporan Keuangan Dasar</li>
                            </ul>
                            <a href="https://wa.me/{{ \App\Models\Setting::getValue('whatsapp_number', '6285730302827') }}?text=Halo%20Admin%20Kang%20Digital,%20saya%20ingin%20menyewa%20Lisensi%20Bulanan%20Kasir%20UMKM%20(License%20Key:%20{{ $user->license->license_key ?? 'KD-DEMO' }})" target="_blank" style="background: var(--primary-light); color: var(--primary); text-decoration: none; padding: 10px; border-radius: 10px; font-weight: 700; text-align: center; font-size: 12.5px; transition: all 0.2s;">
                                Pilih Sewa Bulanan
                            </a>
                        </div>

                        <!-- Plan 2: Tahunan (Popular) -->
                        <div class="pricing-card-item" style="border: 2px solid var(--primary); border-radius: 16px; padding: 20px; display: flex; flex-direction: column; transition: var(--transition); background: #ffffff; position: relative; overflow: hidden; box-shadow: 0 8px 24px rgba(108, 93, 211, 0.08);">
                            <!-- Badge -->
                            <div style="position: absolute; top: 0; right: 0; background: var(--primary); color: #fff; font-size: 9px; font-weight: 800; padding: 4px 10px; border-bottom-left-radius: 10px; text-transform: uppercase;">Paling Populer</div>
                            <div style="font-size: 12px; font-weight: 800; color: var(--primary); text-transform: uppercase; margin-bottom: 8px;">Sewa Tahunan</div>
                            <div style="margin-bottom: 12px;">
                                <span style="font-family: var(--font-heading); font-size: 24px; font-weight: 800; color: var(--text-main);">Rp 249.000</span>
                                <span style="font-size: 12px; color: var(--text-muted);">/thn</span>
                            </div>
                            <ul style="list-style: none; padding: 0; margin: 0 0 20px 0; font-size: 12px; color: var(--text-main); display: flex; flex-direction: column; gap: 8px; flex-grow: 1;">
                                <li><i class="fa-solid fa-check" style="color:var(--accent-green); margin-right: 6px;"></i> 1 Perangkat Android POS</li>
                                <li><i class="fa-solid fa-check" style="color:var(--accent-green); margin-right: 6px;"></i> Transaksi Tanpa Batas</li>
                                <li><i class="fa-solid fa-check" style="color:var(--accent-green); margin-right: 6px;"></i> Sinkronisasi Cloud Otomatis</li>
                                <li><i class="fa-solid fa-check" style="color:var(--accent-green); margin-right: 6px;"></i> Laporan Keuangan Lengkap</li>
                                <li><i class="fa-solid fa-check" style="color:var(--accent-green); margin-right: 6px;"></i> Layanan Bantuan VIP (WA)</li>
                            </ul>
                            <a href="https://wa.me/{{ \App\Models\Setting::getValue('whatsapp_number', '6285730302827') }}?text=Halo%20Admin%20Kang%20Digital,%20saya%20ingin%20menyewa%20Lisensi%20Tahunan%20Kasir%20UMKM%20(License%20Key:%20{{ $user->license->license_key ?? 'KD-DEMO' }})" target="_blank" style="background: var(--primary); color: #ffffff; text-decoration: none; padding: 10px; border-radius: 10px; font-weight: 700; text-align: center; font-size: 12.5px; transition: all 0.2s; box-shadow: 0 4px 12px rgba(108, 93, 211, 0.2);">
                                Pilih Sewa Tahunan
                            </a>
                        </div>

                    </div>
                    <span style="font-size: 11px; color: var(--text-muted); font-style: italic; display: block; text-align: center; margin-top: 12px;">
                        *Pembayaran aman, lisensi langsung terupdate otomatis setelah dikonfirmasi oleh tim aktivasi kami.
                    </span>
                </div>

                <div class="table-card">
                    <h3 style="margin-bottom:20px; font-family:var(--font-heading); font-size:16px;">Rekan Tim dalam Lisensi</h3>
                    <table class="lessons-table">
                        <thead>
                            <tr>
                                <th>NAMA LENGKAP</th>
                                <th>USERNAME</th>
                                <th>ROLE/JABATAN</th>
                                <th>STATUS</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td style="font-weight:700;">{{ $user->name }} (Anda)</td>
                                <td>{{ $user->username }}</td>
                                <td><span class="badge badge-blue">{{ strtoupper($user->role) }}</span></td>
                                <td><span style="color:var(--accent-green); font-weight:700;">Online</span></td>
                            </tr>
                            @foreach($teammates as $mate)
                                <tr>
                                    <td style="font-weight:700;">{{ $mate->name }}</td>
                                    <td>{{ $mate->username }}</td>
                                    <td><span class="badge badge-purple">{{ strtoupper($mate->role) }}</span></td>
                                    <td><span style="color:var(--text-light); font-weight:700;">Offline</span></td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- TAB: SETTINGS -->
            <div id="tab-settings" class="tab-panel-content">
                <div class="section-header">
                    <h2>Account Settings</h2>
                </div>
                <div class="table-card" style="padding:30px; max-width:600px;">
                    <form style="display:flex; flex-direction:column; gap:20px;">
                        <div style="display:flex; flex-direction:column; gap:8px;">
                            <label style="font-size:12px; font-weight:700; color:var(--text-muted);">Nama Tampilan</label>
                            <input type="text" value="{{ $user->name }}" style="padding:12px; border-radius:12px; border:1px solid var(--border-color); font-weight:600; outline:none;" readonly>
                        </div>
                        <div style="display:flex; flex-direction:column; gap:8px;">
                            <label style="font-size:12px; font-weight:700; color:var(--text-muted);">Username</label>
                            <input type="text" value="{{ $user->username }}" style="padding:12px; border-radius:12px; border:1px solid var(--border-color); font-weight:600; outline:none;" readonly>
                        </div>
                        <div style="display:flex; flex-direction:column; gap:8px;">
                            <label style="font-size:12px; font-weight:700; color:var(--text-muted);">Level Member</label>
                            <input type="text" value="{{ ucfirst($user->role) }}" style="padding:12px; border-radius:12px; border:1px solid var(--border-color); font-weight:600; outline:none;" readonly>
                        </div>
                        <span style="font-size:11px; color:var(--text-muted); font-style:italic;">*Informasi akun dikunci oleh administrator. Hubungi admin Kang Digital untuk melakukan pembaruan profil.</span>
                    </form>
                </div>
            </div>
        </main>

        <!-- RIGHT PANEL -->
        <aside class="right-panel" id="right-panel">
            <!-- Statistic Card -->
            <section class="panel-section">
                <div class="panel-section-header">
                    <h3>Status Sistem</h3>
                    <button class="more-btn" onclick="alert('Menu Status')"><i class="fa-solid fa-ellipsis-vertical"></i></button>
                </div>
                
                <div class="stat-card">
                    <!-- Circle Progress indicator -->
                    <div class="circle-progress-wrapper">
                        <div class="circular-progress" style="background: conic-gradient(var(--primary) 360deg, #e2e8f0 0deg);">
                            <div class="avatar-inside">
                                <img src="https://api.dicebear.com/7.x/pixel-art/svg?seed={{ urlencode($user->username) }}" alt="Avatar" class="memoji-avatar" style="border-radius: 50%;">
                            </div>
                        </div>
                        <div class="progress-val-badge" style="background: var(--accent-green); color:#fff; font-size: 10px; padding: 4px 8px;">Aktif</div>
                    </div>
                    
                    <h4 class="stat-welcome-text">Halo {{ explode(' ', $user->name)[0] }} 👋</h4>
                    <p class="stat-subtitle-text">Sistem kasir Anda siap digunakan & terhubung ke cloud hPanel.</p>
                    
                    <!-- Bar Chart -->
                    <div class="bar-chart-container">
                        <div class="chart-bars">
                            <div class="bar-group" onclick="showChartValue('Performa sinkronisasi optimal')">
                                <div class="bar-column">
                                    <div class="bar-fill bar-fill-gray" style="height: 10%;"></div>
                                </div>
                                <div class="bar-column">
                                    <div class="bar-fill bar-fill-purple" style="height: 90%;"></div>
                                </div>
                                <span class="bar-label">Sinkron</span>
                            </div>
                            
                            <div class="bar-group" onclick="showChartValue('Backup cloud berjalan otomatis')">
                                <div class="bar-column">
                                    <div class="bar-fill bar-fill-gray" style="height: 15%;"></div>
                                </div>
                                <div class="bar-column">
                                    <div class="bar-fill bar-fill-purple" style="height: 95%;"></div>
                                </div>
                                <span class="bar-label">Backup</span>
                            </div>
                            
                            <div class="bar-group" onclick="showChartValue('Database kasir aman')">
                                <div class="bar-column">
                                    <div class="bar-fill bar-fill-gray" style="height: 5%;"></div>
                                </div>
                                <div class="bar-column">
                                    <div class="bar-fill bar-fill-purple" style="height: 100%;"></div>
                                </div>
                                <span class="bar-label">Keamanan</span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Mentors List Section -->
            <section class="panel-section mentors-section">
                <div class="panel-section-header">
                    <h3>Hubungi Dukungan</h3>
                </div>
                
                <div class="mentors-list">
                    <div class="mentor-item">
                        <div class="mentor-profile-left">
                            <div style="background: rgba(37,99,235,0.1); width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: var(--primary); flex-shrink: 0;">
                                <i class="fa-solid fa-headset" style="font-size: 16px;"></i>
                            </div>
                            <div class="mentor-list-details">
                                <span class="mentor-list-name">Layanan Pelanggan</span>
                                <span class="mentor-list-role">Dukungan teknis & bantuan</span>
                            </div>
                        </div>
                        <a href="https://wa.me/{{ \App\Models\Setting::getValue('whatsapp_number', '6285730302827') }}?text=Halo%20Admin%20Kang%20Digital,%20saya%20butuh%20bantuan%20terkait%20Kasir%20UMKM" target="_blank" class="follow-btn following" style="text-decoration:none; display: inline-flex; align-items:center; gap:4px; font-weight:700;">
                            <i class="fa-brands fa-whatsapp"></i> Chat
                        </a>
                    </div>
                    
                    <div class="mentor-item">
                        <div class="mentor-profile-left">
                            <div style="background: rgba(16,185,129,0.1); width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: var(--accent-green); flex-shrink: 0;">
                                <i class="fa-solid fa-file-invoice-dollar" style="font-size: 16px;"></i>
                            </div>
                            <div class="mentor-list-details">
                                <span class="mentor-list-name">Sales & Sewa</span>
                                <span class="mentor-list-role">Perpanjangan lisensi / sewa</span>
                            </div>
                        </div>
                        <a href="https://wa.me/{{ \App\Models\Setting::getValue('whatsapp_number', '6285730302827') }}?text=Halo%20Admin%20Kang%20Digital,%20saya%20ingin%20perpanjang%20sewa%20lisensi%20Kasir%20UMKM" target="_blank" class="follow-btn" style="text-decoration:none; display: inline-flex; align-items:center; gap:4px; font-weight:700;">
                            <i class="fa-brands fa-whatsapp"></i> Chat
                        </a>
                    </div>
                </div>
            </section>
        </aside>
    </div>

    <!-- Background form for Laravel authentication logout -->
    <form id="logout-form" action="{{ route('member.logout') }}" method="POST" style="display: none;">
        @csrf
    </form>

    <!-- Dialog Box overlay -->
    <div class="dialog-backdrop" id="dialog-backdrop" onclick="closeDialog()"></div>
    <div class="dialog-box" id="dialog-box">
        <div class="dialog-icon">
            <i class="fa-solid fa-circle-check"></i>
        </div>
        <h3 class="dialog-title" id="dialog-title">Successfully Registered!</h3>
        <p class="dialog-text" id="dialog-text">You have successfully joined the online course. Get ready to level up your skills!</p>
        <button class="dialog-btn" onclick="closeDialog()">Awesome</button>
    </div>

    <!-- JavaScript Interactions -->
    <script>
        // Tab switching logic
        const menuItems = document.querySelectorAll('.menu-item');
        const tabPanels = document.querySelectorAll('.tab-panel-content');

        menuItems.forEach(item => {
            item.addEventListener('click', () => {
                const tabId = item.getAttribute('data-tab');
                if (!tabId) return;

                switchTab(tabId);
                
                // On mobile, close sidebar after clicking tab
                if (window.innerWidth <= 768) {
                    document.getElementById('sidebar').classList.remove('active');
                }
            });
        });

        function switchTab(tabId) {
            // Update active state of sidebar menus
            menuItems.forEach(menu => {
                if (menu.getAttribute('data-tab') === tabId) {
                    menu.classList.add('active');
                } else {
                    menu.classList.remove('active');
                }
            });

            // Update active tab panel view
            tabPanels.forEach(panel => {
                if (panel.id === `tab-${tabId}`) {
                    panel.classList.add('active');
                } else {
                    panel.classList.remove('active');
                }
            });
        }

        // Search Filter Courses
        const searchInput = document.getElementById('course-search');
        const courseCards = document.querySelectorAll('.course-card');

        searchInput.addEventListener('input', (e) => {
            const query = e.target.value.toLowerCase().trim();
            
            // Switch back to dashboard view if search is active
            switchTab('dashboard');

            courseCards.forEach(card => {
                const title = card.querySelector('.course-title').textContent.toLowerCase();
                const category = card.getAttribute('data-category').toLowerCase();
                
                if (title.includes(query) || category.includes(query)) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
        });

        // Filter by Clicking Progress Chips
        function filterCourses(categoryName) {
            switchTab('dashboard');
            
            courseCards.forEach(card => {
                const cardCategory = card.getAttribute('data-category');
                if (cardCategory.toLowerCase().includes(categoryName.toLowerCase())) {
                    card.style.display = 'block';
                    card.style.transform = 'scale(1.02)';
                    setTimeout(() => { card.style.transform = 'scale(1)'; }, 200);
                } else {
                    card.style.display = 'none';
                }
            });
        }

        // Favorite Toggle
        function toggleFav(btn, event) {
            event.stopPropagation(); // Avoid triggering card click
            btn.classList.toggle('favorited');
            const icon = btn.querySelector('i');
            if (btn.classList.contains('favorited')) {
                icon.className = 'fa-solid fa-heart';
            } else {
                icon.className = 'fa-regular fa-heart';
            }
        }

        // Mentor Follow Toggle
        function toggleFollow(btn) {
            btn.classList.toggle('following');
            const span = btn.querySelector('span');
            if (btn.classList.contains('following')) {
                span.textContent = 'Following';
            } else {
                span.textContent = 'Follow';
            }
        }

        // Open custom popup alert dialogues
        function openJoinDialog() {
            showDialog("Join Online Course", "Thank you for joining our courses! You have successfully unlocked 12 weeks of premium modules.");
        }

        function showNotification() {
            showDialog("Notifications", "You are completely up-to-date! There are no new announcements from your mentors.");
        }

        function openLessonVideo(lessonName) {
            showDialog("Starting Lesson", `Loading video stream player for: "${lessonName}". Please wait...`);
        }

        function showChartValue(val) {
            showDialog("Statistic Overview", val);
        }

        function addNewMentor() {
            showDialog("Add Mentor", "You can search and add certified industry experts to your mentorship list in the settings directory.");
        }

        function showDialog(title, text) {
            document.getElementById('dialog-title').textContent = title;
            document.getElementById('dialog-text').textContent = text;
            document.getElementById('dialog-box').classList.add('active');
            document.getElementById('dialog-backdrop').classList.add('active');
        }

        function closeDialog() {
            document.getElementById('dialog-box').classList.remove('active');
            document.getElementById('dialog-backdrop').classList.remove('active');
        }

        // Mobile drawer toggles
        document.getElementById('menu-toggle').addEventListener('click', () => {
            document.getElementById('sidebar').classList.toggle('active');
        });

        document.getElementById('panel-toggle').addEventListener('click', () => {
            const panel = document.getElementById('right-panel');
            if (panel.style.display === 'flex') {
                panel.style.display = 'none';
            } else {
                panel.style.display = 'flex';
                panel.style.position = 'fixed';
                panel.style.right = '0';
                panel.style.top = '64px';
                panel.style.height = 'calc(100vh - 64px)';
                panel.style.zIndex = '98';
                panel.style.width = '280px';
                panel.style.boxShadow = '-10px 0 30px rgba(0,0,0,0.05)';
            }
        });

        // Continue watching slider mock interactions
        let currentCardIndex = 0;
        function nextSlide() {
            const container = document.getElementById('courses-container');
            const cards = container.querySelectorAll('.course-card');
            
            // Highlight the next card with micro animation
            currentCardIndex = (currentCardIndex + 1) % cards.length;
            cards.forEach((card, index) => {
                if(index === currentCardIndex) {
                    card.style.border = '2px solid var(--primary)';
                    card.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
                    setTimeout(() => { card.style.border = '1px solid var(--border-color)'; }, 1000);
                }
            });
        }

        function prevSlide() {
            const container = document.getElementById('courses-container');
            const cards = container.querySelectorAll('.course-card');
            
            currentCardIndex = (currentCardIndex - 1 + cards.length) % cards.length;
            cards.forEach((card, index) => {
                if(index === currentCardIndex) {
                    card.style.border = '2px solid var(--primary)';
                    card.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
                    setTimeout(() => { card.style.border = '1px solid var(--border-color)'; }, 1000);
                }
            });
        }

        function copyLicense() {
            const licenseKey = document.getElementById('license-key-text').innerText;
            navigator.clipboard.writeText(licenseKey).then(() => {
                const btnText = document.getElementById('copy-btn-text');
                btnText.textContent = 'Tersalin!';
                setTimeout(() => {
                    btnText.textContent = 'Salin';
                }, 2000);
            }).catch(err => {
                alert('Gagal menyalin lisensi: ' + err);
            });
        }
    </script>
</body>
</html>
