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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Unidad <%= unidad %> - Sesión <%= sesionNum %></title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="navbar">
        <a href="sesiones.jsp?unidad=<%= unidad %>" class="navbar-brand">← Volver a Sesiones</a>
        <div class="user-badge">
            <img src="<%= (usuario.getFotoUrl() != null && !usuario.getFotoUrl().isEmpty()) ? usuario.getFotoUrl() : "https://ui-avatars.com/api/?name=" + usuario.getNombre() + "&background=0D8ABC&color=fff" %>" class="user-avatar" alt="Foto Perfil">
            <span style="font-weight: 600; font-size: 0.9rem;"><%= usuario.getNombre() %></span>
        </div>
    </div>

    <div class="container">
        <div class="glass-card" style="max-width: 650px; margin: 0 auto;">
            <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 1.5rem;">
                <div>
                    <span class="badge-tag">UNIDAD <%= unidad %> &bull; SESIÓN <%= sesionNum %></span>
                    <h2 style="font-size: 1.5rem; font-weight: 800; margin-top: 0.3rem;">Entrega de Avance Académico</h2>
                </div>
                <div style="font-size: 2.2rem;">📤</div>
            </div>

            <% if (request.getParameter("success") != null) { %>
                <div class="alert alert-success">
                    🎉 ¡Tu trabajo ha sido subido y guardado exitosamente en Supabase Storage!
                </div>
            <% } %>

            <% if (request.getParameter("error") != null) { %>
                <div class="alert alert-danger">
                    ⚠️ Ocurrió un error al procesar el archivo. Por favor verifica e intenta de nuevo.
                </div>
            <% } %>

            <% if (archivoExistenteUrl != null) { %>
                <div style="background: rgba(0, 242, 254, 0.05); border: 1px solid var(--cyan-glow); padding: 1.25rem; border-radius: 16px; margin-bottom: 1.75rem;">
                    <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                        <div>
                            <div style="font-size: 0.78rem; color: var(--cyan-glow); font-weight: 700;">ESTADO DE ENTREGA</div>
                            <div style="font-size: 0.95rem; font-weight: 600; margin-top: 2px;">Documento adjuntado anteriormente</div>
                        </div>
                        <a href="<%= archivoExistenteUrl %>" target="_blank" class="btn btn-secondary" style="font-size: 0.85rem; padding: 0.5rem 1rem;">
                            📁 Abrir / Descargar Archivo en Supabase
                        </a>
                    </div>
                </div>
            <% } %>

            <form action="subir-trabajo" method="post" enctype="multipart/form-data">
                <input type="hidden" name="unidad" value="<%= unidad %>">
                <input type="hidden" name="sesion" value="<%= sesionNum %>">

                <div class="form-group">
                    <label for="archivo"><%= (archivoExistenteUrl != null) ? "Reemplazar documento por uno nuevo" : "Seleccionar Imagen o Documento de Trabajo" %></label>
                    <input type="file" id="archivo" name="archivo" required>
                </div>

                <button type="submit" class="btn" style="width: 100%; margin-top: 0.75rem;">
                    ☁️ Subir Trabajo a Supabase Storage
                </button>
            </form>
        </div>
    </div>
</body>
</html>
