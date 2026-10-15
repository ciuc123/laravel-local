<?php

use App\Http\Controllers\LeetcodeController;
use App\Http\Controllers\LemonIoTestController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/leetcode/show/{problem}/', [LeetcodeController::class, 'show'])->name('leetcode.show');

Route::get('/', function(){
    return view('welcome', [
        'greeting' => "Hello world",
        'person' => request('person', "World"),
    ]);
});

Route::get("/lemon", LemonIoTestController::class)->name('lemon');
