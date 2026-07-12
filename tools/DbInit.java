import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

/**
 * スキーマSQLをHSQLDBサーバに適用する初期化ツール（アプリ本体とは独立）。
 * 使い方: java -cp bin:lib/hsqldb.jar DbInit db/schema.sql
 */
public class DbInit {
	public static void main(String[] args) throws Exception {
		String schemaPath = args.length > 0 ? args[0] : "db/schema.sql";
		String raw = new String(Files.readAllBytes(Paths.get(schemaPath)), StandardCharsets.UTF_8);

		// 行頭コメント（--）を除去してから ; で分割
		StringBuilder sb = new StringBuilder();
		for (String line : raw.split("\n")) {
			if (line.trim().startsWith("--")) continue;
			sb.append(line).append("\n");
		}

		Class.forName("org.hsqldb.jdbcDriver");
		try (Connection con = DriverManager.getConnection("jdbc:hsqldb:hsql://localhost", "sa", "");
		     Statement st = con.createStatement()) {
			int n = 0;
			for (String stmt : sb.toString().split(";")) {
				String s = stmt.trim();
				if (s.isEmpty()) continue;
				st.execute(s);
				n++;
			}
			System.out.println("DB初期化完了: " + n + " 文を実行 (" + schemaPath + ")");
		}
	}
}
