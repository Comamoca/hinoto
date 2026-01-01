# 実装計画

## タスク概要

このドキュメントは、flexible-body-types機能の実装タスクを定義します。全てのタスクは要件と設計ドキュメントに基づいており、段階的に機能を構築していきます。

## 実装タスク

- [ ] 1. Body型の基盤を構築する
- [ ] 1.1 Gleam側でBody型を定義する
  - カスタム型でStringBody、BitArrayBody、BlobBody等の9種類のバリアントを定義
  - 各JavaScript型に対応するOpaque型（JsBlob、JsArrayBuffer等）を定義
  - 型パラメータを使ってRequest/Response型との統合を準備
  - _Requirements: 4.1, 4.2, 4.4_

- [ ] 1.2 Body型のヘルパー関数を実装する
  - Body型のバリアントを生成するコンストラクタ関数を実装
  - Body型のパターンマッチング用のヘルパー関数を実装
  - 型変換ユーティリティ関数を実装
  - _Requirements: 4.1, 4.2_

- [ ] 2. FFI変換レイヤーでbody型判別機能を実装する
- [ ] 2.1 JavaScript側でbody型を判別する関数を実装する
  - instanceof演算子を使ってbody型を判別するロジックを実装
  - 各body型（String、Blob、ArrayBuffer等）を適切なバリアントに変換
  - nullを EmptyBodyに変換
  - サポートされていない型を検出してエラーを返す
  - _Requirements: 1.1-1.9, 6.2, 6.3_

- [ ] 2.2 Requestボディの非同期読み取り機能を実装する
  - JavaScript Requestのbodyプロパティを非同期で読み取る
  - 各body型に適した読み取りメソッド（text()、arrayBuffer()等）を使用
  - 読み取りエラーを適切にハンドリング
  - Promiseで結果を返す
  - _Requirements: 1.1-1.9, 6.1, 6.4_

- [ ] 3. Node.jsランタイムでbody型変換を実装する
- [ ] 3.1 toGleamRequest関数を拡張してbody型判別を統合する
  - 既存のtoGleamRequest関数でbody型判別関数を呼び出す
  - 判別されたBody型をGleam Requestオブジェクトに設定
  - エラーハンドリングを実装
  - _Requirements: 1.1-1.9, 3.1_

- [ ] 3.2 toNodeResponse関数を拡張してBody型をサポートする
  - Gleam ResponseのBody型をパターンマッチで判別
  - 各バリアントをJavaScript Response bodyに変換
  - EmptyBodyをnullに変換
  - Response constructorに適切なbodyを渡す
  - _Requirements: 2.1-2.9, 3.1_

- [ ] 4. Denoランタイムでbody型変換を実装する
- [ ] 4.1 Denoランタイム用のbody型判別ロジックを実装する
  - Node.jsと同じbody型判別ロジックをDenoランタイム用FFIに実装
  - Deno固有のAPI互換性を確認
  - _Requirements: 1.1-1.9, 3.2_

- [ ] 4.2 Denoランタイム用のRequest/Response変換を実装する
  - toGleamRequest関数でbody型判別を統合
  - toDenoResponse関数でBody型変換を実装
  - _Requirements: 2.1-2.9, 3.2_

- [ ] 5. Bunランタイムでbody型変換を実装する
- [ ] 5.1 Bunランタイム用のbody型判別ロジックを実装する
  - Node.jsと同じbody型判別ロジックをBunランタイム用FFIに実装
  - Bun固有のAPI互換性を確認
  - _Requirements: 1.1-1.9, 3.3_

- [ ] 5.2 Bunランタイム用のRequest/Response変換を実装する
  - toGleamRequest関数でbody型判別を統合
  - toBunResponse関数でBody型変換を実装
  - _Requirements: 2.1-2.9, 3.3_

- [ ] 6. Cloudflare Workersランタイムでbody型変換を実装する
- [ ] 6.1 Workersランタイム用のbody型判別ロジックを実装する
  - Node.jsと同じbody型判別ロジックをWorkersランタイム用FFIに実装
  - Workers環境でのAPI互換性を確認
  - _Requirements: 1.1-1.9, 3.4_

- [ ] 6.2 Workersランタイム用のRequest/Response変換を実装する
  - toGleamRequest関数でbody型判別を統合
  - toWorkersResponse関数でBody型変換を実装
  - _Requirements: 2.1-2.9, 3.4_

