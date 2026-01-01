# Technology Stack - Hinoto

## Architecture

Hinoto は **モジュラーモノリス** アーキテクチャを採用しています：

- **コアモジュール** (`hinoto`): 型定義、リクエスト/レスポンス変換、ハンドラーロジック
- **ランタイムモジュール** (`hinoto/runtime`): 各 JavaScript ランタイム固有の実装と FFI
- **ステータスモジュール** (`hinoto/status`): HTTP ステータスコード関連の機能

### Key Design Decisions

1. **Fetch API 互換性**: 標準的な Web API に準拠することで、学習コストを低減し移植性を向上
2. **ランタイム分離**: ランタイム固有のコードを独立したモジュールに分離し、Tree-shaking を最適化
3. **型駆動設計**: Gleam の型システムを最大限活用し、実行時エラーを最小化
4. **Promise ベース**: JavaScript エコシステムとの統合を容易にするため非同期処理を Promise で実装

## Language & Runtime

### Primary Language
- **Gleam** (target: JavaScript)
  - 強力な型システムと型推論
  - パターンマッチング
  - イミュータブルなデータ構造
  - JavaScript へのコンパイル

### Supported JavaScript Runtimes
- **Node.js** - サーバーサイド JavaScript ランタイム
- **Deno** - セキュアな JavaScript/TypeScript ランタイム
- **Bun** - 高速な JavaScript ランタイム
- **CloudFlare Workers** - エッジコンピューティングプラットフォーム
- **WinterJS** - Rust ベースの軽量 JavaScript ランタイム

## Dependencies

### Core Dependencies

```toml
gleam_stdlib = ">= 0.44.0 and < 2.0.0"
gleam_javascript = ">= 1.0.0 and < 2.0.0"
gleam_http = ">= 4.1.1 and < 5.0.0"
```

- **[gleam_stdlib](https://hexdocs.pm/gleam_stdlib)**: Gleam 標準ライブラリ
- **[gleam_javascript](https://hexdocs.pm/gleam_javascript)**: JavaScript FFI とプリミティブ型のサポート
- **[gleam_http](https://hexdocs.pm/gleam_http)**: HTTP リクエスト/レスポンスの型定義

### External Runtime Dependencies

- **[@hono/node-server](https://github.com/honojs/node-server)** (Node.js runtime)
  - Node.js での HTTP サーバー実装に使用
  - NPM/Yarn/PNPM などのパッケージマネージャーでインストール

### Development Dependencies

```toml
gleeunit = ">= 1.0.0 and < 2.0.0"
```

- **[gleeunit](https://hexdocs.pm/gleeunit)**: Gleam 用のテストフレームワーク

### Optional Tools

- **[wrangler](https://developers.cloudflare.com/workers/wrangler/)**: CloudFlare Workers 開発ツール
- **[hinoto_cli](https://github.com/Comamoca/hinoto_cli)**: Hinoto プロジェクトのセットアップを簡略化する CLI ツール

## Development Environment

### Required Tools

1. **Gleam Compiler** (最新版推奨)
   ```sh
   # インストール方法は https://gleam.run/getting-started/ を参照
   ```

2. **JavaScript Runtime** (いずれか一つ以上)
   - Node.js (v18 以降推奨)
   - Deno (v1.40 以降推奨)
   - Bun (v1.0 以降推奨)

3. **パッケージマネージャー** (Node.js を使用する場合)
   - npm / yarn / pnpm のいずれか

### Optional Tools

- **wrangler**: CloudFlare Workers での開発に必要
  ```sh
  npm install -g wrangler
  ```

- **Nix/Devenv**: 開発環境の再現性を確保するため (プロジェクトに `flake.nix` が含まれている)

## Common Commands

### Build & Development

```sh
# プロジェクトのビルド
gleam build

# TypeScript 型定義の生成
gleam build --target javascript

# コードフォーマット
gleam format

# フォーマットチェック（CI 用）
gleam format --check

# テスト実行
gleam test

# ドキュメント生成
gleam docs build
```

### Runtime-Specific Commands

```sh
# Node.js でサーバーを起動
gleam run

# Deno でサーバーを起動
gleam run --target javascript --runtime deno

# Bun でサーバーを起動
gleam run --target javascript --runtime bun
```

### CloudFlare Workers Development

```sh
# プロジェクトの初期化
gleam add hinoto hinoto_cli
gleam run -m hinoto/cli -- workers init

# 開発サーバーの起動
wrangler dev

# デプロイ
wrangler deploy
```

## Environment Variables

### Development
現在、Hinoto コア自体は環境変数を必要としませんが、アプリケーション開発時には以下のような変数を使用することがあります：

- `PORT`: サーバーのリスニングポート (デフォルト: ランタイムに依存)
- `HOST`: サーバーのバインドアドレス (デフォルト: `0.0.0.0` または `localhost`)

### CloudFlare Workers
`wrangler.toml` で環境変数とシークレットを管理します。

## Port Configuration

### Default Ports by Runtime

- **Node.js**: 通常 3000 (アプリケーションで指定可能)
- **Deno**: 通常 8000 (アプリケーションで指定可能)
- **Bun**: 通常 3000 (アプリケーションで指定可能)
- **CloudFlare Workers**: エッジネットワークが管理 (443/80)

### Example Configuration

各ランタイムの `serve` 関数でポートとホストを指定できます：

```gleam
// Node.js の例
node.serve(
  hinoto.fetch(handler),
  Some(3000),  // ポート
  Some("0.0.0.0")  // ホスト
)
```

## Build & Deploy Strategy

### Local Development
1. Gleam でコードを記述
2. `gleam build` でビルド
3. ランタイムでテスト実行
4. `gleam test` でユニットテスト

### Production Build
1. `gleam build --target javascript` で JavaScript を生成
2. 必要に応じてバンドラー（esbuild、Rollup など）で最適化
3. 各ランタイムまたはプラットフォームにデプロイ

### CloudFlare Workers
1. `wrangler dev` で開発
2. `wrangler deploy` でデプロイ
3. Wrangler が自動的にビルドとバンドルを実行

## Testing Strategy

- **ユニットテスト**: `gleeunit` を使用
- **統合テスト**: 各ランタイムでの実行テスト
- **型検証**: Gleam コンパイラによる静的型チェック

## FFI (Foreign Function Interface)

各ランタイム用の FFI コードは `.mjs` ファイルで実装されています：

- `ffi.node.mjs` - Node.js 固有の機能
- `ffi.deno.mjs` - Deno 固有の機能
- `ffi.bun.mjs` - Bun 固有の機能
- `ffi.workers.mjs` - CloudFlare Workers 固有の機能
- `ffi.winterjs.mjs` - WinterJS 固有の機能

FFI は最小限に抑えられ、ランタイム固有の処理のみを含むよう設計されています。
