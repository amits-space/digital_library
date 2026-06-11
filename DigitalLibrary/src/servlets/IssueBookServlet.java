package servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;

import java.io.*;
import java.sql.*;

/**
 * ═══════════════════════════════════════════════════════════════════
 *  IssueBookServlet — Module 4 + Module 5 Demonstration
 *
 *  Concepts covered:
 *    • HTTP POST request handling via doPost()
 *    • Reading POST form parameters with request.getParameter()
 *    • JDBC Transaction Processing:
 *        con.setAutoCommit(false)  → start transaction
 *        con.commit()              → commit both SQL operations atomically
 *        con.rollback()            → undo everything if any step fails
 *    • PreparedStatement for secure, parameterised SQL
 * ═══════════════════════════════════════════════════════════════════
 *
 *  WHY the transaction matters (exam answer):
 *    If Step 1 (decrement copies) succeeds but Step 2 (insert record)
 *    fails, rollback() undoes Step 1 — so the database stays consistent.
 *    Without a transaction, we could lose a book copy with no issuance
 *    record, leaving the database in a corrupt state.
 */
public class IssueBookServlet extends HttpServlet {

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
     * Handles HTTP POST requests: POST /issue
     * Form fields expected: book_id, student_name
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Step 1: Read HTTP POST parameters ────────────────────────────
        String bookIdStr    = request.getParameter("book_id");
        String studentName  = request.getParameter("student_name");

        // Basic input validation
        if (bookIdStr == null || studentName == null ||
            bookIdStr.trim().isEmpty() || studentName.trim().isEmpty()) {
            sendResponse(response, false, "Invalid input: Book ID and Student Name are required.");
            return;
        }

        int bookId;
        try {
            bookId = Integer.parseInt(bookIdStr.trim());
        } catch (NumberFormatException e) {
            sendResponse(response, false, "Invalid Book ID format.");
            return;
        }
        studentName = studentName.trim();

        // ── Step 2: JDBC Transaction ──────────────────────────────────────
        Connection con = null;
        try {
            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            /*
             *  ┌─────────────────────────────────────────────────────┐
             *  │  TRANSACTION START                                   │
             *  │  setAutoCommit(false) disables auto-commit mode.     │
             *  │  Every SQL statement from here is part of one unit   │
             *  │  of work — either ALL succeed or ALL are rolled back. │
             *  └─────────────────────────────────────────────────────┘
             */
            con.setAutoCommit(false);

            /* ── SQL Step A: Decrement available copies ───────────── */
            /*
             * The WHERE clause "AND available_copies > 0" acts as a guard.
             * If the book is already out of stock, rows == 0 and we throw
             * an exception — no partial changes are committed.
             */
            String sql1 = "UPDATE Books " +
                          "SET available_copies = available_copies - 1 " +
                          "WHERE book_id = ? AND available_copies > 0";

            PreparedStatement ps1 = con.prepareStatement(sql1);
            ps1.setInt(1, bookId);
            int rowsUpdated = ps1.executeUpdate();
            ps1.close();

            if (rowsUpdated == 0) {
                // Book not available — trigger rollback path
                throw new Exception("Book not available or Book ID does not exist!");
            }

            /* ── SQL Step B: Insert issuance record ───────────────── */
            String sql2 = "INSERT INTO IssuedBooks (book_id, student_name, issue_date) " +
                          "VALUES (?, ?, CURDATE())";

            PreparedStatement ps2 = con.prepareStatement(sql2);
            ps2.setInt(1, bookId);
            ps2.setString(2, studentName);
            ps2.executeUpdate();
            ps2.close();

            /*
             *  ┌─────────────────────────────────────────────────────┐
             *  │  COMMIT                                              │
             *  │  Both SQL statements succeeded — persist changes.    │
             *  └─────────────────────────────────────────────────────┘
             */
            con.commit();

            sendResponse(response, true,
                "Book issued successfully to " + studentName + "!");

        } catch (Exception e) {
            /*
             *  ┌─────────────────────────────────────────────────────┐
             *  │  ROLLBACK                                            │
             *  │  Something went wrong — undo ALL changes made        │
             *  │  in this transaction so the DB stays consistent.     │
             *  └─────────────────────────────────────────────────────┘
             */
            try {
                if (con != null) con.rollback();
            } catch (SQLException rollbackEx) {
                rollbackEx.printStackTrace();
            }
            sendResponse(response, false, "Issue failed: " + e.getMessage());

        } finally {
            // Always close the connection in finally block
            try {
                if (con != null) con.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }

    /* ── Helper: redirect to issue.jsp with a status message ── */
    private void sendResponse(HttpServletResponse response,
                               boolean success, String message)
            throws IOException {
        String encoded = java.net.URLEncoder.encode(message, "UTF-8");
        String status  = success ? "success" : "error";
        response.sendRedirect("issue.jsp?status=" + status + "&message=" + encoded);
    }
}