- [ ] 7. WinterJSランタイムでbody型変換を実装する
- [ ] 7.1 WinterJSランタイム用のbody型判別ロジックを実装する
  - Node.jsと同じbody型判別ロジックをWinterJSランタイム用FFIに実装
  - WinterJS環境でのAPI互換性を確認
  - _Requirements: 1.1-1.9, 3.5_

- [ ] 7.2 WinterJSランタイム用のRequest/Response変換を実装する
  - toGleamRequest関数でbody型判別を統合
  - toWinterJSResponse関数でBody型変換を実装
  - _Requirements: 2.1-2.9, 3.5_

- [ ] 8. 後方互換性を確保する
- [ ] 8.1 既存のString型ハンドラとの互換性を検証する
  - 既存のRequest(String)/Response(String)を使用するコードが動作することを確認
  - StringをStringBodyに自動変換するロジックを実装
  - 既存のサンプルコードが変更なしで動作することを検証
  - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [ ] 8.2 BitArray型との互換性を実装する
  - BitArrayをBitArrayBodyに変換するロジックを実装
  - 既存のBitArray型コードが動作することを確認
  - _Requirements: 5.2_

- [ ] 9. エラーハンドリングを強化する
- [ ] 9.1 body型変換エラーのハンドリングを実装する
  - サポートされていないbody型を検出してエラーメッセージを生成
  - body読み取り失敗時のエラーハンドリングを実装
  - エラーメッセージに問題の原因と解決方法を含める
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ] 9.2 ランタイム非対応のbody型を処理する
  - 特定のランタイムでサポートされていないbody型を検出
  - エラーメッセージで代替手段を提案
  - ランタイムごとの対応状況をドキュメント化
  - _Requirements: 3.6, 6.3_

- [ ] 10. ユニットテストを実装する
- [ ] 10.1 Body型のユニットテストを実装する
  - 各バリアントのコンストラクタ関数をテスト
  - パターンマッチングのヘルパー関数をテスト
  - 型変換ユーティリティ関数をテスト
  - _Requirements: 4.3_

- [ ] 10.2 FFI変換レイヤーのユニットテストを実装する
  - body型判別関数の各body型（String、Blob、ArrayBuffer等）をテスト
  - nullがEmptyBodyに変換されることをテスト
  - サポートされていない型でエラーが返されることをテスト
  - body読み取り失敗時のエラーハンドリングをテスト
  - _Requirements: 1.1-1.9, 6.1, 6.2_

- [ ] 10.3 Response変換のユニットテストを実装する
  - 各Bodyバリアントが正しいJavaScript型に変換されることをテスト
  - EmptyBodyがnullに変換されることをテスト
  - エラーケースでのハンドリングをテスト
  - _Requirements: 2.1-2.9_

- [ ] 11. 統合テストを実装する
- [ ] 11.1 Node.jsランタイムの統合テストを実装する
  - 各body型を含むリクエストを送信し、Gleam側で正しく受け取れることを検証
  - Gleam側で各body型を含むレスポンスを返し、JavaScript側で正しく受け取れることを検証
  - エンドツーエンドのbody型変換フローをテスト
  - _Requirements: 1.1-1.9, 2.1-2.9, 3.1_

- [ ] 11.2 Denoランタイムの統合テストを実装する
  - Node.jsと同様の統合テストをDeno環境で実行
  - Deno固有のAPI動作を検証
  - _Requirements: 1.1-1.9, 2.1-2.9, 3.2_

- [ ] 11.3 Bunランタイムの統合テストを実装する
  - Node.jsと同様の統合テストをBun環境で実行
  - Bun固有のAPI動作を検証
  - _Requirements: 1.1-1.9, 2.1-2.9, 3.3_

- [ ] 11.4 Cloudflare Workersランタイムの統合テストを実装する
  - Node.jsと同様の統合テストをWorkers環境で実行
  - Workers環境での制約を考慮したテストを実装
  - _Requirements: 1.1-1.9, 2.1-2.9, 3.4_

- [ ] 11.5 WinterJSランタイムの統合テストを実装する
  - Node.jsと同様の統合テストをWinterJS環境で実行
  - WinterJS固有のAPI動作を検証
  - _Requirements: 1.1-1.9, 2.1-2.9, 3.5_

- [ ] 11.6 後方互換性の統合テストを実装する
  - 既存のString型ハンドラが引き続き動作することを検証
  - 既存のBitArray型ハンドラが引き続き動作することを検証
  - 既存のサンプルコードが変更なしで動作することを確認
  - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [ ] 12. パフォーマンステストを実装する
- [ ] 12.1 String型のパフォーマンスを検証する
  - 既存のString型処理と新しいStringBody処理のパフォーマンスを比較
  - レイテンシとスループットが同等であることを検証
  - _Requirements: 7.1_

