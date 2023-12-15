@extends('layouts.app')

@section('authentication')

@if (session('success'))
    <div class="notification-box" id="delete-noti"> 
        <ion-icon name="checkmark-circle" id="noti-icon" ></ion-icon>
        <div>
            <span>Password reset!</span>
            <span>{{ session('success') }}</span>
        </div>
        <ion-icon name="close" id="close-notification"></ion-icon>
    </div>
@endif

<div class="limiter">
    <div class="auth-container">
        <form method="POST" action="{{ route('login') }}" class="auth-form">
            {{ csrf_field() }}
            <h1> User Login </h1>

            @if ($errors->has('email'))
                <span class="error">
                    {{ $errors->first('email') }}
                </span>
            @endif

            <label for="email">Email</label>
            <div class="input-wrapper field">
                <ion-icon class="icon" name="person"></ion-icon>
                <input id="email" class="input" type="email" name="email" placeholder="Email" value="{{ old('email') }}" required>
            </div>

          

            <label for="password">Password</label>
            <div class="input-wrapper">
                <ion-icon class="icon" name="lock-closed"></ion-icon>
                <input class="input" type="password" name="password" placeholder="Password" required>
            </div>

            <div class="extra">
                <label>
                    <input type="checkbox" name="remember" {{ old('remember') ? 'checked' : '' }}> Remember Me
                </label>
                <div class="forget-pass">
                    <a href="{{ route('recover') }}"> Forgot password? </a>
                </div>	
            </div>

            <div class="btn-wrapper">
                <a href><button class="login-btn"> Login </button></a>
            </div>

            <div class="alt-methods">
                <hr class="line-before"> 
                <span> Or Login Using </span> 
                <hr class="line-after">
            </div>

            <button class="google-btn">
                <ion-icon class="opt-icon google" name="logo-google"></ion-icon>
                <span class="option google">Google</span>
            </button>

            <div class="toggle-login">
                <span> Don't have an account?
                    <a href="{{ route('register') }}" class="toggle-register">Register </a>
                </span>
            </div>

        </form>
    </div>
</div>

@endsection