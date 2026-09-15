# Proyecto: Repositorio de Trabajos - Arquitectura de Computadoras

Este proyecto implementa una aplicación Web en Java (JSP/Servlets) con base de datos PostgreSQL en Supabase y almacenamiento de archivos en Supabase Storage (fotos de perfil y entrega de trabajos por unidad/sesión).

---

## 1. Script SQL para Supabase (PostgreSQL)

Ejecuta el siguiente script en el **SQL Editor** de tu panel de Supabase:

```sql
-- Crear tabla de Usuarios
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    foto_url TEXT,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla de Trabajos
CREATE TABLE IF NOT EXISTS trabajos (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    unidad INT NOT NULL CHECK (unidad BETWEEN 1 AND 4),
    sesion INT NOT NULL CHECK (sesion BETWEEN 1 AND 4),
    archivo_url TEXT NOT NULL,
    subido_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_usuario_unidad_sesion UNIQUE (usuario_id, unidad, sesion)
);

-- Configuración de Supabase Storage:
-- Debes crear dos Buckets Públicos en Supabase Storage:
-- 1. `avatars` (para fotos de perfil)
-- 2. `trabajos` (para documentos/imágenes de tareas)
```

---

## 2. Estructura Completa del Proyecto Maven

```text
repositorio/
├── pom.xml
└── src/
    └── main/
        ├── java/
        │   └── com/
        │       └── arquitectura/
        │           ├── config/
        │           │   └── DBConfig.java
        │           ├── model/
        │           │   ├── Usuario.java
        │           │   └── Trabajo.java
        │           ├── util/
        │           │   └── SupabaseStorageUtil.java
        │           └── servlet/
        │               ├── LoginServlet.java
        │               ├── RegistroServlet.java
        │               ├── LogoutServlet.java
        │               └── TrabajoServlet.java
        └── webapp/
            ├── css/
            │   └── style.css
            ├── WEB-INF/
            │   └── web.xml
            ├── index.jsp
            ├── registro.jsp
            ├── dashboard.jsp
            ├── sesiones.jsp
            └── trabajos.jsp
```

---

## 3. Archivo `pom.xml`

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.arquitectura</groupId>
    <artifactId>repositorio-trabajos</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>war</packaging>

    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <dependencies>
        <!-- Jakarta Servlet API / Java EE Servlet API (Tomcat 10+ utiliza jakarta.servlet) -->
        <dependency>
            <groupId>jakarta.servlet</groupId>
            <artifactId>jakarta.servlet-api</artifactId>
            <version>6.0.0</version>
            <scope>provided</scope>
        </dependency>

        <!-- Driver JDBC de PostgreSQL -->
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <version>42.7.2</version>
        </dependency>

        <!-- Jackson / JSON processing para leer respuestas de Supabase si se requiere -->
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
            <version>2.17.0</version>
        </dependency>
    </dependencies>

    <build>
        <finalName>repositorio-trabajos</finalName>
    </build>
</project>
```

---

## 4. Configuración de Base de Datos (`DBConfig.java`)

```java
package com.arquitectura.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConfig {
    // Reemplaza con los datos de tu Supabase (Settings -> Database -> Connection string / Direct Connection)
    private static final String URL = "jdbc:postgresql://db.YOUR_SUPABASE_PROJECT.supabase.co:5432/postgres";
    private static final String USER = "postgres";
    private static final String PASSWORD = "YOUR_DATABASE_PASSWORD";

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
```

---

## 5. Clase Utilitaria para Supabase Storage (`SupabaseStorageUtil.java`)

Esta clase hace peticiones HTTP a la API REST de Supabase Storage para subir imágenes y archivos sin librerías externas pesadas.

```java
package com.arquitectura.util;

import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.UUID;

public class SupabaseStorageUtil {

    // Configura la URL de tu proyecto y la Anon key o Service Role key de Supabase
    private static final String SUPABASE_URL = "https://YOUR_PROJECT_ID.supabase.co";
    private static final String SUPABASE_KEY = "YOUR_SUPABASE_ANON_KEY";

    /**
     * Subes un archivo a Supabase Storage y retorna la URL pública del archivo.
     */
    public static String uploadFile(String bucketName, String originalFilename, InputStream inputStream, String contentType) throws Exception {
        String ext = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            ext = originalFilename.substring(originalFilename.lastIndexOf("."));
        }
        String fileName = UUID.randomUUID().toString() + ext;
        
        String uploadEndpoint = SUPABASE_URL + "/storage/v1/object/" + bucketName + "/" + fileName;

        URL url = new URL(uploadEndpoint);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Authorization", "Bearer " + SUPABASE_KEY);
        conn.setRequestProperty("apikey", SUPABASE_KEY);
        conn.setRequestProperty("Content-Type", contentType != null ? contentType : "application/octet-stream");

        try (OutputStream os = conn.getOutputStream()) {
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }
            os.flush();
        }

        int responseCode = conn.getResponseCode();
        if (responseCode == 200 || responseCode == 201) {
            // URL Pública de acceso
            return SUPABASE_URL + "/storage/v1/object/public/" + bucketName + "/" + fileName;
        } else {
            throw new RuntimeException("Error al subir archivo a Supabase Storage. HTTP Code: " + responseCode);
        }
    }
}
```

---

## 6. Modelos Java (`Usuario.java` y `Trabajo.java`)

```java
package com.arquitectura.model;

