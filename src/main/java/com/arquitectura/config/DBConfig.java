package com.arquitectura.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConfig {

    // Configuración JDBC para PostgreSQL en Supabase con SSL activado para la nube (Render)
    private static final String DEFAULT_URL = "jdbc:postgresql://db.nosmllupbhkcvxcizkkz.supabase.co:5432/postgres?sslmode=require";
    private static final String DEFAULT_USER = "postgres";
    private static final String DEFAULT_PASSWORD = "lJAGTrWVICfSlXyZ";

    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        String url = System.getenv("DB_URL") != null ? System.getenv("DB_URL") : DEFAULT_URL;
        String user = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : DEFAULT_USER;
        String password = System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : DEFAULT_PASSWORD;

        return DriverManager.getConnection(url, user, password);
    }
}
