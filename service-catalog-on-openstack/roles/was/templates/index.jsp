<%@
 page import="java.util.*,javax.naming.*, java.sql.*, javax.sql.*" %>

<%
      // Declare the JDBC objects.
      DataSource ds = null;
      Connection con = null;
      Statement stmt = null;
      InitialContext ic;


      try {
        ic = new InitialContext();
        //ds = (DataSource) ic.lookup("java:/postgresDS");
        ds = (DataSource) ic.lookup("java:jboss/postgresDS");
        con = ds.getConnection();
        stmt = con.createStatement();
        ResultSet rs = stmt.executeQuery("select name from jbtest");

        while(rs.next()) {
                out.println("<br> " + rs.getString(1));
        }
        rs.close();
        stmt.close();
      } catch (Exception e) {
        out.println("Exception thrown :/");
        e.printStackTrace();
      } finally {
        if (con != null) {
                con.close();
        }
      }
%>
