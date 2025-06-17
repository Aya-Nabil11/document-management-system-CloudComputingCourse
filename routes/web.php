<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DocumentController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\DashboardController;

use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;

Route::get('/init-categories', function () {
    try {
        DB::statement("
            CREATE TABLE IF NOT EXISTS categories (
                id BIGSERIAL PRIMARY KEY,
                name VARCHAR(255),
                created_at TIMESTAMP,
                updated_at TIMESTAMP
            )
        ");
        return '✔️ Table categories created successfully.';
    } catch (\Exception $e) {
        return '❌ Error: ' . $e->getMessage();
    }
});

Route::get('/init-documents', function () {
    try {
        DB::statement("
            CREATE TABLE IF NOT EXISTS documents (
                id BIGSERIAL PRIMARY KEY,
                title VARCHAR(255),
                original_filename VARCHAR(255),
                file_path VARCHAR(255),
                file_type VARCHAR(255),
                category_id BIGINT,
                file_size BIGINT,
                content_preview TEXT,
                created_at TIMESTAMP,
                updated_at TIMESTAMP,
                FOREIGN KEY (category_id) REFERENCES categories(id)
            )
        ");
        return '✔️ Table documents created successfully.';
    } catch (\Exception $e) {
        return '❌ Error: ' . $e->getMessage();
    }
});


Route::get('/', [DocumentController::class , 'index'])->name('dashboard');

Route::get('/documents/search', [DocumentController::class, 'searchView'])
    ->name('documents.search');

Route::get('/documents/searchHandle', [DocumentController::class, 'search'])
    ->name('documents.searchHandle');

Route::resource('documents', DocumentController::class);

