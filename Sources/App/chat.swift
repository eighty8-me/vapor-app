import Vapor

public class ChatRoom {
  // 接続中のWebSocketクライアント
  var clients = [WebSocket]()

  // WebSocketクライアントの接続ハンドラ
  func handler() -> ((WebSocket, Request) throws -> ()) {
    return { ws, req in
      // 接続中クライアントリストに追加
      self.clients.append(ws)
      // メッセージ受信時のハンドラを登録
      ws.onText(self.onText)
      // 切断時にクライアントリストから除去
      ws.onClose.always {
        self.clients = self.clients.filter { $0 === ws }
      }
    }
  }

  // WebSocketクライアントからのメッセージハンドラ
  private func onText(sender: WebSocket, text: String) -> () {
    // 送られたメッセージをそのまま全クライアントに送信する
    self.clients.forEach{ ws in
      if ws !== sender {
        ws.send("> \(text)")
      }
    }
  }
}