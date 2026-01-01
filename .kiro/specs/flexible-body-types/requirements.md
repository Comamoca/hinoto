# Requirements Document

## イントロダクション

現在、HinotoのJavaScriptランタイム実装では、Request/ResponseのbodyをString型に固定して処理しています。しかし、MDN仕様によると、Request/ResponseのbodyはString以外にも複数の型をサポートしており、より柔軟なデータ処理を可能にします。

本機能では、MDNのRequest/Response仕様に基づき、以下の全てのbody型に対応することで、開発者がバイナリデータ、フォームデータ、ストリーム等を自由に扱えるようにします：

- `Blob` - バイナリデータ（画像、ファイル等）
- `ArrayBuffer` - 固定長バイナリデータ
- `TypedArray` (Uint8Array等) - 型付き配列
- `DataView` - ArrayBufferの柔軟なビュー
- `FormData` - フォーム送信データ
- `ReadableStream` - ストリーミングデータ
- `URLSearchParams` - URLクエリパラメータ
- `String` - テキストデータ
- `null` - 空のボディ

これにより、画像アップロード、ファイルダウンロード、ストリーミングAPI、フォーム処理など、多様なユースケースに対応可能になります。

## 要件

### 要件1: 複数のBody型のサポート

**目的:** 開発者として、MDN仕様に準拠した全てのbody型を使用できるようにしたい。これにより、バイナリデータやストリームなど、多様なデータ形式を扱えるようになる。

#### 受入基準

1. WHEN リクエストボディがStringである THEN Hinotoランタイム SHALL そのStringをGleam Requestオブジェクトに正しく変換する
2. WHEN リクエストボディがBlobである THEN Hinotoランタイム SHALL そのBlobをGleam Requestオブジェクトに正しく変換する
3. WHEN リクエストボディがArrayBufferである THEN Hinotoランタイム SHALL そのArrayBufferをGleam Requestオブジェクトに正しく変換する
4. WHEN リクエストボディがTypedArray (Uint8Array, Int8Array等)である THEN Hinotoランタイム SHALL そのTypedArrayをGleam Requestオブジェクトに正しく変換する
5. WHEN リクエストボディがDataViewである THEN Hinotoランタイム SHALL そのDataViewをGleam Requestオブジェクトに正しく変換する
6. WHEN リクエストボディがFormDataである THEN Hinotoランタイム SHALL そのFormDataをGleam Requestオブジェクトに正しく変換する
7. WHEN リクエストボディがReadableStreamである THEN Hinotoランタイム SHALL そのReadableStreamをGleam Requestオブジェクトに正しく変換する
8. WHEN リクエストボディがURLSearchParamsである THEN Hinotoランタイム SHALL そのURLSearchParamsをGleam Requestオブジェクトに正しく変換する
9. WHEN リクエストボディがnullである THEN Hinotoランタイム SHALL 空のボディとしてGleam Requestオブジェクトに変換する

### 要件2: レスポンスBody型のサポート

**目的:** 開発者として、レスポンスでもMDN仕様に準拠した全てのbody型を返せるようにしたい。これにより、クライアントに多様な形式のデータを送信できるようになる。

#### 受入基準

1. WHEN Gleam ResponseのボディがStringである THEN Hinotoランタイム SHALL そのStringをJavaScript Responseオブジェクトに正しく変換する
2. WHEN Gleam ResponseのボディがBlobである THEN Hinotoランタイム SHALL そのBlobをJavaScript Responseオブジェクトに正しく変換する
3. WHEN Gleam ResponseのボディがArrayBufferである THEN Hinotoランタイム SHALL そのArrayBufferをJavaScript Responseオブジェクトに正しく変換する
4. WHEN Gleam ResponseのボディがTypedArrayである THEN Hinotoランタイム SHALL そのTypedArrayをJavaScript Responseオブジェクトに正しく変換する
5. WHEN Gleam ResponseのボディがDataViewである THEN Hinotoランタイム SHALL そのDataViewをJavaScript Responseオブジェクトに正しく変換する
6. WHEN Gleam ResponseのボディがFormDataである THEN Hinotoランタイム SHALL そのFormDataをJavaScript Responseオブジェクトに正しく変換する
7. WHEN Gleam ResponseのボディがReadableStreamである THEN Hinotoランタイム SHALL そのReadableStreamをJavaScript Responseオブジェクトに正しく変換する
8. WHEN Gleam ResponseのボディがURLSearchParamsである THEN Hinotoランタイム SHALL そのURLSearchParamsをJavaScript Responseオブジェクトに正しく変換する
9. WHEN Gleam Responseのボディがnullである THEN Hinotoランタイム SHALL 空のボディとしてJavaScript Responseオブジェクトに変換する

