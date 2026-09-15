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
        req.setCharacterEncoding("UTF-8");
        String nombre = req.getParameter("nombre");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        Part fotoPart = req.getPart("foto");

        String fotoUrl = null;

        // Subida de imagen a Supabase Storage (Bucket: avatars)
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
            req.setAttribute("error", "No se pudo registrar el usuario. Comprueba si el correo ya existe.");
            req.getRequestDispatcher("registro.jsp").forward(req, resp);
        }
    }
}
