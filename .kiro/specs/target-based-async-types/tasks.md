# 実装タスク: target-based-async-types

## 概要

この実装では、JavaScriptとErlangターゲットで異なる非同期型システムを導入します。JavaScriptでは`Promise`ベースのAPI、ErlangではMistフレームワークの型システムに準拠したAPIを提供します。

## タスクリスト

- [ ] 1. コアモジュールのターゲット別型システム実装
- [x] 1.1 `handle`関数をターゲット別実装に書き換え
  - JavaScriptターゲットで`Promise`を受け入れる`handle`関数を実装
  - Erlangターゲットで同期的な`handle`関数を実装
  - `@target`属性を使用してターゲット別に分岐
  - 内部で`use`構文を使用してPromiseチェーンを構築
  - _Requirements: 1.1, 1.2, 1.4, 2.1, 2.2, 5.1, 5.2, 5.3_

- [x] 1.2 Erlang向け型エイリアスを追加
  - `HinotoMist(context)`型エイリアスを定義（`Hinoto(context, mist.Connection)`のエイリアス）
  - Erlangターゲット専用の`@target(erlang)`属性を付与
  - Mistの`Connection`型をインポート
  - _Requirements: 3.2, 3.3, 4.2, 4.3, 4.4, 5.5_

- [x] 1.3 コアモジュールのユニットテストを実装
  - JavaScriptターゲットで`handle`関数が`Promise`を正しく処理することをテスト
  - `set_response`、`set_request`、`set_context`関数が正しく動作することを確認
  - モックハンドラーを使用して基本的な動作を検証
  - _Requirements: 8.1, 8.3_

- [ ] 2. Mistランタイムモジュールの実装
- [x] 2.1 Mistランタイムモジュールを新規作成
  - `src/hinoto/runtime/mist.gleam`ファイルを作成
  - Mistの`Connection`と`ResponseData`型をインポート
  - `handler`関数を実装（Hinotoインスタンスを受け取りMistハンドラーを返す）
  - `start_server`関数を実装（ポートとホストを受け取りMistサーバーを起動）
  - `@target(erlang)`属性を付与してErlang専用にする
  - _Requirements: 3.1, 3.5, 9.1, 9.2_

- [x] 2.2 Mistランタイムの統合テストを実装
  - Mistサーバーを起動して基本的なリクエスト処理をテスト
  - `Connection`と`ResponseData`型の変換が正しく動作することを確認
  - Erlangターゲットでのビルドとテストが成功することを確認
  - _Requirements: 8.2, 8.3, 8.4_

- [x] 2.3 gleam.tomlにMist依存関係を追加
  - Erlangターゲット用に`mist`パッケージを依存関係に追加
  - バージョンを最新安定版に設定
  - _Requirements: 9.1_

- [ ] 3. JavaScriptランタイムモジュールのドキュメント更新
- [x] 3.1 Node.jsランタイムのドキュメントコメントを更新
  - `Promise`の説明を明確化
  - `handler`関数の型シグネチャにPromiseを明記
  - 使用例を更新してPromiseベースのハンドラーを示す
  - _Requirements: 2.1, 2.3_

- [x] 3.2 他のJavaScriptランタイムのドキュメントを更新
  - Deno、Bun、Workers、WinterJSの各ランタイムモジュールのドキュメントを更新
  - Promiseベースのハンドラー例を追加
  - _Requirements: 2.1, 2.3_

- [ ] 4. サンプルプロジェクトのマイグレーション
- [x] 4.1 Node.jsサンプルをPromise対応に移行
  - `example/node_server/src/node_server.gleam`を更新
  - すべてのハンドラーをPromiseを返すように書き換え
  - 非同期処理の例を追加（例: データベースアクセス、外部API呼び出し）
  - ビルドとテストが成功することを確認
  - _Requirements: 2.1, 2.2, 2.5, 6.1, 6.5, 6.6_

- [x] 4.2 Denoサンプルを非同期対応に移行
  - `example/deno_server/src/deno_server.gleam`を更新
  - Promiseベースのハンドラーに書き換え
  - `to_deno_response`変換関数を追加
  - _Requirements: 2.1, 6.2, 6.5, 6.6_

- [x] 4.3 Bunサンプルを非同期対応に移行
  - `example/bun_server/src/bun_server.gleam`を更新
  - Promiseベースのハンドラーに書き換え
  - `to_bun_response`変換関数を追加
  - _Requirements: 2.1, 6.3, 6.5, 6.6_

- [x] 4.4 Cloudflare Workersサンプルを非同期対応に移行
  - `example/workers/src/workers.gleam`を更新
  - Promiseベースのハンドラーに書き換え
  - _Requirements: 2.1, 6.4, 6.5, 6.6_

- [ ] 4.5 Erlang/Mistサンプルプロジェクトを新規作成
  - `example/mist_server`ディレクトリを作成
  - `gleam.toml`でMist依存関係を設定
  - Mistランタイムモジュールを使用した基本的なHTTPサーバーを実装
  - ストリーミングレスポンス（`mist.Chunked`）の例を追加
  - ファイルレスポンス（`mist.send_file`）の例を追加
  - Erlangターゲットでビルドとテストが成功することを確認
  - _Requirements: 3.1, 3.5, 3.6, 3.7, 9.2, 9.3, 9.4, 9.5, 9.6_