### 要件3: 全JavaScriptランタイムでの一貫性

**目的:** 開発者として、全てのサポート対象JavaScriptランタイム（Node.js、Deno、Bun、Cloudflare Workers、WinterJS）で同じbody型のサポートを利用したい。これにより、ランタイム間でコードの移植性が保たれる。

#### 受入基準

1. WHEN Node.jsランタイムで実行される THEN Hinoto SHALL 全てのbody型を同じ方法でサポートする
2. WHEN Denoランタイムで実行される THEN Hinoto SHALL 全てのbody型を同じ方法でサポートする
3. WHEN Bunランタイムで実行される THEN Hinoto SHALL 全てのbody型を同じ方法でサポートする
4. WHEN Cloudflare Workersランタイムで実行される THEN Hinoto SHALL 全てのbody型を同じ方法でサポートする
5. WHEN WinterJSランタイムで実行される THEN Hinoto SHALL 全てのbody型を同じ方法でサポートする
6. IF ランタイムが特定のbody型をネイティブサポートしない THEN Hinoto SHALL 適切なエラーメッセージを返すか、可能な範囲でポリフィルを提供する

### 要件4: Gleam型システムとの統合

**目的:** 開発者として、Gleamの型システムでbodyの型を表現したい。これにより、コンパイル時に型の安全性が保証され、実行時エラーを減らせる。

#### 受入基準

1. WHEN ユーザーがリクエストボディの型を指定する THEN Hinoto SHALL Gleamの型システムを通じてその型を表現する
2. WHEN ユーザーがレスポンスボディの型を指定する THEN Hinoto SHALL Gleamの型システムを通じてその型を表現する
3. WHEN 型が不正である THEN Gleamコンパイラ SHALL コンパイル時にエラーを検出する
4. WHERE body型がGleam側で定義される THE Hinoto SHALL JavaScript FFIを通じて適切にマッピングする

### 要件5: 後方互換性の維持

**目的:** 既存ユーザーとして、現在String型で動作しているコードが引き続き動作することを期待する。これにより、破壊的変更なしに新機能を導入できる。

#### 受入基準

1. WHEN 既存コードがString型のbodyを使用している THEN Hinoto SHALL そのコードを変更なしで動作させる
2. WHEN 既存コードがBitArray型のbodyを使用している THEN Hinoto SHALL そのコードを変更なしで動作させる
3. IF ユーザーが新しいbody型を使用しない THEN Hinoto SHALL 現在の動作を保持する
4. WHEN APIが変更される THEN Hinoto SHALL 既存の公開APIに対して後方互換性を維持する

### 要件6: エラーハンドリングと検証

**目的:** 開発者として、body型の変換エラーを適切に処理したい。これにより、デバッグが容易になり、本番環境での問題を早期に発見できる。

#### 受入基準

1. WHEN body型の変換に失敗する THEN Hinoto SHALL 明確なエラーメッセージを含むResult型のErrorを返す
2. WHEN サポートされていないbody型が使用される THEN Hinoto SHALL コンパイル時または実行時にエラーを報告する
3. WHEN ランタイムがbody型をサポートしない THEN Hinoto SHALL 実行時に明確なエラーメッセージを提供する
4. WHERE エラーが発生する THE エラーメッセージ SHALL 問題の原因と解決方法を示す

### 要件7: パフォーマンスとメモリ効率

**目的:** 開発者として、新しいbody型のサポートが既存のパフォーマンスを劣化させないことを期待する。これにより、本番環境でのスループットとレイテンシが維持される。

#### 受入基準

1. WHEN String型のbodyを使用する THEN Hinoto SHALL 現在のパフォーマンスレベルを維持する
2. WHEN 大きなバイナリデータ（ArrayBuffer、Blob等）を処理する THEN Hinoto SHALL メモリコピーを最小限に抑える
3. WHEN ReadableStreamを使用する THEN Hinoto SHALL ストリーミング処理を効率的に実行する
4. WHERE 可能である THE Hinoto SHALL ゼロコピー変換を実装する

### 要件8: ドキュメントと例

**目的:** 開発者として、新しいbody型の使い方を理解するための明確なドキュメントと例が欲しい。これにより、迅速に新機能を採用できる。

#### 受入基準

1. WHEN ユーザーがドキュメントを参照する THEN Hinoto SHALL 各body型の使用例を提供する
2. WHEN ユーザーが特定のユースケース（画像アップロード、ファイルダウンロード等）を実装する THEN Hinoto SHALL そのユースケースの完全な例を提供する
3. WHERE 型変換が必要である THE ドキュメント SHALL 変換方法を明確に説明する
4. WHEN APIリファレンスが更新される THEN すべてのbody型 SHALL ドキュメントに記載される
