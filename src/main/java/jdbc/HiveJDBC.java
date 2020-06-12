package jdbc;

import java.io.*;
import java.sql.*;

public class HiveJDBC {
    private static String driverName = "org.apache.hive.jdbc.HiveDriver";
    private static String url = "jdbc:hive2://10.60.7.11:10000/dsep";
    private static String user = "admin";
    private static String password = "admin";

    private static Connection conn = null;
    private static Statement stmt = null;
    private static ResultSet rs = null;

    static {
        try {
            Class.forName(driverName);
            conn = DriverManager.getConnection(url, user, password);
            stmt = conn.createStatement();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) throws SQLException, IOException {
        String header = "CREATE TABLE dsep.wjd_field_type_info_tool AS";

        FileReader reader = new FileReader("src/main/resources/wjd_field_type_info_tool.sql");
        BufferedReader bufferedReader = new BufferedReader(reader);
        String line = null;
        StringBuilder sb = new StringBuilder();
        sb.append(header + "\n");
        while ((line = bufferedReader.readLine()) != null) {
            sb.append(line + "\n");
        }
        sb.append("limit 1");
        try {
            stmt.execute("show create table dsep.wjd_field_type_info_tool");
        } catch (Exception e) {
            if (e == null) {
                stmt.execute("drop table dsep.wjd_field_type_info_tool");
            }
        }

        stmt.execute(sb.toString());

        ResultSet resultSet = stmt.executeQuery("desc wjd_field_type_info_tool");


        while (resultSet.next()) {
            if (resultSet.getString(2).equals("timestamp")) {
                System.out.println("string");
            } else {
                System.out.println(resultSet.getString(2));
            }
        }

        stmt.close();
        conn.close();
    }
}
