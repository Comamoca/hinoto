import hinoto

/// Cloudflare Workers specific context type.
/// This type is designed to work directly with Cloudflare Workers runtime
/// and provides access to the native env and ctx objects.
// pub type WorkersContext(env, ctx) {
//   WorkersContext(env: env, ctx: ctx)
// }

pub type WorkersContext(env, ctx) {
  WorkersContext(env: hinoto.Environment, ctx: ctx)
}
