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
    String imgUnidad = "img/unit" + unidad + ".png";
    String[] titulosUnidades = {
        "",
        "Fundamentos de CPU",
        "Jerarquía de Memoria",
        "Entrada / Salida & Buses",
        "Arquitecturas Avanzadas"
    };
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Unidad <%= unidad %> - Sesiones</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="navbar">
        <a href="dashboard.jsp" class="navbar-brand">← Volver al Dashboard</a>
        <div class="user-badge">
            <img src="<%= (usuario.getFotoUrl() != null && !usuario.getFotoUrl().isEmpty()) ? usuario.getFotoUrl() : "https://ui-avatars.com/api/?name=" + usuario.getNombre() + "&background=0D8ABC&color=fff" %>" class="user-avatar" alt="Foto Perfil">
            <span style="font-weight: 600; font-size: 0.9rem;"><%= usuario.getNombre() %></span>
        </div>
    </div>

    <div class="container">
        <!-- HEADER DE LA UNIDAD CON BANNER Y BADGE -->
        <div class="glass-card" style="display: flex; align-items: center; gap: 2rem; padding: 2rem; margin-bottom: 2.5rem; flex-wrap: wrap;">
            <img src="<%= imgUnidad %>" alt="Unidad" style="width: 140px; height: 110px; object-fit: cover; border-radius: 16px; border: 1px solid var(--border-color);">
            <div style="flex: 1;">
                <span class="badge-tag">UNIDAD 0<%= unidad %></span>
                <h1 style="font-size: 1.6rem; font-weight: 800; margin-top: 0.2rem;"><%= titulosUnidades[unidad] %></h1>
                <p style="color: var(--text-secondary); font-size: 0.9rem; margin-top: 0.3rem;">Selecciona cualquiera de las 4 sesiones programadas para enviar o revisar tu informe de laboratorio.</p>
            </div>
        </div>

        <h2 style="font-size: 1.25rem; font-weight: 700; margin-bottom: 1.25rem;">
            📌 Sesiones de la Unidad <%= unidad %>
        </h2>

        <div class="grid-units">
            <% for (int s = 1; s <= 4; s++) { %>
                <a href="trabajos.jsp?unidad=<%= unidad %>&sesion=<%= s %>" class="unit-card-img" style="min-height: 160px;">
                    <div class="unit-card-body">
                        <div>
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem;">
                                <span class="badge-tag">SESIÓN 0<%= s %></span>
                                <span style="font-size: 1.2rem;">📝</span>
                            </div>
                            <h3 style="font-size: 1.1rem; font-weight: 700; margin-bottom: 0.4rem;">Laboratorio Sesión <%= s %></h3>
                            <p style="font-size: 0.82rem; color: var(--text-secondary);">Subida de entregables, captura de código o reporte técnico.</p>
                        </div>
                        <div style="margin-top: 1.5rem; color: var(--cyan-glow); font-weight: 700; font-size: 0.85rem;">
                            Gestionar Trabajo →
                        </div>
                    </div>
                </a>
            <% } %>
        </div>
    </div>
</body>
</html>
