# Hinoto テストドキュメント

このドキュメントは、Hinotプロジェクトに実装されているすべてのテストの一覧と詳細を記載しています。

## テスト概要

- **総テスト数**: 18テスト
- **テストファイル数**: 3ファイル
- **テスト実行状況**: すべて成功

## テストファイル構成

### 1. `test/hinoto_test.gleam` - 単体テスト (8テスト)

メインライブラリの基本機能をテストします。

#### 1.1 `context_test()`

- **目的**: Context型が正しく作成できることを確認
- **検証内容**: `Context`型の作成とパターンマッチング
- **実装**: 単純な型作成テスト

#### 1.2 `environment_test()`

- **目的**: Environment型が正しく作成できることを確認
- **検証内容**: 辞書を持つ`Environment`型の作成とパターンマッチング
- **実装**: `dict.from_list()`を使用した環境変数辞書の初期化

#### 1.3 `default_context_test()`

- **目的**: DefaultContext型が正しく作成・アクセスできることを確認
- **検証内容**: EnvironmentとContextを組み合わせたDefaultContextの作成と値の確認
- **実装**: ネストしたパターンマッチングによるフィールドの検証

#### 1.4 `default_handler_test()`

- **目的**: デフォルトハンドラーが正しい値を返すことを確認
- **検証内容**:
  - HTTPステータス200を返す
  - レスポンスボディが`Text("Hello from hinoto!")`であることを確認
- **実装**: Promiseを使用した非同期テスト

#### 1.5 `fetch_test()`

- **目的**: fetch関数が正しくコンパイルされることを確認
- **検証内容**: fetch関数の戻り値が期待される型であることの確認
- **実装**: 関数型の検証

#### 1.6 `environment_dict_access_test()`

- **目的**: Environment内の辞書操作が正しく動作することを確認
- **検証内容**:
  - 辞書サイズの確認
  - 環境変数の取得（`DATABASE_URL`, `API_KEY`）
  - 存在する変数の値確認
- **実装**: `dict.get()`を使用したResult型の処理

#### 1.7 `update_environment_bug_test()`

- **目的**: `update_environment`関数の既知のバグを文書化
- **検証内容**: 現在の実装の動作確認（バグ修正前の状態）
- **実装**: バグの存在を文書化するテスト
- **注意**: この関数は環境を更新すべきだが、現在はレスポンスを更新している

#### 1.8 `response_body_variants_test()`

- **目的**: ResponseBody型のバリアント（Text）が正しく動作することを確認
- **検証内容**:
  - Text variant のパターンマッチング
  - レスポンスボディの作成と内容確認
- **実装**: conversation.Text型を使用したテスト

### 2. `test/integration_test.gleam` - 統合テスト (4テスト)

異なるコンポーネント間の連携をテストします。

#### 2.1 `handler_chaining_concept_test()`

- **目的**: ハンドラーチェーンのコンセプトが動作することを確認
- **検証内容**: 複数のレスポンス処理とPromise操作の確認
- **実装**: レスポンスの作成と変更のシミュレーション

#### 2.2 `environment_context_integration_test()`

- **目的**: EnvironmentとContextが統合的に動作することを確認
- **検証内容**:
  - DefaultContextの作成
  - 両コンポーネントの保持確認
  - パターンマッチングによる型検証
- **実装**: ネストしたパターンマッチング

#### 2.3 `response_creation_test()`

- **目的**: レスポンス作成と構造の確認
- **検証内容**:
  - レスポンスのステータス確認（200）
  - レスポンスボディの内容確認
- **実装**: Promise処理を使用したレスポンス検証

#### 2.4 `promise_handling_test()`

- **目的**: Promise処理の基本動作確認
- **検証内容**: `promise.resolve()`と`promise.map()`の動作確認
- **実装**: 文字列値を使用した簡単なPromise操作

### 3. `test/hinoto/status_test.gleam` - HTTPステータスコードテスト (6テスト)

HTTPステータスコード定数の正確性をテストします。

#### 3.1 `informational_status_codes_test()`

- **目的**: 1xx情報レスポンスステータスコードの確認
- **検証内容**:
  - `continue = 100`
  - `switching_protocols = 101`
  - `processing = 102`
  - `early_hints = 103`

