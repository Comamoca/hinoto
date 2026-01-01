# Project Structure - Hinoto

## Root Directory Organization

```
hinoto/
├── src/                  # ソースコード
├── test/                 # テストコード
├── example/              # サンプル実装
├── docs/                 # ドキュメント
├── build/                # ビルド成果物（自動生成）
├── .kiro/                # Kiro 仕様管理
├── .claude/              # Claude Code 設定
├── .serena/              # Serena エージェント設定
├── gleam.toml            # Gleam プロジェクト設定
├── manifest.toml         # 依存関係ロックファイル
├── flake.nix             # Nix 開発環境設定
└── README.md             # プロジェクト概要
```

### Key Directories

- **`src/`**: すべての Gleam ソースコード
- **`test/`**: ユニットテストと統合テスト
- **`example/`**: 各ランタイム向けのサンプルアプリケーション
- **`docs/`**: ユーザー向けドキュメント（Markdown）
- **`build/`**: Gleam コンパイラが生成する JavaScript と型定義
- **`.kiro/`**: Spec-Driven Development のための仕様とステアリング
- **`.claude/`**: Claude Code のスラッシュコマンド定義

## Source Code Structure (`src/`)

### Core Module Layout

```
src/
├── hinoto.gleam              # コアモジュール - 主要な型定義とハンドラーロジック
├── hinoto/
│   ├── runtime/              # ランタイム固有の実装
│   │   ├── README.md         # ランタイムモジュールのドキュメント
│   │   ├── node.gleam        # Node.js サポート
│   │   ├── deno.gleam        # Deno サポート
│   │   ├── bun.gleam         # Bun サポート
│   │   ├── workers.gleam     # CloudFlare Workers サポート
│   │   ├── winterjs.gleam    # WinterJS サポート
│   │   ├── ffi.node.mjs      # Node.js FFI
│   │   ├── ffi.deno.mjs      # Deno FFI
│   │   ├── ffi.bun.mjs       # Bun FFI
│   │   ├── ffi.workers.mjs   # CloudFlare Workers FFI
│   │   ├── ffi.winterjs.mjs  # WinterJS FFI
│   │   └── workers/          # Workers 固有のサブモジュール
│   └── status.gleam          # HTTP ステータスコード関連
```

### Module Responsibilities

#### `hinoto.gleam` (Core Module)
- **Hinoto 型**: リクエスト、レスポンス、コンテキストを含む主要な型
- **handle 関数**: ハンドラーロジックの実装
- **fetch 関数**: Fetch API 互換のエントリーポイント
- **型変換**: JavaScript Request/Response と Gleam 型の相互変換

#### `hinoto/runtime/*.gleam` (Runtime Modules)
各ランタイム用のモジュールは以下の責務を持ちます：
- **serve 関数**: サーバーの起動とリスニング
- **ランタイム固有の設定**: ポート、ホスト、その他のオプション
- **FFI とのブリッジ**: Gleam コードと JavaScript FFI の接続

#### `hinoto/runtime/ffi.*.mjs` (FFI Files)
各 FFI ファイルは以下を実装します：
- **サーバー起動**: ランタイム固有の HTTP サーバー作成
- **リクエスト処理**: ランタイム API と Fetch API の橋渡し
- **エラーハンドリング**: ランタイム固有のエラー処理

#### `hinoto/status.gleam` (Status Module)
- HTTP ステータスコードの定義
- ステータス関連のユーティリティ関数

## Test Structure (`test/`)

```
test/
├── hinoto_test.gleam         # コアモジュールのユニットテスト
└── integration_test.gleam    # ランタイム統合テスト
```

### Testing Approach
- **ユニットテスト**: 個々の関数とモジュールの動作を検証
- **統合テスト**: 各ランタイムでの実際の動作を検証
- **型テスト**: Gleam の型システムによるコンパイル時検証

## Example Structure (`example/`)

```
example/
├── README.md                 # サンプルの概要
├── node_server/              # Node.js サンプル
│   ├── src/
│   │   └── node_server.gleam
│   ├── gleam.toml
│   └── package.json
├── deno_server/              # Deno サンプル
│   ├── src/
│   │   └── deno_server.gleam
│   └── gleam.toml
├── bun_server/               # Bun サンプル
│   ├── src/
│   │   └── bun_server.gleam
│   ├── gleam.toml
│   └── package.json
└── workers/                  # CloudFlare Workers サンプル
    ├── src/
    │   ├── workers.gleam
    │   └── index.js          # Workers エントリーポイント
    ├── gleam.toml
    └── wrangler.toml
```

