<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
  ═══════════════════════════════════════════════════════════════════
   issue.jsp — Issue Book Form Page
   • HTML form that submits HTTP POST to IssueBookServlet (/issue)
   • Reads ?book_id= query param to pre-fill the form (from search page)
   • Shows success/error message after servlet redirects back here
  ═══════════════════════════════════════════════════════════════════
--%>
<%
    String prefillBookId = request.getParameter("book_id");
    String status  = request.getParameter("status");
    String message = request.getParameter("message");
    if (prefillBookId == null) prefillBookId = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Issue Book — Digital Library</title>
    <meta name="description" content="Issue a book from the Digital Library by entering Book ID and student name.">
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
        <li><a href="issue.jsp" class="active">Issue Book</a></li>
        <li><a href="return.jsp">Return Book</a></li>
    </ul>
</nav>

<div class="page-header">
    <div class="container">
        <div class="breadcrumb"><a href="index.jsp">Home</a> › Issue Book</div>
        <h1 class="page-title">📤 Issue a Book</h1>
        <p class="page-subtitle">
            Fill in the form below. The form submits a <strong>HTTP POST</strong> request
            to <code>IssueBookServlet</code>, which uses a <strong>JDBC Transaction</strong>
            to safely record the issuance.
        </p>
    </div>
</div>

<main class="section">
    <div class="container">
        <div class="form-layout">

            <!-- ── Status Message (after redirect) ── -->
            <% if (status != null && message != null) { %>
            <div class="alert <%= "success".equals(status) ? "alert-success" : "alert-error" %>"
                 id="statusAlert">
                <%= "success".equals(status) ? "✅" : "❌" %> <%= message %>
            </div>
            <% } %>

            <!-- ── Issue Book Form ── -->
            <div class="form-card">
                <div class="form-card-header">
                    <h2>Book Issuance Form</h2>
                    <p>Fields are submitted via HTTP POST to <code>/issue</code></p>
                </div>

                <!--
                  method="post" → IssueBookServlet.doPost() will handle this
                  action="issue" → mapped in web.xml to IssueBookServlet
                -->
                <form action="issue" method="post" id="issueForm" class="form-body">

                    <div class="form-group">
                        <label for="book_id">Book ID <span class="required">*</span></label>
                        <input type="number"
                               name="book_id"
                               id="book_id"
                               class="form-input"
                               placeholder="e.g. 1"
                               value="<%= prefillBookId %>"
                               min="1"
                               required>
                        <span class="form-hint">
                            Find Book IDs on the <a href="search?genre=Fiction">Search page</a>.
                        </span>
                    </div>

                    <div class="form-group">
                        <label for="student_name">Student Name <span class="required">*</span></label>
                        <input type="text"
                               name="student_name"
                               id="student_name"
                               class="form-input"
                               placeholder="e.g. Priya Sharma"
                               maxlength="100"
                               required>
                    </div>

                    <button type="submit" class="btn btn-primary btn-full" id="issueSubmitBtn">
                        📤 Issue Book
                    </button>
                </form>
            </div>

            <!-- ── Code Explanation Panel ── -->
            <div class="info-panel">
                <h3>⚙️ What happens when you submit?</h3>
                <ol class="flow-list">
                    <li>
                        <span class="flow-step">POST /issue</span>
                        Browser sends <code>book_id</code> + <code>student_name</code>
                        as POST body parameters.
                    </li>
                    <li>
                        <span class="flow-step">doPost()</span>
                        <code>IssueBookServlet.doPost()</code> reads them with
                        <code>request.getParameter()</code>.
                    </li>
                    <li>
                        <span class="flow-step">Transaction Start</span>
                        <code>con.setAutoCommit(false)</code> begins the transaction.
                    </li>
                    <li>
                        <span class="flow-step">SQL Step 1</span>
                        <code>UPDATE Books SET available_copies - 1</code>
                        where <code>available_copies &gt; 0</code>.
                    </li>
                    <li>
                        <span class="flow-step">SQL Step 2</span>
                        <code>INSERT INTO IssuedBooks</code> with today's date.
                    </li>
                    <li>
                        <span class="flow-step">Commit / Rollback</span>
                        If both succeed → <code>con.commit()</code>.
                        If either fails → <code>con.rollback()</code>.
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
