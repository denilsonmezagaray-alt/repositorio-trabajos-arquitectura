package com.arquitectura.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConfig {

    // Lista de URLs posibles para conectar a Supabase desde la nube
    private static final String[] DB_URLS = {
        "jdbc:postgresql://aws-0-sa-east-1.pooler.supabase.com:6543/postgres?sslmode=require",
        "jdbc:postgresql://db.nosmllupbhkcvxcizkkz.supabase.co:5432/postgres?sslmode=require",
        "jdbc:postgresql://db.nosmllupbhkcvxcizkkz.supabase.co:5432/postgres?sslmode=disable"
    };

    private static final String[] DB_USERS = {
        "postgres.nosmllupbhkcvxcizkkz",
        "postgres",
        "postgres"
    };

    private static final String DEFAULT_PASSWORD = "lJAGTrWVICfSlXyZ";

    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        String envUrl = System.getenv("DB_URL");
        String envUser = System.getenv("DB_USER");
        String password = System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : DEFAULT_PASSWORD;

        if (envUrl != null && envUser != null) {
            return DriverManager.getConnection(envUrl, envUser, password);
        }

        SQLException lastException = null;
        for (int i = 0; i < DB_URLS.length; i++) {
            try {
                return DriverManager.getConnection(DB_URLS[i], DB_USERS[i], password);
            } catch (SQLException e) {
                lastException = e;
            }
        }

        throw lastException != null ? lastException : new SQLException("No se pudo conectar a ninguna URL de Supabase.");
    }
}
