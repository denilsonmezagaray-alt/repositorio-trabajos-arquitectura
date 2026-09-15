package com.arquitectura.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConfig {

    // Configuración para conexión con PostgreSQL en Supabase
    // Ajusta la URL, usuario y contraseña según tu panel de Supabase:
    // Settings -> Database -> Connection string / Direct Connection
    private static final String URL = "jdbc:postgresql://db.nosmllupbhkcvxcizkkz.supabase.co:5432/postgres?user=postgres&password=lJAGTrWVICfSlXyZ";
    private static final String USER = "postgres";
    private static final String PASSWORD = "lJAGTrWVICfSlXyZ";

    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
