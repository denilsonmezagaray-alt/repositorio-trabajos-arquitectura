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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Linterna Verde Arquitectura</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <!-- NAVBAR LINTERNA VERDE -->
    <div class="navbar">
        <a href="dashboard.jsp" class="navbar-brand">
            <span>🟢</span> Green Lantern Corps - Arquitectura
        </a>
        <div class="user-badge">
            <img src="<%= (usuario.getFotoUrl() != null && !usuario.getFotoUrl().isEmpty()) ? usuario.getFotoUrl() : "https://ui-avatars.com/api/?name=" + usuario.getNombre() + "&background=059669&color=fff" %>" class="user-avatar" alt="Foto Perfil">
            <span style="font-weight: 700; font-size: 0.9rem;"><%= usuario.getNombre() %></span>
            <a href="logout" class="btn btn-secondary" style="padding: 0.35rem 0.85rem; font-size: 0.8rem; border-radius: 30px;">Desconectar</a>
        </div>
    </div>

    <div class="container">
        <!-- HERO BANNER CON ENERGÍA VERDE -->
        <div class="hero-banner" style="background-image: url('img/hero.png');">
            <div class="hero-overlay"></div>
            <div class="hero-content">
                <span class="badge-tag">SECTOR 2814 &bull; NÚCLEO DE PODER</span>
                <h1 class="hero-title">Matriz de Fuerza y Aprendizaje</h1>
                <p class="hero-subtitle">"En el día más brillante, en la noche más oscura... ningún avance de arquitectura escapará de mi vista."</p>
            </div>
        </div>

        <!-- CHARTS & AVANCE DE PODER -->
        <div class="glass-card" style="margin-bottom: 2.5rem;">
            <div style="display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 2rem;">
                <div style="flex: 1; min-width: 250px;">
                    <span class="badge-tag">NIVEL DE ENERGÍA</span>
                    <h2 style="font-size: 1.5rem; font-weight: 800; margin-bottom: 0.5rem; color: var(--gl-emerald);">Recarga del Anillo de Poder</h2>
                    <p style="color: var(--text-secondary); font-size: 0.9rem; line-height: 1.6;">
                        Has forjado y entregado <strong style="color: var(--gl-glow); font-size: 1.15rem;"><%= trabajosSubidos %></strong> de <strong>16</strong> constelaciones/sesiones en la batería central.
                    </p>
                    <div style="margin-top: 1.5rem; display: flex; gap: 1rem;">
                        <div style="background: rgba(0, 255, 135, 0.05); padding: 12px 20px; border-radius: 14px; border: 1px solid var(--border-color);">
                            <div style="font-size: 0.75rem; color: var(--text-secondary);">Recarga Completa</div>
                            <div style="font-size: 1.3rem; font-weight: 800; color: var(--gl-glow);"><%= Math.round((trabajosSubidos / 16.0) * 100) %>%</div>
                        </div>
                        <div style="background: rgba(0, 255, 135, 0.05); padding: 12px 20px; border-radius: 14px; border: 1px solid var(--border-color);">
                            <div style="font-size: 0.75rem; color: var(--text-secondary);">Pendientes</div>
                            <div style="font-size: 1.3rem; font-weight: 800; color: #f43f5e;"><%= 16 - trabajosSubidos %></div>
                        </div>
                    </div>
                </div>
                <div style="width: 210px;">
                    <canvas id="progressChart"></canvas>
                </div>
            </div>
        </div>

        <!-- UNIDADES DE ENERGÍA CON IMÁGENES DÍNAMICAS ESMERALDA -->
        <h2 style="font-size: 1.35rem; font-weight: 800; margin-bottom: 1.25rem; display: flex; align-items: center; gap: 10px; color: var(--gl-glow);">
            🟢 Cuadrantes de Conocimiento
        </h2>
        
        <div class="grid-units">
            <a href="sesiones.jsp?unidad=1" class="unit-card-img">
                <img src="img/unit1.png" class="unit-card-media" alt="Unidad 1">
                <div class="unit-card-body">
                    <div>
                        <span class="badge-tag">CUADRANTE 01</span>
                        <h3 style="font-size: 1.1rem; font-weight: 700; margin-bottom: 0.4rem;">Fuerza Central de CPU</h3>
                        <p style="font-size: 0.82rem; color: var(--text-secondary);">Construcción del procesador, ALU de esmeralda y set de instrucciones.</p>
                    </div>
                    <div style="margin-top: 1rem; color: var(--gl-glow); font-weight: 800; font-size: 0.85rem; display: flex; align-items: center; gap: 5px;">
                        Ver 4 Sesiones →
                    </div>
                </div>
            </a>

            <a href="sesiones.jsp?unidad=2" class="unit-card-img">
                <img src="img/unit2.png" class="unit-card-media" alt="Unidad 2">
                <div class="unit-card-body">
                    <div>
                        <span class="badge-tag">CUADRANTE 02</span>
                        <h3 style="font-size: 1.1rem; font-weight: 700; margin-bottom: 0.4rem;">Matriz de Memoria</h3>
                        <p style="font-size: 0.82rem; color: var(--text-secondary);">Memoria Caché de plasma verde, RAM principal y mapeo continuo.</p>
                    </div>
                    <div style="margin-top: 1rem; color: var(--gl-glow); font-weight: 800; font-size: 0.85rem; display: flex; align-items: center; gap: 5px;">
                        Ver 4 Sesiones →
                    </div>
                </div>
            </a>

            <a href="sesiones.jsp?unidad=3" class="unit-card-img">
                <img src="img/unit3.png" class="unit-card-media" alt="Unidad 3">
                <div class="unit-card-body">
                    <div>
                        <span class="badge-tag">CUADRANTE 03</span>
                        <h3 style="font-size: 1.1rem; font-weight: 700; margin-bottom: 0.4rem;">Buses de Luz & I/O</h3>
                        <p style="font-size: 0.82rem; color: var(--text-secondary);">Canales de transmisión directa DMA y buses de interrupción fotónica.</p>
                    </div>
                    <div style="margin-top: 1rem; color: var(--gl-glow); font-weight: 800; font-size: 0.85rem; display: flex; align-items: center; gap: 5px;">
                        Ver 4 Sesiones →
                    </div>
                </div>
            </a>

            <a href="sesiones.jsp?unidad=4" class="unit-card-img">
                <img src="img/unit4.png" class="unit-card-media" alt="Unidad 4">
                <div class="unit-card-body">
                    <div>
                        <span class="badge-tag">CUADRANTE 04</span>
                        <h3 style="font-size: 1.1rem; font-weight: 700; margin-bottom: 0.4rem;">Supernúcleos Cuánticos</h3>
                        <p style="font-size: 0.82rem; color: var(--text-secondary);">Matriz multihilo masiva, GPUs y arquitecturas de poder cósmico.</p>
                    </div>
                    <div style="margin-top: 1rem; color: var(--gl-glow); font-weight: 800; font-size: 0.85rem; display: flex; align-items: center; gap: 5px;">
                        Ver 4 Sesiones →
                    </div>
                </div>
            </a>
        </div>
    </div>

    <script>
        const ctx = document.getElementById('progressChart').getContext('2d');
        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Energía Recargada', 'Pendiente'],
                datasets: [{
                    data: [<%= trabajosSubidos %>, <%= 16 - trabajosSubidos %>],
                    backgroundColor: ['#00ff87', 'rgba(16, 185, 129, 0.1)'],
                    borderColor: '#040d08',
                    borderWidth: 3,
                    hoverOffset: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                cutout: '75%',
                plugins: {
                    legend: { display: false }
                }
            }
        });
    </script>
</body>
</html>
