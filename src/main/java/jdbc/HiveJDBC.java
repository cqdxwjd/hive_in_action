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
        FileReader reader = new FileReader("src/main/resources/wjd_field_type_info_tool.sql");
        BufferedReader bufferedReader = new BufferedReader(reader);
        String line = null;
        StringBuilder sb = new StringBuilder();
        while ((line = bufferedReader.readLine()) != null) {
            sb.append(line + "\n");
        }
//        stmt.execute(sb.toString());

        ResultSet resultSet = stmt.executeQuery("desc wjd_field_type_info_tool");


        while (resultSet.next()) {
            System.out.println(resultSet.getString(2));
        }
    }
}
