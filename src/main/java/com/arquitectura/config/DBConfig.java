package com.arquitectura.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConfig {

    // 1. Direct Domain en puerto 5432 (postgres)
    // 2. Direct Domain en puerto 6543 (postgres)
    // 3. Pooler Directo con user=postgres.nosmllupbhkcvxcizkkz
    private static final String[] DB_URLS = {
        "jdbc:postgresql://db.nosmllupbhkcvxcizkkz.supabase.co:5432/postgres?sslmode=require&user=postgres",
        "jdbc:postgresql://db.nosmllupbhkcvxcizkkz.supabase.co:6543/postgres?sslmode=require&user=postgres",
        "jdbc:postgresql://aws-0-sa-east-1.pooler.supabase.com:6543/postgres?sslmode=require&user=postgres.nosmllupbhkcvxcizkkz",
        "jdbc:postgresql://aws-0-us-east-1.pooler.supabase.com:6543/postgres?sslmode=require&user=postgres.nosmllupbhkcvxcizkkz"
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
                return DriverManager.getConnection(DB_URLS[i], "postgres", password);
            } catch (SQLException e) {
                errorLog.append("[").append(i).append("] ").append(e.getMessage()).append("; ");
            }
        }

        throw new SQLException("Fallaron conexiones: " + errorLog.toString());
    }
}