- [ ] 5. E2Eテストの実装
- [ ] 5.1 JavaScriptランタイムのE2Eテストを実装
  - Node.js、Deno、Bun、Workersの各ランタイムで実際にサーバーを起動
  - 基本的なHTTPリクエスト（GET、POST）を送信してレスポンスを検証
  - Promiseベースのハンドラーが正しく動作することを確認
  - ルーティングが期待通りに動作することを確認
  - _Requirements: 2.3, 2.4, 2.5, 6.5_

- [ ] 5.2 Erlang/MistランタイムのE2Eテストを実装
  - Mistサーバーを起動して実際のHTTPリクエストを処理
  - `Connection`と`ResponseData`型の変換が正しく動作することを確認
  - ストリーミングレスポンスとファイルレスポンスをテスト
  - _Requirements: 3.5, 9.2, 9.4, 9.5_

- [ ] 6. ドキュメントの更新とマイグレーションガイドの作成
- [ ] 6.1 concepts.mdにターゲット別型定義の説明を追加
  - `@target`属性の使用方法を説明
  - JavaScriptとErlangでの型の違いを明記
  - Mistフレームワークとの統合について説明
  - `HinotoMist`型エイリアスの使用方法を記載
  - _Requirements: 10.1, 10.2, 10.6_

- [ ] 6.2 quickstart.mdに使用例を追加
  - JavaScriptターゲットでのPromiseベースのハンドラー例を追加
  - Erlangターゲットでのサーバー起動例を追加
  - Mistの`Connection`と`ResponseData`型の使用例を追加
  - _Requirements: 10.3, 10.6_

- [x] 6.3 README.mdを更新
  - v2.0.0の破壊的変更を明記
  - 新しいPromiseベースのAPIについて説明
  - JavaScriptとErlangの両方のサンプルコードを追加
  - マイグレーションガイドをREADMEに追加
  - _Requirements: 10.4_

- [x] 6.4 CHANGELOGとマイグレーションガイドを作成
  - v1.x → v2.0.0のマイグレーションガイドをREADMEに記載
  - 既存コードの書き換え例を具体的に示す
  - `handle`関数のシグネチャ変更について説明
  - `promise.resolve()`を使った同期的なハンドラーのラップ方法を示す
  - 非同期処理の書き方（`use`構文）を説明
  - _Requirements: 7.2, 7.3, 7.4_

- [ ] 6.5 API docsの生成と検証
  - `gleam docs build`を実行してAPIドキュメントを生成
  - 各ターゲット用の型定義が正しく表示されることを確認
  - `@target`属性が適切にドキュメント化されていることを確認
  - _Requirements: 10.5_

- [x] 7. CI/CDパイプラインの更新
- [x] 7.1 JavaScriptターゲットのCI設定を更新
  - `gleam build --target javascript`が成功することを確認
  - `gleam test --target javascript`が成功することを確認
  - CI/CDで明示的にJavaScriptターゲットを指定
  - _Requirements: 8.1, 8.4_

- [x] 7.2 ErlangターゲットのCI設定を追加
  - `gleam build --target erlang`が成功することを確認
  - `gleam test --target erlang`が成功することを確認
  - JavaScriptとErlangの両方を並列実行
  - _Requirements: 8.2, 8.4_

## 実装の注意事項

### 破壊的変更
- v1.x → v2.0.0へのメジャーバージョンアップ
- JavaScriptターゲットで`handle`関数のシグネチャが変更
- 既存のJavaScriptコードは**必ず**Promiseを返すように書き換えが必要

### マイグレーション例
```gleam
// 旧コード（v1.x）
hinoto
|> handle(fn(req) {
  response.new(200)
  |> response.set_body("Hello")
})

// 新コード（v2.0.0） - 同期的な場合
hinoto
|> handle(fn(req) {
  promise.resolve(
    response.new(200)
    |> response.set_body("Hello")
  )
})

// 新コード（v2.0.0） - 非同期処理の場合
hinoto
|> handle(fn(req) {
  use data <- promise.await(fetch_data())
  response.new(200)
  |> response.set_body(data)
})
```

### テスト戦略
- **ユニットテスト**: コアモジュールの型変換とハンドラー処理
- **統合テスト**: 各ランタイムモジュールでのサーバー起動とリクエスト処理
- **E2Eテスト**: 実際のHTTPリクエストを送信して全体の動作を検証
- **クロスターゲットテスト**: JavaScriptとErlangの両方でビルドとテストを実行

### 実装の優先順位
1. **Phase 1 (Tasks 1.x)**: コア型システムの実装とテスト
2. **Phase 2 (Tasks 2.x, 3.x)**: Mistランタイムとドキュメント更新
3. **Phase 3 (Tasks 4.x, 5.x)**: サンプルプロジェクトの移行とE2Eテスト
4. **Phase 4 (Tasks 6.x, 7.x)**: ドキュメント整備とCI/CD設定

### Rollback戦略
各フェーズでビルドエラーやテスト失敗が発生した場合、前のフェーズに戻って原因を特定します。特にPhase 1のコアモジュール実装は慎重に進め、必ずユニットテストを先に実装してから本体コードを書きます。
