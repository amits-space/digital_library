package servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;

import java.io.*;
import java.sql.*;

/**
 * ═══════════════════════════════════════════════════════════════════
 *  ReturnBookServlet — Module 4 + Module 5 Demonstration
 *
 *  Concepts covered:
 *    • HTTP POST request handling via doPost()
 *    • Reading POST form parameters
 *    • JDBC Transaction wrapping two UPDATE statements:
 *        1. Set return_date in IssuedBooks
 *        2. Increment available_copies in Books
 *    • commit() / rollback() for atomicity
 * ═══════════════════════════════════════════════════════════════════
 */
public class ReturnBookServlet extends HttpServlet {

    private static final String DB_URL  = "jdbc:mysql://localhost:3306/digital_library";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC Driver not found!", e);
        }
    }

    /**
     * Handles HTTP POST requests: POST /return
     * Form field expected: issue_id
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Step 1: Read HTTP POST parameter ─────────────────────────────
        String issueIdStr = request.getParameter("issue_id");

        if (issueIdStr == null || issueIdStr.trim().isEmpty()) {
            sendResponse(response, false, "Invalid input: Issue ID is required.");
            return;
        }

        int issueId;
        try {
            issueId = Integer.parseInt(issueIdStr.trim());
        } catch (NumberFormatException e) {
            sendResponse(response, false, "Invalid Issue ID format.");
            return;
        }

        // ── Step 2: JDBC Transaction ──────────────────────────────────────
        Connection con = null;
        try {
            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            // TRANSACTION START
            con.setAutoCommit(false);

            /* ── First, look up the book_id for this issue record ─────── */
            int bookId = -1;
            String lookupSql = "SELECT book_id FROM IssuedBooks " +
                               "WHERE issue_id = ? AND return_date IS NULL";

            PreparedStatement psLookup = con.prepareStatement(lookupSql);
            psLookup.setInt(1, issueId);
            ResultSet rs = psLookup.executeQuery();

            if (rs.next()) {
                bookId = rs.getInt("book_id");
            }
            rs.close();
            psLookup.close();

            if (bookId == -1) {
                throw new Exception("Issue record not found or book already returned!");
            }

            /* ── SQL Step A: Mark the book as returned ────────────────── */
            String sql1 = "UPDATE IssuedBooks SET return_date = CURDATE() " +
                          "WHERE issue_id = ? AND return_date IS NULL";

            PreparedStatement ps1 = con.prepareStatement(sql1);
            ps1.setInt(1, issueId);
            int rows = ps1.executeUpdate();
            ps1.close();

            if (rows == 0) {
                throw new Exception("Could not update return date. Record may not exist.");
            }

            /* ── SQL Step B: Increment available copies ───────────────── */
            String sql2 = "UPDATE Books SET available_copies = available_copies + 1 " +
                          "WHERE book_id = ?";

            PreparedStatement ps2 = con.prepareStatement(sql2);
            ps2.setInt(1, bookId);
            ps2.executeUpdate();
            ps2.close();

            // COMMIT — both updates succeeded
            con.commit();

            sendResponse(response, true,
                "Book returned successfully! Issue ID: " + issueId);

        } catch (Exception e) {
            // ROLLBACK — undo both updates if anything went wrong
            try {
                if (con != null) con.rollback();
            } catch (SQLException rollbackEx) {
                rollbackEx.printStackTrace();
            }
            sendResponse(response, false, "Return failed: " + e.getMessage());

        } finally {
            try {
                if (con != null) con.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }

    /* ── Helper: redirect to return.jsp with a status message ── */
    private void sendResponse(HttpServletResponse response,
                               boolean success, String message)
            throws IOException {
        String encoded = java.net.URLEncoder.encode(message, "UTF-8");
        String status  = success ? "success" : "error";
        response.sendRedirect("return.jsp?status=" + status + "&message=" + encoded);
    }
}
