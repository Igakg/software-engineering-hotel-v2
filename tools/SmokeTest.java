import java.util.Date;

import util.DateUtil;
import app.reservation.ReserveRoomForm;
import app.checkin.CheckInRoomForm;
import app.checkout.CheckOutRoomForm;
import app.AppException;

/**
 * 最小要件（予約→チェックイン→チェックアウト）の結合テスト。
 * Form を直接駆動し、通しで例外なく完了することを確認する。
 * 事前に HSQLDBサーバ起動 + DbInit 済みであること。
 */
public class SmokeTest {
	public static void main(String[] args) throws Exception {
		Date stayingDate = DateUtil.createDate(2026, 6, 1); // month は0始まり → 6=7月, 2026/07/01

		// 1. 予約（状態: 未利用 で作成）
		ReserveRoomForm reserveForm = new ReserveRoomForm();
		reserveForm.setStayingDate(stayingDate);
		String reservationNumber = reserveForm.submitReservation();
		System.out.println("[予約] 予約番号 = " + reservationNumber);

		// 2. チェックイン（予約: 未利用→利用済 / 部屋: 不在→在室 / 料金: 未精算を計上）
		CheckInRoomForm checkInForm = new CheckInRoomForm();
		checkInForm.setReservationNumber(reservationNumber);
		String roomNumber = checkInForm.checkIn();
		System.out.println("[チェックイン] 割当部屋 = " + roomNumber);

		// 3. チェックアウト（部屋: 在室→不在 / 料金: 未精算→精算済）
		CheckOutRoomForm checkOutForm = new CheckOutRoomForm();
		checkOutForm.setRoomNumber(roomNumber);
		checkOutForm.checkOut();
		System.out.println("[チェックアウト] 完了");

		// 4. 二重チェックアウトは失敗すること（料金が精算済＝consume のため）
		try {
			CheckOutRoomForm again = new CheckOutRoomForm();
			again.setRoomNumber(roomNumber);
			again.checkOut();
			System.out.println("[NG] 二重チェックアウトが成功してしまった");
		}
		catch (AppException e) {
			System.out.println("[想定どおり] 二重チェックアウトは拒否された");
		}

		System.out.println("SmokeTest: 全工程 OK");
	}
}
