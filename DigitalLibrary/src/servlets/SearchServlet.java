package servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

import java.io.*;
import java.sql.*;
import java.util.*;

/**
 * ═══════════════════════════════════════════════════════════════════
 *  SearchServlet — Module 4 Demonstration
 *
 *  Concepts covered:
 *    • HTTP GET request handling via doGet()
 *    • Reading URL query parameters with request.getParameter()
 *    • Creating & setting a Cookie (lastGenre, expires in 1 day)
 *    • JDBC: DriverManager, PreparedStatement, ResultSet
 *    • Forwarding result data to a JSP via RequestDispatcher
 * ═══════════════════════════════════════════════════════════════════
 */
public class SearchServlet extends HttpServlet {

    /* ── Database connection constants ── */
    private static final String DB_URL = "jdbc:mysql://localhost:3306/digital_library";
    private static final String DB_USER = "root";       // ← change if needed
    private static final String DB_PASS = "";           // root has no password

    static {
        try {
            // Load the MySQL JDBC driver once when the class is loaded
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC Driver not found!", e);
        }
    }

    /**
     * Handles HTTP GET requests: GET /search?genre=Fiction
     *
     * Flow:
     *   1. Read the "genre" query parameter from the URL
     *   2. Query Books table for available books in that genre
     *   3. Set a "lastGenre" Cookie so index.jsp can recommend it later
     *   4. Store results as a request attribute and forward to search.jsp
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Step 1: Read HTTP GET parameter ──────────────────────────────
        String genre = request.getParameter("genre");
        if (genre == null || genre.trim().isEmpty()) {
            genre = "Fiction";   // sensible default
        }
        genre = genre.trim();

        // ── Step 2: JDBC — query the database ────────────────────────────
        List<Map<String, Object>> books = new ArrayList<>();
        String errorMessage = null;

        try (Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

            /*
             * PreparedStatement prevents SQL Injection:
             *   – The "?" placeholder is filled with a sanitised value.
             *   – Never concatenate user input directly into SQL strings!
             */
            String sql = "SELECT book_id, title, author, genre, available_copies " +
                         "FROM Books WHERE genre = ? AND available_copies > 0 " +
                         "ORDER BY title";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, genre);                   // bind the genre parameter
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> book = new LinkedHashMap<>();
                        book.put("book_id",          rs.getInt("book_id"));
                        book.put("title",            rs.getString("title"));
                        book.put("author",           rs.getString("author"));
                        book.put("genre",            rs.getString("genre"));
                        book.put("available_copies", rs.getInt("available_copies"));
                        books.add(book);
                    }
                }
            }

        } catch (SQLException e) {
            errorMessage = "Database error: " + e.getMessage();
            e.printStackTrace();
        }

        // ── Step 3: Set the "lastGenre" Cookie ───────────────────────────
        /*
         *  Cookie API (Module 4):
         *    new Cookie(name, value)  — creates the cookie object
         *    setMaxAge(seconds)       — 86400 s = 1 day; -1 = session only
         *    response.addCookie(c)   — sends Set-Cookie header to browser
         */
        Cookie genreCookie = new Cookie("lastGenre", genre);
        genreCookie.setMaxAge(86400);   // persist for 1 day
        genreCookie.setPath("/");       // accessible across the whole app
        response.addCookie(genreCookie);

        // ── Step 4: Forward to search.jsp via RequestDispatcher ──────────
        request.setAttribute("books",        books);
        request.setAttribute("searchedGenre", genre);
        request.setAttribute("errorMessage", errorMessage);

        RequestDispatcher rd = request.getRequestDispatcher("/search.jsp");
        rd.forward(request, response);
    }
}
