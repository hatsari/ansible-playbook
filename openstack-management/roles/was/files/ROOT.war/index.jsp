<%
DataSource ds = null;
Connection con = null;
Statement stmt = null;
InitialContext ic;

try {
	ic = new InitialContext();
	ds = (DataSource) ic.lookup("java:/SampleDS");

	con = ds.getConnection();
	stmt = con.createStatement();

	ResultSet rs = stmt.executeQuery("select * from login");
	while (rs.next()) {
		out.println("<br> " + rs.getString("username") + " | "
				+ rs.getString("password"));
	}

	rs.close();
	stmt.close();
} catch (Exception e) {
	out.println("Exception thrown ");
	e.printStackTrace();
} finally {
	if (con != null) {
		con.close();
	}
}

%>