### Example Organization
各サンプルは独立した Gleam プロジェクトとして構成され、以下を含みます：
- **`src/`**: サンプルアプリケーションのコード
- **`gleam.toml`**: プロジェクト設定（hinoto への依存を含む）
- **ランタイム固有の設定**: `package.json` (Node.js/Bun) または `wrangler.toml` (Workers)

## Documentation Structure (`docs/`)

```
docs/
├── concepts.md               # 設計概念とアーキテクチャ
└── quickstart.md             # クイックスタートガイド
```

### Documentation Philosophy
- **concepts.md**: Hinoto の設計思想、Hinoto 型、ハンドラー、ルーティングの概念を説明
- **quickstart.md**: 各ランタイムでの実際のセットアップ手順とサンプルコード

## Code Organization Patterns

### Module Hierarchy
```
hinoto                        # Public API
└── hinoto/runtime            # Runtime-specific implementations (also public)
    └── hinoto/runtime/workers # Internal submodules (may be private)
```

### Import Organization
Gleam の慣習に従い、import は以下の順序で記述します：

1. **標準ライブラリ**: `gleam/option`, `gleam/result` など
2. **外部依存**: `gleam_http`, `gleam_javascript` など
3. **プロジェクト内モジュール**: `hinoto`, `hinoto/runtime/node` など

例：
```gleam
import gleam/javascript/promise
import gleam/option.{None, Some}
import gleam/http/request
import gleam/http/response
import conversation.{Text}
import hinoto
import hinoto/runtime/node
```

### Type-First Design
型定義を先に行い、実装を後から追加するアプローチを採用：

1. **型定義**: `pub type Hinoto(context) { ... }`
2. **関数シグネチャ**: `pub fn handle(hinoto: Hinoto(ctx), handler: Handler(ctx)) -> Hinoto(ctx)`
3. **実装**: 関数本体の記述

## File Naming Conventions

### Gleam Files
- **スネークケース**: `hinoto.gleam`, `node_server.gleam`
- **モジュール名と一致**: ファイル名 `node.gleam` → モジュール名 `hinoto/runtime/node`

### FFI Files
- **プレフィックス `ffi.`**: `ffi.node.mjs`, `ffi.workers.mjs`
- **拡張子 `.mjs`**: ES Module として認識されるよう `.mjs` を使用

### Documentation Files
- **小文字ケバブケース**: `quickstart.md`, `concepts.md`
- **明確な名称**: ファイル名から内容が推測できること

## Key Architectural Principles

### 1. Runtime Isolation
ランタイム固有のコードは `hinoto/runtime` 配下に分離し、コアモジュールはランタイムに依存しない設計。

### 2. Minimal FFI
FFI の使用を最小限に抑え、可能な限り Gleam で実装。FFI は各ランタイムの固有機能にのみ使用。

### 3. Module-First
機能をモジュール単位で分割し、Tree-shaking による最適化を可能に。ユーザーは必要なモジュールのみをインポート。

### 4. Type Safety
Gleam の型システムを活用し、実行時エラーを最小化。すべての公開 API は明確な型シグネチャを持つ。

### 5. Functional Design
イミュータブルなデータ構造と純粋関数を優先。副作用は明示的に `Promise` などで表現。

### 6. Explicit Over Implicit
暗黙的な動作や隠れた設定を避け、すべてを明示的に記述。ユーザーがコードの動作を理解しやすい設計。

## Build Artifacts (`build/`)

```
build/
└── dev/
    └── javascript/
        └── hinoto/
            ├── hinoto.mjs            # コンパイル済み JavaScript
            ├── hinoto.d.mts          # TypeScript 型定義
            └── hinoto/               # サブモジュール
                └── runtime/
                    ├── node.mjs
                    ├── node.d.mts
                    └── ...
```

### Build Output
- **`.mjs` ファイル**: ES Module 形式の JavaScript
- **`.d.mts` ファイル**: TypeScript 型定義
- **ディレクトリ構造**: `src/` の構造を反映

## Configuration Files

### `gleam.toml`
プロジェクトのメタデータ、依存関係、ドキュメント設定を定義。

### `manifest.toml`
依存関係のバージョンロックファイル（自動生成）。

### `flake.nix`
Nix による開発環境の再現性を確保。

## Development Workflow

1. **機能追加**: `src/` にコードを追加
2. **テスト作成**: `test/` にテストを追加
3. **ビルド検証**: `gleam build` で型チェックとビルド
4. **テスト実行**: `gleam test` でテスト
5. **サンプル更新**: 必要に応じて `example/` を更新
6. **ドキュメント更新**: `docs/` と `README.md` を更新
