import { main } from "./workers.mjs";

export default {
  async fetch(req, env, ctx) {
    return await main()(req, ctx);
  },
};
