<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%--
  ═══════════════════════════════════════════════════════════════════
   search.jsp — Search Results Page
   Data arrives via request attributes set by SearchServlet.doGet()
  ═══════════════════════════════════════════════════════════════════
--%>
<%
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> books =
        (List<Map<String, Object>>) request.getAttribute("books");
    String searchedGenre = (String)  request.getAttribute("searchedGenre");
    String errorMessage  = (String)  request.getAttribute("errorMessage");

    if (books == null)        books = new ArrayList<>();
    if (searchedGenre == null) searchedGenre = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Results — Digital Library</title>
    <meta name="description" content="Search results for <%= searchedGenre %> books in the Digital Library.">
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
        <li><a href="return.jsp">Return Book</a></li>
    </ul>
</nav>

<div class="page-header">
    <div class="container">
        <div class="breadcrumb">
            <a href="index.jsp">Home</a> › Search Results
        </div>
        <h1 class="page-title">
            Search Results
            <span class="genre-badge"><%= searchedGenre %></span>
        </h1>
        <p class="page-subtitle">
            Showing available books in the <strong><%= searchedGenre %></strong> genre.
            A <code>lastGenre</code> cookie has been set to remember your preference.
        </p>

        <!-- New search from this page -->
        <form action="search" method="get" class="search-bar search-bar-sm" id="reSearchForm">
            <select name="genre" id="reGenreSelect" class="genre-select">
                <option value="Fiction"    <%="Fiction".equals(searchedGenre)    ? "selected" : ""%>>Fiction</option>
                <option value="Science"    <%="Science".equals(searchedGenre)    ? "selected" : ""%>>Science</option>
                <option value="History"    <%="History".equals(searchedGenre)    ? "selected" : ""%>>History</option>
                <option value="Technology" <%="Technology".equals(searchedGenre) ? "selected" : ""%>>Technology</option>
                <option value="Business"   <%="Business".equals(searchedGenre)   ? "selected" : ""%>>Business</option>
                <option value="Self-Help"  <%="Self-Help".equals(searchedGenre)  ? "selected" : ""%>>Self-Help</option>
            </select>
            <button type="submit" class="btn btn-primary" id="reSearchBtn">🔍 Search Again</button>
        </form>
    </div>
</div>

<main class="section">
    <div class="container">

        <!-- Error display -->
        <% if (errorMessage != null) { %>
        <div class="alert alert-error" id="errorAlert">
            ⚠️ <%= errorMessage %>
        </div>
        <% } %>

        <!-- Cookie info banner -->
        <div class="info-banner">
            <span class="info-icon">🍪</span>
            <span>
                Cookie <code>lastGenre = "<%= searchedGenre %>"</code> has been set
                (expires in 1 day). Visit the <a href="index.jsp">homepage</a> to see it in action.
            </span>
        </div>

        <!-- Results count -->
        <p class="results-count">
            Found <strong><%= books.size() %></strong> available book<%= books.size() != 1 ? "s" : ""%>
        </p>

        <!-- Book results -->
        <% if (!books.isEmpty()) { %>
        <div class="results-table-wrapper">
            <table class="results-table" id="resultsTable">
                <thead>
                    <tr>
                        <th>Book ID</th>
                        <th>Title</th>
                        <th>Author</th>
                        <th>Genre</th>
                        <th>Available Copies</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Map<String, Object> book : books) { %>
                    <tr>
                        <td><span class="book-id-badge">#<%= book.get("book_id") %></span></td>
                        <td class="book-title-cell"><%= book.get("title") %></td>
                        <td class="book-author-cell">by <%= book.get("author") %></td>
                        <td><span class="genre-tag"><%= book.get("genre") %></span></td>
                        <td>
                            <span class="copies-indicator
                                <%= ((Integer)book.get("available_copies")) > 2 ? "copies-good" : "copies-low" %>">
                                <%= book.get("available_copies") %>
                            </span>
                        </td>
                        <td>
                            <a href="issue.jsp?book_id=<%= book.get("book_id") %>"
                               class="btn btn-sm btn-issue"
                               id="issue-book-<%= book.get("book_id") %>">
                                📤 Issue
                            </a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } else if (errorMessage == null) { %>
        <div class="empty-state">
            <div class="empty-icon">📭</div>
            <h3>No books found</h3>
            <p>No available books in the <strong><%= searchedGenre %></strong> genre right now.</p>
            <a href="index.jsp" class="btn btn-primary" id="backHomeBtn">← Back to Home</a>
        </div>
        <% } %>
    </div>
</main>

<footer class="footer">
    <p>Digital Library Management System &copy; 2024 — BIS402 Module 4 &amp; 5 Project</p>
</footer>
<script src="js/main.js"></script>
</body>
</html>
