package com.arquitectura.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConfig {

    // Lista de endpoints de Supabase con usuario postgres estándar en el pooler y conexión directa
    private static final String[] DB_URLS = {
        "jdbc:postgresql://db.nosmllupbhkcvxcizkkz.supabase.co:5432/postgres?sslmode=require",
        "jdbc:postgresql://aws-0-sa-east-1.pooler.supabase.com:6543/postgres?sslmode=require",
        "jdbc:postgresql://aws-0-sa-east-1.pooler.supabase.com:5432/postgres?sslmode=require"
    };

    private static final String[] DB_USERS = {
        "postgres",
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

        StringBuilder errorLog = new StringBuilder();
        for (int i = 0; i < DB_URLS.length; i++) {
            try {
                return DriverManager.getConnection(DB_URLS[i], DB_USERS[i], password);
            } catch (SQLException e) {
                errorLog.append("[").append(i).append("] ").append(e.getMessage()).append("; ");
            }
        }

        throw new SQLException("Fallaron conexiones: " + errorLog.toString());
    }
}
