<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
  ═══════════════════════════════════════════════════════════════════
   return.jsp — Return Book Form Page
   • HTML form that submits HTTP POST to ReturnBookServlet (/return)
   • Shows success/error after servlet redirects back here
  ═══════════════════════════════════════════════════════════════════
--%>
<%
    String status  = request.getParameter("status");
    String message = request.getParameter("message");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Return Book — Digital Library</title>
    <meta name="description" content="Return an issued book to the Digital Library using the Issue ID.">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
          rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<nav class="navbar">
    <div class="nav-brand">
        <span class="nav-icon">📚</span>
        <span>Digital Library</span>
    </div>
    <ul class="nav-links">
        <li><a href="index.jsp">Home</a></li>
        <li><a href="issue.jsp">Issue Book</a></li>
        <li><a href="return.jsp" class="active">Return Book</a></li>
    </ul>
</nav>

<div class="page-header">
    <div class="container">
        <div class="breadcrumb"><a href="index.jsp">Home</a> › Return Book</div>
        <h1 class="page-title">📥 Return a Book</h1>
        <p class="page-subtitle">
            Enter the <strong>Issue ID</strong> from the issuance record. The servlet
            uses a <strong>JDBC Transaction</strong> to update both tables atomically.
        </p>
    </div>
</div>

<main class="section">
    <div class="container">
        <div class="form-layout">

            <!-- ── Status Message ── -->
            <% if (status != null && message != null) { %>
            <div class="alert <%= "success".equals(status) ? "alert-success" : "alert-error" %>"
                 id="returnStatusAlert">
                <%= "success".equals(status) ? "✅" : "❌" %> <%= message %>
            </div>
            <% } %>

            <!-- ── Return Book Form ── -->
            <div class="form-card">
                <div class="form-card-header">
                    <h2>Book Return Form</h2>
                    <p>Submits HTTP POST to <code>/return</code></p>
                </div>

                <!--
                  method="post" → ReturnBookServlet.doPost() handles this
                  action="return" → mapped in web.xml to ReturnBookServlet
                -->
                <form action="return" method="post" id="returnForm" class="form-body">

                    <div class="form-group">
                        <label for="issue_id">Issue ID <span class="required">*</span></label>
                        <input type="number"
                               name="issue_id"
                               id="issue_id"
                               class="form-input"
                               placeholder="e.g. 1"
                               min="1"
                               required>
                        <span class="form-hint">
                            The Issue ID was assigned when the book was borrowed.
                            Check the <code>IssuedBooks</code> table in your database.
                        </span>
                    </div>

                    <button type="submit" class="btn btn-primary btn-full" id="returnSubmitBtn">
                        📥 Return Book
                    </button>
                </form>
            </div>

            <!-- ── Code Explanation Panel ── -->
            <div class="info-panel">
                <h3>⚙️ What happens when you submit?</h3>
                <ol class="flow-list">
                    <li>
                        <span class="flow-step">POST /return</span>
                        Browser sends <code>issue_id</code> as a POST body parameter.
                    </li>
                    <li>
                        <span class="flow-step">doPost()</span>
                        <code>ReturnBookServlet.doPost()</code> reads it with
                        <code>request.getParameter("issue_id")</code>.
                    </li>
                    <li>
                        <span class="flow-step">Lookup</span>
                        Queries <code>IssuedBooks</code> to find the <code>book_id</code>
                        for this issue (ensures book is actually on loan).
                    </li>
                    <li>
                        <span class="flow-step">Transaction Start</span>
                        <code>con.setAutoCommit(false)</code>.
                    </li>
                    <li>
                        <span class="flow-step">SQL Step 1</span>
                        <code>UPDATE IssuedBooks SET return_date = CURDATE()</code>.
                    </li>
                    <li>
                        <span class="flow-step">SQL Step 2</span>
                        <code>UPDATE Books SET available_copies + 1</code>.
                    </li>
                    <li>
                        <span class="flow-step">Commit / Rollback</span>
                        Both succeed → <code>commit()</code>.
                        Either fails → <code>rollback()</code> keeps DB consistent.
                    </li>
                </ol>
            </div>

        </div>
    </div>
</main>

<footer class="footer">
    <p>Digital Library Management System &copy; 2024 — BIS402 Module 4 &amp; 5 Project</p>
</footer>
<script src="js/main.js"></script>
</body>
</html>
