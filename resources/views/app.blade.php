<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" @class(['dark' => ($appearance ?? 'system') == 'dark'])>

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    
    <!-- FORCE HTTPS for all resources -->
    <meta http-equiv="Content-Security-Policy" content="upgrade-insecure-requests">

    {{-- Inline script to detect system dark mode preference and apply it immediately --}}
    <script>
        (function() {
            const appearance = '{{ $appearance ?? 'system' }}';

            if (appearance === 'system') {
                const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;

                if (prefersDark) {
                    document.documentElement.classList.add('dark');
                }
            }
        })();
    </script>

    {{-- Inline style to set the HTML background color based on our theme in app.css --}}
    <style>
        html {
            background-color: oklch(1 0 0);
        }

        html.dark {
            background-color: oklch(0.145 0 0);
        }
    </style>

    @if(request()->routeIs('home') || request()->routeIs('custom-page.show') || request()->routeIs('login') || request()->routeIs('register'))
        @php
            $seoSettings = get_seo_setting();
        @endphp

        <meta name="title" content="{{ $seoSettings['meta_title'] ?? '' }}">
        <meta name="description" content="{{ $seoSettings['meta_description'] ?? '' }}">
        <meta name="keywords" content="{{ $seoSettings['meta_keywords'] ?? '' }}">

        <!-- Open Graph / Facebook -->
        <meta property="og:type" content="website">
        <meta property="og:url" content="{{ url()->current() }}">
        <meta property="og:title" content="{{ $seoSettings['meta_title'] ?? '' }}">
        <meta property="og:description" content="{{ $seoSettings['meta_description'] ?? '' }}">

        <!-- Twitter -->
        <meta property="twitter:card" content="summary_large_image">
        <meta property="twitter:url" content="{{ url()->current() }}">
        <meta property="twitter:title" content="{{ $seoSettings['meta_title'] ?? '' }}">
        <meta property="twitter:description" content="{{ $seoSettings['meta_description'] ?? '' }}">
        @if(!empty($seoSettings['meta_image']))
            <meta property="twitter:image" content="{{ $seoSettings['meta_image'] }}">
            <meta property="og:image" content="{{ $seoSettings['meta_image'] }}">
        @endif
    @endif

    <title inertia>{{ config('app.name', 'Laravel') }}</title>

    <!-- Fonts - Always use HTTPS -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- jQuery - Use HTTPS version -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    
    @routes
    @if (app()->environment('local'))
        @viteReactRefresh
    @endif
    @vite(['resources/js/app.tsx', "resources/js/pages/{$page['component']}.tsx"])
    
    <script>
        // Ensure base URL is correctly set for assets with HTTPS
        window.baseUrl = '{{ url('/') }}';
        
        // Force HTTPS for base URL if it's HTTP
        if (window.baseUrl.startsWith('http://')) {
            window.baseUrl = window.baseUrl.replace('http://', 'https://');
        }

        // Define asset helper function with HTTPS
        window.asset = function(path) {
            let assetUrl = "{{ asset('') }}" + path;
            if (assetUrl.startsWith('http://')) {
                assetUrl = assetUrl.replace('http://', 'https://');
            }
            return assetUrl;
        };

        // Define storage helper function with HTTPS
        window.storage = function(path) {
            let storageUrl = "{{ asset('storage') }}/" + path;
            if (storageUrl.startsWith('http://')) {
                storageUrl = storageUrl.replace('http://', 'https://');
            }
            return storageUrl;
        };

        // Set initial locale for i18next with HTTPS
        const localeUrl = '{{ route('initial-locale') }}';
        fetch(localeUrl.replace('http://', 'https://'))
            .then(response => response.text())
            .then(locale => {
                window.initialLocale = locale;
            })
            .catch(() => {
                window.initialLocale = 'en';
            });
    </script>
    @inertiaHead
</head>

<body class="font-sans antialiased !mb-0">
    @inertia
</body>

</html>