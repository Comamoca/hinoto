# Requirements Document

## 導入

Hinoroは現在、JavaScriptターゲットのみをサポートしているため、すべての非同期処理が`Promise`型に依存しています。しかし、GleamはJavaScriptとErlangの両方をターゲットとしてサポートしており、将来的にErlangターゲットでもHinotoを使用できるようにする必要があります。

この機能では、Gleamの`@target`属性を活用して、JavaScriptとErlangで異なる型定義を使用できるようにします。これにより：

- **JavaScriptターゲット**: `Promise`ベースの非同期APIを継続使用
- **Erlangターゲット**: Mistフレームワークの型システムに準拠（`Request(Connection)` → `Response(ResponseData)`）
- **型安全性**: コンパイル時にターゲットに応じた適切な型が選択される
- **移植性**: ランタイム固有のコードを明示的に分離し、コアロジックは共通化

### Mistフレームワークとの統合

Erlangターゲットでは、GleamのHTTPサーバーフレームワークである[Mist](https://hexdocs.pm/mist/)の型システムに従います：

- **リクエスト型**: `Request(Connection)` - Mistの`Connection`型を使用
- **レスポンス型**: `Response(ResponseData)` - Mistの`ResponseData`型を使用
- **ハンドラー型**: `fn(Request(Connection)) -> Response(ResponseData)`
- **非同期処理**: Erlang/OTPのプロセスモデルを活用

この実装により、HinotoはJavaScriptとErlangの両方で、各エコシステムの慣用的なパターンに従った自然なAPIを提供できます。

## Requirements

### Requirement 1: ターゲット別型定義システム

**Objective:** 開発者として、JavaScriptとErlangターゲットで異なる非同期型を使用できるようにしたい。これにより、各ターゲットの特性に最適化されたAPIを提供できる。

#### Acceptance Criteria

1. WHEN Gleamコンパイラが`@target(javascript)`属性を検出した場合、HinotoフレームワークはJavaScript固有の型定義を使用しなければならない
2. WHEN Gleamコンパイラが`@target(erlang)`属性を検出した場合、HinotoフレームワークはErlang固有の型定義を使用しなければならない
3. IF コアモジュール(`src/hinoto.gleam`)で型を定義する場合、その型はターゲットに依存しない共通の型でなければならない
4. WHERE ターゲット固有の処理が必要な場合、その処理は`@target`属性で明示的に分離しなければならない
5. WHEN ユーザーが`gleam build --target javascript`を実行した場合、JavaScript用の型定義のみがコンパイル結果に含まれなければならない
6. WHEN ユーザーが`gleam build --target erlang`を実行した場合、Erlang用の型定義のみがコンパイル結果に含まれなければならない

### Requirement 2: JavaScript Promiseベースの非同期API

**Objective:** JavaScript開発者として、標準的な`Promise`APIを使用してHinotoアプリケーションを記述できるようにしたい。これにより、JavaScriptエコシステムとの統合が容易になる。

#### Acceptance Criteria

1. WHEN JavaScriptターゲットでビルドされた場合、`handle`関数は`fn(Request(body)) -> Promise(Response(body))`型のハンドラーを受け入れなければならない
2. IF ハンドラーが`Promise`を返す場合、Hinotoフレームワークはそれを適切に処理し、レスポンスを待機しなければならない
3. WHERE ランタイムモジュール(`hinoto/runtime/node`, `hinoto/runtime/deno`など)でサーバーを起動する場合、`Promise`ベースのハンドラーを正しく処理しなければならない
4. WHEN 非同期エラーが発生した場合、`Promise`の`reject`として適切にエラーを伝播しなければならない
5. IF 複数の非同期操作を連鎖させる場合、`Promise`チェーンが正しく動作しなければならない

### Requirement 3: ErlangターゲットのMist型システムサポート

**Objective:** Erlang開発者として、Mistフレームワークの型システムに準拠したHinotoアプリケーションを記述できるようにしたい。これにより、GleamのErlangエコシステムとの自然な統合が可能になる。

#### Acceptance Criteria

1. WHEN Erlangターゲットでビルドされた場合、`handle`関数は`fn(Request(Connection)) -> Response(ResponseData)`型のハンドラーを受け入れなければならない
2. WHERE `Request`型を使用する場合、Mistの`Connection`型をbodyとして使用しなければならない
3. WHERE `Response`型を使用する場合、Mistの`ResponseData`型をbodyとして使用しなければならない
4. IF Erlangターゲットで非同期処理が必要な場合、Erlang/OTPのプロセスモデルを使用しなければならない
5. WHEN Erlangランタイムでサーバーを起動する場合、Mistのサーバー起動APIと互換性を持たなければならない
6. WHERE `ResponseData`を構築する場合、Mistが提供する`Bytes`、`Chunked`、またはファイルレスポンス型を使用しなければならない
7. WHEN Erlangターゲットでエラーが発生した場合、Gleamの`Result`型を使用してエラーを表現しなければならない

### Requirement 4: 型エイリアスとヘルパー型の定義

**Objective:** 開発者として、ターゲット別の型を簡潔に表現できる型エイリアスを使用したい。これにより、コードの可読性と保守性が向上する。

#### Acceptance Criteria

1. WHERE JavaScriptターゲットの場合、`AsyncResponse(body)`型エイリアスは`Promise(Response(body))`として定義されなければならない
2. WHERE Erlangターゲットの場合、`AsyncResponse`型エイリアスは`Response(ResponseData)`として定義され、Mistの`ResponseData`型を使用しなければならない
3. WHERE Erlangターゲットの場合、リクエストbody型は`Connection`として定義され、Mistの`Connection`型を使用しなければならない
4. IF ユーザーが`AsyncResponse`型を使用する場合、コンパイラはターゲットに応じて自動的に適切な型に解決しなければならない
5. WHEN 型エイリアスをエクスポートする場合、両方のターゲットで一貫した名前とインターフェースを提供しなければならない

### Requirement 5: ハンドラー関数の型シグネチャ

**Objective:** 開発者として、ターゲットに応じた適切なハンドラー型を使用できるようにしたい。これにより、型安全性を保ちながら各ターゲットに最適化されたコードを書ける。

#### Acceptance Criteria

1. WHERE JavaScriptターゲットの場合、`Handler(context, body)`型は`fn(Hinoto(context, body)) -> Hinoto(context, body)`として定義され、内部で`Promise`を使用しなければならない
2. WHERE Erlangターゲットの場合、`Handler(context)`型は`fn(Hinoto(context, Connection)) -> Hinoto(context, ResponseData)`として定義され、Mistの型システムに準拠しなければならない
3. IF `handle`関数を呼び出す場合、ターゲットに応じた適切なハンドラー型が使用されなければならない
4. WHEN ハンドラーの型が不一致の場合、コンパイラは明確な型エラーを報告しなければならない
5. WHERE Erlangターゲットで`Hinoto`型を定義する場合、リクエストbodyは`Connection`型、レスポンスbodyは`ResponseData`型でなければならない

### Requirement 6: サンプルプロジェクトの更新

**Objective:** ユーザーとして、新しいターゲット別型定義システムを使用したサンプルコードを参照できるようにしたい。これにより、実際の使用方法を理解し、自分のプロジェクトに適用できる。

#### Acceptance Criteria

1. WHEN `example/node_server`プロジェクトを確認した場合、`Promise`ベースのハンドラーを使用した実装例が含まれていなければならない
2. WHEN `example/deno_server`プロジェクトを確認した場合、`Promise`ベースのハンドラーを使用した実装例が含まれていなければならない
3. WHEN `example/bun_server`プロジェクトを確認した場合、`Promise`ベースのハンドラーを使用した実装例が含まれていなければならない
4. WHEN `example/workers`プロジェクトを確認した場合、`Promise`ベースのハンドラーを使用した実装例が含まれていなければならない
5. IF 各サンプルプロジェクトをビルドおよび実行した場合、エラーなく動作しなければならない
6. WHERE サンプルコードでルーティングを実装する場合、`Promise`を返すハンドラーを使用しなければならない

### Requirement 7: 後方互換性とマイグレーション

**Objective:** 既存のHinotoユーザーとして、新しい型システムへスムーズに移行できるようにしたい。破壊的変更を最小限に抑え、段階的な移行パスを提供する。

#### Acceptance Criteria

1. IF 既存のコードが`Promise`を明示的に使用していない場合でも、JavaScriptターゲットで正しく動作しなければならない
2. WHEN 既存のハンドラー実装を新しい型システムに移行する場合、最小限のコード変更で済むようにしなければならない
3. WHERE 型エラーが発生する場合、コンパイラは具体的な修正方法を提案するエラーメッセージを表示しなければならない
4. IF ドキュメントを確認した場合、マイグレーションガイドと移行例が含まれていなければならない

### Requirement 8: テストとビルド検証

**Objective:** 開発者として、ターゲット別の型定義が正しく機能することを検証できるテストを実行できるようにしたい。これにより、各ターゲットでの動作を保証できる。

#### Acceptance Criteria

1. WHEN `gleam test --target javascript`を実行した場合、JavaScriptターゲット用のすべてのテストが成功しなければならない
2. WHEN `gleam test --target erlang`を実行した場合、Erlangターゲット用のすべてのテストが成功しなければならない（将来的なErlangサポートのため）
3. WHERE 型定義をテストする場合、各ターゲットで適切な型が使用されていることを検証しなければならない
4. IF CI/CDパイプラインを実行する場合、両方のターゲットでビルドとテストが成功しなければならない

### Requirement 9: Mistフレームワークとの統合

**Objective:** 開発者として、ErlangターゲットでMistフレームワークとシームレスに統合できるようにしたい。これにより、GleamのErlangエコシステムで標準的な方法でHTTPサーバーを構築できる。

#### Acceptance Criteria

1. WHEN Erlangターゲットで依存関係を確認した場合、`mist`パッケージが含まれていなければならない
2. WHERE Erlangターゲットでサーバーを起動する場合、`mist.new(handler)`または類似のMist APIを使用しなければならない
3. IF `ResponseData`を構築する場合、`mist.Bytes(bytes_builder)`、`mist.Chunked(iterator)`などのMist型コンストラクタを使用しなければならない
4. WHEN ストリーミングレスポンスを実装する場合、Mistの`Chunked`型と`gleam/yielder`を使用しなければならない
5. WHERE ファイルレスポンスを返す場合、Mistの`send_file`機能を使用しなければならない
6. IF クライアント情報を取得する場合、`mist.get_client_info(request.body)`を使用して`Connection`から情報を抽出しなければならない

### Requirement 10: ドキュメントの更新

**Objective:** ユーザーとして、ターゲット別型定義システムとMist統合の使用方法を理解できる包括的なドキュメントを参照できるようにしたい。

#### Acceptance Criteria

1. WHERE `docs/concepts.md`を確認した場合、ターゲット別型定義の概念と設計思想が説明されていなければならない
2. WHERE `docs/concepts.md`を確認した場合、ErlangターゲットでのMist統合について説明されていなければならない
3. WHERE `docs/quickstart.md`を確認した場合、JavaScriptとErlangターゲットでの使用例が含まれていなければならない
4. IF `README.md`を確認した場合、新しい型システムに関する説明とサンプルコードが含まれていなければならない
5. WHEN APIドキュメントを生成した場合、各ターゲット用の型定義が正しく表示されなければならない
6. WHERE Erlangターゲットのドキュメントを確認した場合、Mistの`Connection`と`ResponseData`型の使用例が含まれていなければならない
