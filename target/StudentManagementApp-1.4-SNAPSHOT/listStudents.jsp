<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<html>
<head>
    <title>List of Students</title>
</head>
<body>

<h1>List of Students</h1>

<table border="1">
    <tr>
        <th>Name</th>
        <th>Email</th>
    </tr>

    <c:forEach var="student" items="${students}">
        <tr>
            <td>${student.name}</td>
            <td>${student.email}</td>
        </tr>
    </c:forEach>
</table>

<a href="student?action=new">Add New Student</a>

</body>
</html>
