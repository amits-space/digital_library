# 📚 Digital Library Management System
**BIS402 — Module 4 & 5 Project**

A Java Web Application demonstrating **Servlets**, **Cookies**, **JDBC**, and **Transaction Processing**.

---

## 🗂️ Project Structure

```
DigitalLibrary/
├── database/
│   └── schema.sql                  ← Run this first in MySQL
├── src/
│   └── servlets/
│       ├── SearchServlet.java      ← doGet + Cookie + JDBC
│       ├── IssueBookServlet.java   ← doPost + JDBC Transaction
│       └── ReturnBookServlet.java  ← doPost + JDBC Transaction
├── WebContent/
│   ├── index.jsp                   ← Homepage + Cookie reading
│   ├── search.jsp                  ← Search results
│   ├── issue.jsp                   ← Issue book form
│   ├── return.jsp                  ← Return book form
│   ├── css/style.css
│   └── js/main.js
├── WEB-INF/
│   └── web.xml                     ← Servlet URL mappings
└── pom.xml                         ← Maven build (optional)
```

---

## ⚙️ Setup Instructions

### Step 1 — Database

1. Open **MySQL Workbench** (or any MySQL client).
2. Run the SQL file: `database/schema.sql`
3. This creates the `digital_library` database, both tables, and sample data.

### Step 2 — Configure DB Credentials

In each servlet, update these constants if your MySQL uses different credentials:

```java
private static final String DB_URL  = "jdbc:mysql://localhost:3306/digital_library";
private static final String DB_USER = "root";      // ← your MySQL username
private static final String DB_PASS = "password";  // ← your MySQL password
```

Also update the credentials in `index.jsp` (the scriptlet block at the top).

### Step 3 — Add the MySQL JAR (if not using Maven)

Download **mysql-connector-j-8.x.x.jar** from [dev.mysql.com](https://dev.mysql.com/downloads/connector/j/)
and place it in `WEB-INF/lib/`.

### Step 4 — Deploy to Tomcat

**Option A — Eclipse/IntelliJ:**
1. Import as a **Dynamic Web Project** or **Maven Project**.
2. Right-click → **Run on Server** → select your **Tomcat 10** instance.

**Option B — Manual WAR:**
```
# Build WAR (requires Maven)
mvn clean package

# Copy to Tomcat webapps
copy target\DigitalLibrary.war C:\tomcat\webapps\
```

### Step 5 — Open in Browser

```
http://localhost:8080/DigitalLibrary/
```

---

## 🌐 URL Reference

| URL | Method | Servlet | Description |
|-----|--------|---------|-------------|
| `/` | GET | index.jsp | Homepage — reads `lastGenre` cookie |
| `/search?genre=Fiction` | GET | SearchServlet | Search by genre, sets cookie |
| `/issue` | POST | IssueBookServlet | Issue a book (JDBC transaction) |
| `/return` | POST | ReturnBookServlet | Return a book (JDBC transaction) |

---

## ✅ BIS402 Concepts Checklist

| Concept | Implementation |
|---------|---------------|
| `doGet` Servlet | `SearchServlet.java` |
| `doPost` Servlet | `IssueBookServlet.java`, `ReturnBookServlet.java` |
| `request.getParameter()` | All three servlets |
| Cookie (set) | `SearchServlet` — saves `lastGenre` |
| Cookie (read) | `index.jsp` — shows personalised recommendations |
| `RequestDispatcher.forward()` | `SearchServlet` → `search.jsp` |
| JDBC `DriverManager.getConnection()` | All three servlets |
| `PreparedStatement` | All SQL queries (prevents SQL injection) |
| `setAutoCommit(false)` | `IssueBookServlet`, `ReturnBookServlet` |
| `commit()` | On successful multi-step operations |
| `rollback()` | On any failure — keeps DB consistent |

---

## 🔁 Request Flow Diagram

```
index.jsp
  └─ Cookie read → "lastGenre" → show recommended books

GET /search?genre=Fiction
  └─ SearchServlet.doGet()
        ├─ PreparedStatement → SELECT from Books
        ├─ Cookie set: lastGenre = "Fiction" (1 day)
        └─ RequestDispatcher.forward() → search.jsp

POST /issue  (book_id, student_name)
  └─ IssueBookServlet.doPost()
        └─ JDBC TRANSACTION
              ├─ setAutoCommit(false)
              ├─ UPDATE Books SET copies - 1  (where copies > 0)
              ├─ INSERT IssuedBooks ...
              └─ commit()  or  rollback()

POST /return  (issue_id)
  └─ ReturnBookServlet.doPost()
        └─ JDBC TRANSACTION
              ├─ setAutoCommit(false)
              ├─ UPDATE IssuedBooks SET return_date = CURDATE()
              ├─ UPDATE Books SET copies + 1
              └─ commit()  or  rollback()
```

---

## 💡 Why Transactions Matter (Exam Answer)

> In `IssueBookServlet`, if Step 1 (decrement book copies) **succeeds** but  
> Step 2 (insert issuance record) **fails**, the `rollback()` call **undoes Step 1** too.  
> Without a transaction, the book count would be permanently decremented  
> with no corresponding issuance record — leaving the database in an **inconsistent state**.  
> Transactions guarantee **Atomicity**: either ALL steps succeed, or NONE of them do.

---

*Digital Library Management System — BIS402 Module 4 & 5*
