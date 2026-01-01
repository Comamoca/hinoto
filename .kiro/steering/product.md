# Product Overview - Hinoto

## What is Hinoto?

Hinoto は Gleam で書かれた、複数の JavaScript ランタイムをサポートする Web フレームワークです。Node.js、Deno、Bun、CloudFlare Workers、WinterJS といった様々な実行環境で動作し、モジュールファーストの設計により効率的なコード生成を実現しています。

## Core Features

- **マルチランタイムサポート**
  - Node.js、Deno、Bun などの主要な JavaScript ランタイムに対応
  - CloudFlare Workers や WinterJS などのエッジ環境でも動作
  - 各ランタイム用の専用モジュール（`hinoto/runtime/node`、`hinoto/runtime/deno` など）を提供

- **モジュールファースト設計**
  - 機能がモジュール単位で分割され、Tree-shaking に最適化
  - バンドル時に余分な FFI コードが混入しない
  - 必要な機能のみをインポートして使用可能

- **カスタムコンテキスト**
  - `Hinoto` 型に任意のコンテキストを含められる
  - ランタイム固有の情報を統一的に扱える
  - 型安全なコンテキスト管理

- **Fetch API 互換設計**
  - `Request` と `Response` の変換を簡潔に記述
  - `Promise` ベースの非同期処理
  - 標準的な Web API に準拠

- **パターンマッチングベースのルーティング**
  - Gleam の強力なパターンマッチング機能を活用
  - ルーティングロジックを関数として分割可能
  - 型安全なルーティング実装

## Target Use Cases

### Serverless アプリケーション開発
CloudFlare Workers などのエッジ環境で動作する軽量な Web アプリケーションの構築に最適です。hinoto/cli を使用することで、wrangler の設定ファイルを簡単に生成できます。

### マルチランタイム対応アプリケーション
複数の JavaScript ランタイムで動作する必要があるライブラリやフレームワークの基盤として使用できます。ランタイム固有のコードは `hinoto/runtime` 配下に分離されているため、移植性が高いコードを書けます。

### 型安全な Web API 開発
Gleam の強力な型システムを活用して、実行時エラーを最小限に抑えた Web API を開発できます。パターンマッチングを使ったルーティングにより、コンパイル時にルートの整合性を検証できます。

### 軽量な Web サーバー
Node.js、Deno、Bun などのランタイムを使って、シンプルで高速な Web サーバーを構築できます。外部の大規模なフレームワークに依存せず、必要最小限の機能で動作します。

## Key Value Propositions

### Gleam の型安全性と JavaScript エコシステムの融合
Gleam の強力な型システムとコンパイル時検証を活用しながら、JavaScript の豊富なエコシステムとランタイムを利用できます。

### ベンダーロックインの回避
特定のランタイムやクラウドプロバイダーに依存しない設計により、アプリケーションの移植性を確保できます。

### シンプルで予測可能な API
複雑な設定や隠れた機能がなく、明示的で理解しやすい API 設計を採用しています。

### Tree-shaking による最適化
モジュール単位での分割により、未使用のコードがバンドルに含まれず、効率的なデプロイが可能です。

## Inspirations

Hinoto は以下のプロジェクトから影響を受けています：

- **[Hono](https://hono.dev/)** - モダンな Web フレームワークの設計思想
- **[glen](https://hexdocs.pm/glen/)** - Gleam による Web 開発のアプローチ
- **[honojs/node-server](https://github.com/honojs/node-server)** - Node.js ランタイムの実装
