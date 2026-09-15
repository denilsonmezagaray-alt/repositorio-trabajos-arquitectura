-- =======================================================
-- REPOSITORIO DE TRABAJOS - ARQUITECTURA DE COMPUTADORAS
-- Script SQL para Supabase PostgreSQL
-- =======================================================

-- 1. Tabla de Usuarios
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    foto_url TEXT,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabla de Trabajos
CREATE TABLE IF NOT EXISTS trabajos (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    unidad INT NOT NULL CHECK (unidad BETWEEN 1 AND 4),
    sesion INT NOT NULL CHECK (sesion BETWEEN 1 AND 4),
    archivo_url TEXT NOT NULL,
    subido_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_usuario_unidad_sesion UNIQUE (usuario_id, unidad, sesion)
);

-- INSTRUCCIONES DE SUPABASE STORAGE:
-- En el panel de Supabase -> Storage, crea 2 Buckets con acceso PÚBLICO (Public Bucket):
-- 1) `avatars` (para fotos de perfil)
-- 2) `trabajos` (para los archivos de las tareas)
