<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%--
  ═══════════════════════════════════════════════════════════════════
   index.jsp — Homepage  (Module 4: Cookie Reading Demo)

   Cookie Concept:
     • request.getCookies() returns all cookies sent by the browser.
     • We scan for the one named "lastGenre" (set by SearchServlet).
     • If found, we use its value to query books of that genre and
       show a personalised "Recommended for you" section.
     • If no cookie exists (first visit), we default to "Fiction".
  ═══════════════════════════════════════════════════════════════════
--%>
<%
    /* ── Module 4: Read the "lastGenre" Cookie ───────────────── */
    String lastGenre = "Fiction";   // default for first-time visitors
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie c : cookies) {
            if ("lastGenre".equals(c.getName())) {
                lastGenre = c.getValue();
                break;
            }
        }
    }

    /* ── Fetch recommended books from the database ──────────── */
    List<Map<String, Object>> recommendedBooks = new ArrayList<>();
    String dbUrl   = "jdbc:mysql://localhost:3306/digital_library";
    String dbUser  = "root";
    String dbPass  = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(dbUrl, dbUser, dbPass);
        PreparedStatement ps = con.prepareStatement(
            "SELECT book_id, title, author, available_copies " +
            "FROM Books WHERE genre = ? AND available_copies > 0 " +
            "ORDER BY title LIMIT 5"
        );
        ps.setString(1, lastGenre);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, Object> b = new LinkedHashMap<>();
            b.put("book_id",          rs.getInt("book_id"));
            b.put("title",            rs.getString("title"));
            b.put("author",           rs.getString("author"));
            b.put("available_copies", rs.getInt("available_copies"));
            recommendedBooks.add(b);
        }
        rs.close(); ps.close(); con.close();
    } catch (Exception ex) {
        /* silently ignore on homepage if DB not yet set up */
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Digital Library — Home</title>
    <meta name="description"
          content="BIS402 Digital Library Management System — search, issue and return books.">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
          rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<!-- ══════════════════  NAVBAR  ══════════════════════════════════ -->
<nav class="navbar">
    <div class="nav-brand">
        <span class="nav-icon">📚</span>
        <span>Digital Library</span>
    </div>
    <ul class="nav-links">
        <li><a href="index.jsp" class="active">Home</a></li>
        <li><a href="issue.jsp">Issue Book</a></li>
        <li><a href="return.jsp">Return Book</a></li>
    </ul>
</nav>

<!-- ══════════════════  HERO  ════════════════════════════════════ -->
<header class="hero">
    <div class="hero-content">
        <div class="hero-badge">BIS402 — Module 4 &amp; 5</div>
        <h1 class="hero-title">Digital Library<br><span class="gradient-text">Management System</span></h1>
        <p class="hero-subtitle">
            Search books, issue them to students, and manage returns — powered by
            Java Servlets, JDBC Transactions, and Cookies.
        </p>

        <!-- ── Genre Search Form → SearchServlet (GET) ── -->
        <form action="search" method="get" class="search-bar" id="searchForm">
            <select name="genre" id="genreSelect" class="genre-select">
                <option value="Fiction"    <%="Fiction".equals(lastGenre)    ? "selected" : ""%>>Fiction</option>
                <option value="Science"    <%="Science".equals(lastGenre)    ? "selected" : ""%>>Science</option>
                <option value="History"    <%="History".equals(lastGenre)    ? "selected" : ""%>>History</option>
                <option value="Technology" <%="Technology".equals(lastGenre) ? "selected" : ""%>>Technology</option>
                <option value="Business"   <%="Business".equals(lastGenre)   ? "selected" : ""%>>Business</option>
                <option value="Self-Help"  <%="Self-Help".equals(lastGenre)  ? "selected" : ""%>>Self-Help</option>
            </select>
            <button type="submit" class="btn btn-primary" id="searchBtn">
                🔍 Search Books
            </button>
        </form>
    </div>
    <div class="hero-decoration">
        <div class="floating-card card-1">📖</div>
        <div class="floating-card card-2">🎓</div>
        <div class="floating-card card-3">✨</div>
    </div>
</header>

<!-- ══════════════════  COOKIE RECOMMENDATION  ═══════════════════ -->
<section class="section">
    <div class="container">
        <div class="recommendation-banner">
            <div class="rec-icon">🍪</div>
            <div class="rec-text">
                <h2 class="rec-title">Recommended for you:
                    <span class="genre-badge"><%= lastGenre %></span> books
                </h2>
                <p class="rec-subtitle">
                    Based on your last search (stored in a <strong>Cookie</strong>
                    named <code>lastGenre</code>).
                    <% if (cookies == null || recommendedBooks.isEmpty()) { %>
                        This is your first visit — showing default genre.
                    <% } %>
                </p>
            </div>
        </div>

        <!-- Recommended book cards -->
        <% if (!recommendedBooks.isEmpty()) { %>
        <div class="book-grid">
            <% for (Map<String, Object> book : recommendedBooks) { %>
            <div class="book-card">
                <div class="book-cover">📚</div>
                <div class="book-info">
                    <h3 class="book-title"><%= book.get("title") %></h3>
                    <p class="book-author">by <%= book.get("author") %></p>
                    <div class="book-meta">
                        <span class="genre-tag"><%= lastGenre %></span>
                        <span class="copies-tag">
                            <%= book.get("available_copies") %> available
                        </span>
                    </div>
                    <a href="issue.jsp?book_id=<%= book.get("book_id") %>"
                       class="btn btn-sm" id="issue-<%= book.get("book_id") %>">
                        Issue This Book
                    </a>
                </div>
            </div>
            <% } %>
        </div>
        <% } else { %>
        <div class="empty-state">
            <p>No available books found for <strong><%= lastGenre %></strong>.
               Try a different genre above!</p>
        </div>
        <% } %>
    </div>
</section>

<!-- ══════════════════  QUICK ACTIONS  ══════════════════════════ -->
<section class="section section-dark">
    <div class="container">
        <h2 class="section-title">Quick Actions</h2>
        <div class="action-grid">
            <a href="issue.jsp" class="action-card" id="quickIssue">
                <div class="action-icon">📤</div>
                <h3>Issue a Book</h3>
                <p>Enter Book ID and student name to borrow a book.</p>
            </a>
            <a href="return.jsp" class="action-card" id="quickReturn">
                <div class="action-icon">📥</div>
                <h3>Return a Book</h3>
                <p>Enter the Issue ID to mark a book as returned.</p>
            </a>
            <a href="search?genre=<%= lastGenre %>" class="action-card" id="quickSearch">
                <div class="action-icon">🔍</div>
                <h3>Search Catalogue</h3>
                <p>Browse books by genre using HTTP GET request.</p>
            </a>
        </div>
    </div>
</section>

<!-- ══════════════════  CONCEPT BADGES  ═════════════════════════ -->
<section class="section">
    <div class="container">
        <h2 class="section-title">Concepts Demonstrated</h2>
        <div class="concept-grid">
            <div class="concept-card">
                <span class="concept-tag tag-module4">Module 4</span>
                <h4>doGet Servlet</h4>
                <p>SearchServlet handles HTTP GET with query parameters.</p>
            </div>
            <div class="concept-card">
                <span class="concept-tag tag-module4">Module 4</span>
                <h4>doPost Servlet</h4>
                <p>IssueBookServlet &amp; ReturnBookServlet handle HTTP POST.</p>
            </div>
            <div class="concept-card">
                <span class="concept-tag tag-module4">Module 4</span>
                <h4>Cookies</h4>
                <p>Set in SearchServlet; read here to personalise results.</p>
            </div>
            <div class="concept-card">
                <span class="concept-tag tag-module5">Module 5</span>
                <h4>JDBC Connection</h4>
                <p>DriverManager.getConnection() to MySQL database.</p>
            </div>
            <div class="concept-card">
                <span class="concept-tag tag-module5">Module 5</span>
                <h4>PreparedStatement</h4>
                <p>Prevents SQL injection; used in all three servlets.</p>
            </div>
            <div class="concept-card">
                <span class="concept-tag tag-module5">Module 5</span>
                <h4>Transaction Processing</h4>
                <p>commit() / rollback() ensure atomic multi-step operations.</p>
            </div>
        </div>
    </div>
</section>

<footer class="footer">
    <p>Digital Library Management System &copy; 2024 — BIS402 Module 4 &amp; 5 Project</p>
</footer>

<script src="js/main.js"></script>
</body>
</html>
