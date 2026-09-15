<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro - Arquitectura de Computadoras</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body style="justify-content: center; align-items: center;">
    <div class="glass-card" style="width: 100%; max-width: 460px;">
        <div style="text-align: center; margin-bottom: 1.75rem;">
            <h2 style="font-size: 1.6rem; font-weight: 800; background: var(--gradient-primary); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">Registro de Estudiante</h2>
            <p style="color: var(--text-secondary); font-size: 0.9rem; margin-top: 0.3rem;">Crea tu perfil y sube tu foto a Supabase</p>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger">
                ⚠️ <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <form action="registro" method="post" enctype="multipart/form-data">
            <div class="form-group">
                <label for="nombre">Nombre Completo</label>
                <input type="text" id="nombre" name="nombre" placeholder="Ej. Juan Carlos Pérez" required>
            </div>
            <div class="form-group">
                <label for="email">Correo Electrónico</label>
                <input type="email" id="email" name="email" placeholder="estudiante@universidad.edu.pe" required>
            </div>
            <div class="form-group">
                <label for="password">Contraseña</label>
                <input type="password" id="password" name="password" placeholder="••••••••" required>
            </div>
            <div class="form-group">
                <label for="foto">Foto de Perfil (Se guardará en Supabase Storage)</label>
                <input type="file" id="foto" name="foto" accept="image/*">
            </div>
            <button type="submit" class="btn" style="width: 100%; margin-top: 0.5rem;">
                ✨ Registrarme e Ingresar
            </button>
        </form>

        <p style="text-align: center; margin-top: 1.75rem; font-size: 0.88rem; color: var(--text-secondary);">
            ¿Ya tienes una cuenta? <a href="index.jsp" style="color: var(--cyan-glow); text-decoration: none; font-weight: 600;">Inicia sesión aquí</a>
        </p>
    </div>
</body>
</html>
