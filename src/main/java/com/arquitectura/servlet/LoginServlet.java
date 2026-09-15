package com.arquitectura.servlet;

import com.arquitectura.config.DBConfig;
import com.arquitectura.model.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

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
                req.setAttribute("error", "Credenciales incorrectas.");
                req.getRequestDispatcher("index.jsp").forward(req, resp);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Error al conectar con la base de datos.");
            req.getRequestDispatcher("index.jsp").forward(req, resp);
        }
    }
}