public class Usuario {
    private int id;
    private String nombre;
    private String email;
    private String fotoUrl;

    public Usuario() {}

    public Usuario(int id, String nombre, String email, String fotoUrl) {
        this.id = id;
        this.nombre = nombre;
        this.email = email;
        this.fotoUrl = fotoUrl;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getFotoUrl() { return fotoUrl; }
    public void setFotoUrl(String fotoUrl) { this.fotoUrl = fotoUrl; }
}
```

```java
package com.arquitectura.model;

public class Trabajo {
    private int id;
    private int usuarioId;
    private int unidad;
    private int sesion;
    private String archivoUrl;

    public Trabajo() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUsuarioId() { return usuarioId; }
    public void setUsuarioId(int usuarioId) { this.usuarioId = usuarioId; }

    public int getUnidad() { return unidad; }
    public void setUnidad(int unidad) { this.unidad = unidad; }

    public int getSesion() { return sesion; }
    public void setSesion(int sesion) { this.sesion = sesion; }

    public String getArchivoUrl() { return archivoUrl; }
    public void setArchivoUrl(String archivoUrl) { this.archivoUrl = archivoUrl; }
}
```

---

## 7. Servlets (`LoginServlet`, `RegistroServlet`, `TrabajoServlet`)

### `LoginServlet.java`
```java
package com.arquitectura.servlet;

import com.arquitectura.config.DBConfig;
import com.arquitectura.model.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        try (Connection conn = DBConfig.getConnection()) {
            String sql = "SELECT id, nombre, email, foto_url FROM usuarios WHERE email = ? AND password = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            stmt.setString(2, password);

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Usuario usuario = new Usuario(
                    rs.getInt("id"),
                    rs.getString("nombre"),
                    rs.getString("email"),
                    rs.getString("foto_url")
                );

                HttpSession session = req.getSession();
                session.setAttribute("usuario", usuario);
                resp.sendRedirect("dashboard.jsp");
            } else {
                req.setAttribute("error", "Credenciales incorrectas");
                req.getRequestDispatcher("index.jsp").forward(req, resp);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Error de conexión con la base de datos");
            req.getRequestDispatcher("index.jsp").forward(req, resp);
        }
    }
}
```

### `RegistroServlet.java`
```java
package com.arquitectura.servlet;

import com.arquitectura.config.DBConfig;
import com.arquitectura.util.SupabaseStorageUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/registro")
@MultipartConfig
public class RegistroServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String nombre = req.getParameter("nombre");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        Part fotoPart = req.getPart("foto");

        String fotoUrl = null;

        if (fotoPart != null && fotoPart.getSize() > 0) {
            try (InputStream is = fotoPart.getInputStream()) {
                fotoUrl = SupabaseStorageUtil.uploadFile("avatars", fotoPart.getSubmittedFileName(), is, fotoPart.getContentType());
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        try (Connection conn = DBConfig.getConnection()) {
            String sql = "INSERT INTO usuarios (nombre, email, password, foto_url) VALUES (?, ?, ?, ?)";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, nombre);
            stmt.setString(2, email);
            stmt.setString(3, password);
            stmt.setString(4, fotoUrl);
            stmt.executeUpdate();

            resp.sendRedirect("index.jsp?registered=true");
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error al registrar el usuario.");
            req.getRequestDispatcher("registro.jsp").forward(req, resp);
        }
    }
}
```

### `TrabajoServlet.java`
```java
package com.arquitectura.servlet;