#### 3.2 `success_status_codes_test()`

- **目的**: 2xx成功ステータスコードの確認
- **検証内容**:
  - `ok = 200`
  - `created = 201`
  - `accepted = 202`
  - `non_authoritative_information = 203`
  - `no_content = 204`
  - `reset_content = 205`
  - `partial_content = 206`
  - `multi_status = 207`
  - `already_reported = 208`
  - `im_used = 226`

#### 3.3 `redirection_status_codes_test()`

- **目的**: 3xxリダイレクションステータスコードの確認
- **検証内容**:
  - `multiple_choices = 300`
  - `moved_permanently = 301`
  - `found = 302`
  - `see_other = 303`
  - `not_modified = 304`
  - `use_proxy = 305`
  - `temporary_redirect = 307`
  - `permanent_redirect = 308`

#### 3.4 `client_error_status_codes_test()`

- **目的**: 4xxクライアントエラーステータスコードの確認
- **検証内容**: 400番台のすべてのステータスコード（400-451）
- **実装**: 包括的なクライアントエラーステータスコード検証

#### 3.5 `server_error_status_codes_test()`

- **目的**: 5xxサーバーエラーステータスコードの確認
- **検証内容**: 500番台のすべてのステータスコード（500-511）
- **実装**: 包括的なサーバーエラーステータスコード検証

#### 3.6 `common_status_codes_test()`

- **目的**: よく使用されるステータスコードの確認
- **検証内容**:
  - 成功: 200 (OK), 201 (Created), 204 (No Content)
  - クライアントエラー: 400, 401, 403, 404, 405
  - サーバーエラー: 500, 502, 503
- **実装**: 実際の開発でよく使用されるステータスコードの検証

## テスト実行方法

```bash
gleam test
```

## 依存関係

- `gleeunit`: Gleamの公式テストフレームワーク
- `gleeunit/should`: アサーション関数
- `gleam/javascript/promise`: 非同期処理テスト用
- `gleam/dict`: 環境変数辞書テスト用
- `conversation`: HTTP型定義
- `hinoto`: テスト対象のメインライブラリ

## テスト戦略

1. **単体テスト**: 個別の関数や型の動作確認
2. **統合テスト**: 複数のコンポーネント間の連携確認
3. **定数テスト**: HTTPステータスコード定数の正確性確認
4. **非同期テスト**: Promise処理の動作確認
5. **型テスト**: Gleamの型システムを活用した型安全性確認

## 既知の問題

### バグ: `update_environment`関数
- **場所**: `src/hinoto.gleam:166-171`
- **問題**: 環境を更新すべきだが、現在はレスポンスを更新している
- **状況**: `update_environment_bug_test()`でバグを文書化済み
- **修正が必要**: 関数の実装を環境更新に変更する必要あり

## 現在のテストカバレッジ

### ✅ テスト済み機能
- 基本型の作成（Context, Environment, DefaultContext）
- `default_handler()`関数
- `fetch()`関数の基本動作
- 環境変数辞書操作
- HTTPステータスコード定数（全コード）
- ResponseBody型のText variant
- 基本的な統合テスト
- Promise処理

### ❌ 未テスト機能
- `set_response()`関数
- `update_request()`関数
- `update_response()`関数
- `handle()`関数
- `handle_request()`関数（メインエントリーポイント）
- ResponseBody型のBits, Stream variant
- エラーハンドリング
- 実際のJavaScriptとの統合

## 今後のテスト拡張案

### 高優先度
1. **`update_environment`バグ修正後のテスト**: 正しい環境更新のテスト
2. **未テスト関数のテスト**: `handle_request`、`set_response`等の基本機能テスト
3. **ResponseBody variant テスト**: Bits、Stream型のテスト

### 中優先度
4. **エラーハンドリングテスト**: 異常系のテスト追加
5. **実際のHTTPテスト**: JavaScriptランタイムとの統合テスト
6. **モックテスト**: 外部依存関係のモック化

### 低優先度
7. **パフォーマンステスト**: 大量リクエスト処理のベンチマーク
8. **プロパティベーステスト**: ランダム入力によるテスト
9. **エンドツーエンドテスト**: 実際のHTTPリクエスト処理テスト
