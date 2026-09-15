package com.arquitectura.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConfig {

    // URL directa y Pooler IPv4 para Supabase en servidores en la nube como Render
    // Intenta primero con Connection Pooler (puerto 6543) y si no, con conexión directa sslmode=require
    private static final String DEFAULT_URL = "jdbc:postgresql://aws-0-sa-east-1.pooler.supabase.co:6543/postgres?sslmode=require";
    private static final String FALLBACK_URL = "jdbc:postgresql://db.nosmllupbhkcvxcizkkz.supabase.co:5432/postgres?sslmode=require";
    
    private static final String DEFAULT_USER = "postgres.nosmllupbhkcvxcizkkz";
    private static final String FALLBACK_USER = "postgres";
    private static final String DEFAULT_PASSWORD = "lJAGTrWVICfSlXyZ";

    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        String url = System.getenv("DB_URL");
        String user = System.getenv("DB_USER");
        String password = System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : DEFAULT_PASSWORD;

        if (url != null && user != null) {
            return DriverManager.getConnection(url, user, password);
        }

        // Intento 1: Connection Pooler (Puerto 6543)
        try {
            return DriverManager.getConnection(DEFAULT_URL, DEFAULT_USER, DEFAULT_PASSWORD);
        } catch (SQLException e) {
            // Intento 2: Conexión directa (Puerto 5432)
            return DriverManager.getConnection(FALLBACK_URL, FALLBACK_USER, DEFAULT_PASSWORD);
        }
    }
}