import com.arquitectura.config.DBConfig;
import com.arquitectura.model.Usuario;
import com.arquitectura.util.SupabaseStorageUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/subir-trabajo")
@MultipartConfig
public class TrabajoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect("index.jsp");
            return;
        }

        Usuario usuario = (Usuario) session.getAttribute("usuario");
        int unidad = Integer.parseInt(req.getParameter("unidad"));
        int sesionNum = Integer.parseInt(req.getParameter("sesion"));
        Part archivoPart = req.getPart("archivo");

        if (archivoPart == null || archivoPart.getSize() == 0) {
            resp.sendRedirect("trabajos.jsp?unidad=" + unidad + "&sesion=" + sesionNum + "&error=nofile");
            return;
        }

        try (InputStream is = archivoPart.getInputStream()) {
            String archivoUrl = SupabaseStorageUtil.uploadFile("trabajos", archivoPart.getSubmittedFileName(), is, archivoPart.getContentType());

            try (Connection conn = DBConfig.getConnection()) {
                String sql = "INSERT INTO trabajos (usuario_id, unidad, sesion, archivo_url) VALUES (?, ?, ?, ?) " +
                             "ON CONFLICT (usuario_id, unidad, sesion) DO UPDATE SET archivo_url = EXCLUDED.archivo_url, subido_en = CURRENT_TIMESTAMP";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setInt(1, usuario.getId());
                stmt.setInt(2, unidad);
                stmt.setInt(3, sesionNum);
                stmt.setString(4, archivoUrl);
                stmt.executeUpdate();
            }

            resp.sendRedirect("trabajos.jsp?unidad=" + unidad + "&sesion=" + sesionNum + "&success=true");
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("trabajos.jsp?unidad=" + unidad + "&sesion=" + sesionNum + "&error=true");
        }
    }
}
```

---

## 8. Estilo CSS "Modo Oscuro Tech" (`style.css`)

```css
:root {
    --bg-color: #0b0f19;
    --card-bg: #111827;
    --border-color: #1f2937;
    --accent-color: #00f2fe;
    --accent-gradient: linear-gradient(135deg, #00c6ff 0%, #0072ff 100%);
    --text-primary: #f9fafb;
    --text-secondary: #9ca3af;
}

body {
    margin: 0;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: var(--bg-color);
    color: var(--text-primary);
    min-height: 100vh;
    display: flex;
    flex-direction: column;
}

.navbar {
    background-color: var(--card-bg);
    border-bottom: 1px solid var(--border-color);
    padding: 15px 30px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.navbar h1 {
    margin: 0;
    font-size: 1.2rem;
    color: #00f2fe;
}

.user-profile {
    display: flex;
    align-items: center;
    gap: 12px;
}

.user-avatar {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    object-fit: cover;
    border: 2px solid var(--accent-color);
}

.container {
    max-width: 1000px;
    margin: 40px auto;
    padding: 0 20px;
    flex: 1;
}

.card {
    background: var(--card-bg);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 30px;
    box-shadow: 0 8px 24px rgba(0,0,0,0.4);
}

.form-group {
    margin-bottom: 20px;
}

label {
    display: block;
    margin-bottom: 8px;
    color: var(--text-secondary);
}

input[type="text"],
input[type="email"],
input[type="password"],
input[type="file"] {
    width: 100%;
    padding: 12px;
    border-radius: 8px;
    border: 1px solid var(--border-color);
    background-color: #1a2234;
    color: #fff;
    box-sizing: border-box;
}

.btn {
    background: var(--accent-gradient);
    color: white;
    padding: 12px 24px;
    border: none;
    border-radius: 8px;
    font-weight: bold;
    cursor: pointer;
    text-decoration: none;
    display: inline-block;
}

.btn:hover {
    opacity: 0.9;
}

.grid-4 {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 20px;
    margin-top: 20px;
}

.unit-card, .session-card {
    background-color: #151d30;
    border: 1px solid var(--border-color);
    padding: 25px;
    border-radius: 10px;
    text-align: center;
    transition: transform 0.2s, border-color 0.2s;
}

.unit-card:hover, .session-card:hover {
    transform: translateY(-4px);
    border-color: var(--accent-color);
}
```

---

## 9. Vistas JSP (`index.jsp`, `registro.jsp`, `dashboard.jsp`, `sesiones.jsp`, `trabajos.jsp`)

### `index.jsp`
```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Login - Arquitectura de Computadoras</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body style="display:flex; justify-content:center; align-items:center;">
    <div class="card" style="width: 100%; max-width: 400px;">
        <h2 style="text-align:center; color: var(--accent-color);">Iniciar Sesión</h2>
        <p style="text-align:center; color: var(--text-secondary);">Repositorio de Trabajos</p>

        <% if (request.getAttribute("error") != null) { %>
            <div style="color: #ff4d4d; margin-bottom: 15px; text-align: center;">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <form action="login" method="post">
            <div class="form-group">
                <label>Correo Electrónico</label>
                <input type="email" name="email" required>
            </div>
            <div class="form-group">
                <label>Contraseña</label>
                <input type="password" name="password" required>
            </div>
            <button type="submit" class="btn" style="width: 100%;">Ingresar</button>
        </form>
        <p style="text-align: center; margin-top: 20px;">
            ¿No tienes cuenta? <a href="registro.jsp" style="color: var(--accent-color);">Regístrate aquí</a>
        </p>
    </div>
</body>
</html>
```

### `registro.jsp`
```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Registro - Arquitectura de Computadoras</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body style="display:flex; justify-content:center; align-items:center;">
    <div class="card" style="width: 100%; max-width: 450px;">
        <h2 style="text-align:center; color: var(--accent-color);">Crear Cuenta</h2>

        <% if (request.getAttribute("error") != null) { %>
            <div style="color: #ff4d4d; margin-bottom: 15px; text-align: center;">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <form action="registro" method="post" enctype="multipart/form-data">
            <div class="form-group">
                <label>Nombre Completo</label>
                <input type="text" name="nombre" required>
            </div>
            <div class="form-group">
                <label>Correo Electrónico</label>
                <input type="email" name="email" required>
            </div>
            <div class="form-group">
                <label>Contraseña</label>
                <input type="password" name="password" required>
            </div>
            <div class="form-group">
                <label>Foto de Perfil</label>
                <input type="file" name="foto" accept="image/*">
            </div>
            <button type="submit" class="btn" style="width: 100%;">Registrarse</button>
        </form>
        <p style="text-align: center; margin-top: 20px;">
            ¿Ya tienes cuenta? <a href="index.jsp" style="color: var(--accent-color);">Inicia Sesión</a>
        </p>
    </div>
</body>
</html>
```

### `dashboard.jsp`
```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.arquitectura.model.Usuario" %>
<%@ page import="com.arquitectura.config.DBConfig" %>
<%@ page import="java.sql.*" %>

<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    int trabajosSubidos = 0;
    try (Connection conn = DBConfig.getConnection()) {
        String sql = "SELECT COUNT(*) FROM trabajos WHERE usuario_id = ?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, usuario.getId());
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            trabajosSubidos = rs.getInt(1);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Dashboard - Arquitectura de Computadoras</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <div class="navbar">
        <h1>Arquitectura de Computadoras</h1>
        <div class="user-profile">
            <img src="<%= (usuario.getFotoUrl() != null && !usuario.getFotoUrl().isEmpty()) ? usuario.getFotoUrl() : "https://via.placeholder.com/40" %>" class="user-avatar" alt="Avatar">
            <span><%= usuario.getNombre() %></span>
        </div>
    </div>

    <div class="container">
        <div class="card" style="margin-bottom: 30px;">
            <h2>Progreso del Curso</h2>
            <div style="width: 250px; margin: 0 auto;">
                <canvas id="progressChart"></canvas>
            </div>
            <p style="text-align: center; margin-top: 15px;">
                Has completado <strong><%= trabajosSubidos %></strong> de <strong>16</strong> sesiones.
            </p>
        </div>

        <h2>Unidades Académicas</h2>
        <div class="grid-4">
            <a href="sesiones.jsp?unidad=1" style="text-decoration:none; color:inherit;">
                <div class="unit-card">
                    <h3>Unidad 1</h3>
                    <p>Fundamentos de Arquitectura</p>
                </div>
            </a>
            <a href="sesiones.jsp?unidad=2" style="text-decoration:none; color:inherit;">
                <div class="unit-card">
                    <h3>Unidad 2</h3>
                    <p>Procesadores y Memoria</p>
                </div>
            </a>
            <a href="sesiones.jsp?unidad=3" style="text-decoration:none; color:inherit;">
                <div class="unit-card">
                    <h3>Unidad 3</h3>
                    <p>Entrada / Salida y Bus</p>
                </div>
            </a>
            <a href="sesiones.jsp?unidad=4" style="text-decoration:none; color:inherit;">
                <div class="unit-card">
                    <h3>Unidad 4</h3>
                    <p>Arquitecturas Avanzadas</p>
                </div>
            </a>
        </div>
    </div>

    <script>
        const ctx = document.getElementById('progressChart').getContext('2d');
        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Completadas', 'Pendientes'],
                datasets: [{
                    data: [<%= trabajosSubidos %>, <%= 16 - trabajosSubidos %>],
                    backgroundColor: ['#00f2fe', '#1f2937'],
                    borderWidth: 0
                }]
            },
            options: {
                plugins: {
                    legend: { labels: { color: '#f9fafb' } }
                }
            }
        });
    </script>
</body>
</html>
```

### `sesiones.jsp`
```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.arquitectura.model.Usuario" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    String unidadParam = request.getParameter("unidad");
    int unidad = (unidadParam != null) ? Integer.parseInt(unidadParam) : 1;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Unidad <%= unidad %> - Sesiones</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="navbar">
        <h1><a href="dashboard.jsp" style="color:#00f2fe; text-decoration:none;">← Volver al Dashboard</a></h1>
        <div class="user-profile">
            <img src="<%= usuario.getFotoUrl() %>" class="user-avatar" alt="Avatar">
            <span><%= usuario.getNombre() %></span>
        </div>
    </div>

    <div class="container">
        <h2>Unidad <%= unidad %>: Sesiones de Aprendizaje</h2>
        <div class="grid-4">
            <% for (int s = 1; s <= 4; s++) { %>
                <a href="trabajos.jsp?unidad=<%= unidad %>&sesion=<%= s %>" style="text-decoration:none; color:inherit;">
                    <div class="session-card">
                        <h3>Sesión <%= s %></h3>
                        <p>Subir o ver trabajo entregado</p>
                    </div>
                </a>
            <% } %>
        </div>
    </div>
</body>
</html>
```

### `trabajos.jsp`
```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.arquitectura.model.Usuario" %>
<%@ page import="com.arquitectura.config.DBConfig" %>
<%@ page import="java.sql.*" %>

<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    int unidad = Integer.parseInt(request.getParameter("unidad"));
    int sesionNum = Integer.parseInt(request.getParameter("sesion"));

    String archivoExistenteUrl = null;
    try (Connection conn = DBConfig.getConnection()) {
        String sql = "SELECT archivo_url FROM trabajos WHERE usuario_id = ? AND unidad = ? AND sesion = ?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, usuario.getId());
        stmt.setInt(2, unidad);
        stmt.setInt(3, sesionNum);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            archivoExistenteUrl = rs.getString("archivo_url");
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Unidad <%= unidad %> - Sesión <%= sesionNum %></title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="navbar">
        <h1><a href="sesiones.jsp?unidad=<%= unidad %>" style="color:#00f2fe; text-decoration:none;">← Volver a Sesiones</a></h1>
        <div class="user-profile">
            <img src="<%= usuario.getFotoUrl() %>" class="user-avatar" alt="Avatar">
            <span><%= usuario.getNombre() %></span>
        </div>
    </div>

    <div class="container">
        <div class="card">
            <h2>Entrega de Trabajo - Unidad <%= unidad %>, Sesión <%= sesionNum %></h2>

            <% if (archivoExistenteUrl != null) { %>
                <div style="background-color: #102a43; border: 1px solid #00f2fe; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
                    <p style="margin: 0;">Ya has subido un archivo para esta sesión:</p>
                    <a href="<%= archivoExistenteUrl %>" target="_blank" style="color: #00f2fe; word-break: break-all;">Ver archivo subido</a>
                </div>
            <% } %>

            <form action="subir-trabajo" method="post" enctype="multipart/form-data">
                <input type="hidden" name="unidad" value="<%= unidad %>">
                <input type="hidden" name="sesion" value="<%= sesionNum %>">

                <div class="form-group">
                    <label>Selecciona tu archivo o imagen del trabajo</label>
                    <input type="file" name="archivo" required>
                </div>

                <button type="submit" class="btn">Subir Trabajo a Supabase</button>
            </form>
        </div>
    </div>
</body>
</html>
```
