<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Linterna Verde Arquitectura</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body style="justify-content: center; align-items: center;">
    <div class="glass-card" style="width: 100%; max-width: 440px;">
        <div style="text-align: center; margin-bottom: 2rem;">
            <div style="display: inline-flex; align-items: center; justify-content: center; width: 68px; height: 68px; background: rgba(0, 255, 135, 0.12); border: 1px solid rgba(0, 255, 135, 0.4); border-radius: 50%; margin-bottom: 1rem; color: var(--gl-glow); font-size: 2rem; box-shadow: 0 0 25px rgba(0,255,135,0.3);">
                🟢
            </div>
            <h2 style="font-size: 1.6rem; font-weight: 800; background: var(--gradient-gl); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">Cuerpo de Linternas</h2>
            <p style="color: var(--text-secondary); font-size: 0.9rem; margin-top: 0.3rem;">Repositorio - Arquitectura de Computadoras</p>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger">
                ⚠️ <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <% if (request.getParameter("registered") != null) { %>
            <div class="alert alert-success">
                ✨ ¡Poder activado! Cuenta creada. Inicia sesión.
            </div>
        <% } %>

        <form action="login" method="post">
            <div class="form-group">
                <label for="email">Correo del Guardián</label>
                <input type="email" id="email" name="email" placeholder="guardián@universidad.edu.pe" required>
            </div>
            <div class="form-group">
                <label for="password">Contraseña de Energía</label>
                <input type="password" id="password" name="password" placeholder="••••••••" required>
            </div>
            <button type="submit" class="btn" style="width: 100%; margin-top: 0.5rem;">
                🟢 Encender la Linterna (Ingresar)
            </button>
        </form>

        <p style="text-align: center; margin-top: 1.75rem; font-size: 0.88rem; color: var(--text-secondary);">
            ¿Aún no eres parte del cuerpo? <a href="registro.jsp" style="color: var(--gl-glow); text-decoration: none; font-weight: 700;">Únete aquí</a>
        </p>
    </div>
</body>
</html>
