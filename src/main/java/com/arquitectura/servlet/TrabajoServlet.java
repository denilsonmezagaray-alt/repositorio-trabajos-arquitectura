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
            // 1. Subir archivo a Supabase Storage (Bucket: trabajos)
            String archivoUrl = SupabaseStorageUtil.uploadFile("trabajos", archivoPart.getSubmittedFileName(), is, archivoPart.getContentType());

            // 2. Guardar/Actualizar registro en PostgreSQL
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
