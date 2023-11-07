<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <!-- CSRF Token -->
        <meta name="csrf-token" content="{{ csrf_token() }}">

        <title>{{ config('app.name', 'Laravel') }}</title>
        <link rel="icon" type="image/png" href="{{ asset('images/logo.png') }}">
        <!-- Styles -->
        <link href="{{ url('css/app.css') }}" rel="stylesheet">
        <link href="{{ url('css/navbar.css') }}" rel="stylesheet">
        <link href="{{ url('css/auth.css') }}" rel="stylesheet">
        <link href="{{ url('css/footer.css') }}" rel="stylesheet">
        <link href="{{ url('css/sidebar.css') }}" rel="stylesheet">
        <link href="{{ url('css/breadcrumb.css') }}" rel="stylesheet">

        <script type="text/javascript">
            // Fix for Firefox autofocus CSS bug
            // See: http://stackoverflow.com/questions/18943276/html-5-autofocus-messes-up-css-loading/18945951#18945951
        </script>
        <script type="text/javascript" src={{ url('js/app.js') }} defer>
        <script nomodule
            src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"
            defer></script>
        </script>
    </head>
    <body>
        @if(in_array(request()->route()->getName(), ['login', 'register']))
            @yield('authentication')
        @else
            @include('partials._header')
            <main>
                <x-sidebar></x-sidebar>
                <div class="headers">
                    <button class="open-sidebar">
                        <ion-icon name="menu"></ion-icon>
                    </button>

                    <ul class="breadcrumb">
                        <li> <a href="home.html">Home</a></li>
                        <li> <a href="#">Game Categories</a></li>
                        <li> <a href="#" >Adventure</a></li>
                        <li> Roblox</li>
                    </ul>
                </div>
                <section id="content">
                    @yield('content')
                </section>
            </main>
            @include('partials._footer')
        @endif
        
        <script type="module"
            src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
        <script nomodule
            src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
    </body>
</html>