- [ ] 12.2 バイナリデータのパフォーマンスを検証する
  - 10MBのBlobをリクエストbodyとして送信し、変換時間を測定
  - メモリコピーが最小限であることを検証
  - ゼロコピー変換が適切に動作することを確認
  - _Requirements: 7.2, 7.4_

- [ ] 12.3 ストリーミング処理のパフォーマンスを検証する
  - ReadableStreamを使用したストリーミングデータの送受信をテスト
  - メモリ使用量を測定し、バッファリングが適切に行われることを確認
  - _Requirements: 7.3_

- [ ] 12.4 並行リクエスト処理の負荷テストを実施する
  - 1000並行リクエストを送信し、すべてが正しく処理されることを検証
  - レイテンシとスループットが許容範囲内であることを確認
  - _Requirements: 7.1_

- [ ] 13. サンプルコードとドキュメントを作成する
- [ ] 13.1 各body型の使用例を作成する
  - String、Blob、ArrayBuffer、TypedArray、DataView、FormData、ReadableStream、URLSearchParams、nullの使用例を作成
  - 各例で実際に動作するコードを提供
  - _Requirements: 8.1, 8.2_

- [ ] 13.2 ユースケース別のサンプルコードを作成する
  - 画像アップロード機能のサンプルコード
  - ファイルダウンロード機能のサンプルコード
  - ストリーミングAPI機能のサンプルコード
  - フォーム処理機能のサンプルコード
  - _Requirements: 8.2_

- [ ] 13.3 APIドキュメントを更新する
  - Body型の定義とバリアントをドキュメント化
  - 各ランタイムでのbody型サポート状況を記載
  - 型変換の方法と注意点を説明
  - エラーハンドリングの方法を説明
  - _Requirements: 8.3, 8.4_

- [ ] 14. 統合と検証を完了する
- [ ] 14.1 全ランタイムでの動作を統合検証する
  - 全てのランタイム（Node.js、Deno、Bun、Workers、WinterJS）で全てのbody型が正しく動作することを確認
  - クロスランタイムでの一貫性を検証
  - _Requirements: 3.1-3.6_

- [ ] 14.2 後方互換性の最終検証を実施する
  - 既存のHinotoユーザーのコードが変更なしで動作することを確認
  - 既存のサンプルコードとドキュメントが引き続き有効であることを検証
  - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [ ] 14.3 パフォーマンスの最終検証を実施する
  - 全てのパフォーマンステストが合格することを確認
  - パフォーマンス目標（String型< 1ms、バイナリ< 10ms等）が達成されていることを検証
  - _Requirements: 7.1, 7.2, 7.3, 7.4_

## タスク実行ガイド

### 推奨される実行順序

1. **基盤構築（タスク1）**: Body型の定義とヘルパー関数を実装
2. **FFI変換レイヤー（タスク2）**: body型判別機能を実装
3. **ランタイム実装（タスク3-7）**: 各ランタイムでbody型変換を実装
4. **後方互換性（タスク8）**: 既存コードとの互換性を確保
5. **エラーハンドリング（タスク9）**: エラーハンドリングを強化
6. **テスト（タスク10-12）**: ユニット、統合、パフォーマンステストを実装
7. **ドキュメント（タスク13）**: サンプルコードとドキュメントを作成
8. **統合と検証（タスク14）**: 全体の統合検証を完了

### 重要な注意事項

- 各タスクは前のタスクの完了を前提としています
- ランタイム実装（タスク3-7）は並行して進めることも可能です
- テストは実装と並行して進めることを推奨します
- ドキュメント作成は実装完了後に行うことを推奨します

## 要件カバレッジ

このタスク計画は、requirements.mdに記載された全44の受入基準をカバーしています：

- **要件1（リクエストBody型）**: タスク2.1, 2.2, 3.1, 4.1, 5.1, 6.1, 7.1でカバー
- **要件2（レスポンスBody型）**: タスク3.2, 4.2, 5.2, 6.2, 7.2でカバー
- **要件3（ランタイム一貫性）**: タスク3-7, 14.1でカバー
- **要件4（Gleam型統合）**: タスク1.1, 1.2, 10.1でカバー
- **要件5（後方互換性）**: タスク8, 11.6, 14.2でカバー
- **要件6（エラーハンドリング）**: タスク9, 10.2でカバー
- **要件7（パフォーマンス）**: タスク12, 14.3でカバー
- **要件8（ドキュメント）**: タスク13でカバー
