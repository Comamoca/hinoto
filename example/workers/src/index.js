import * as hinoto from "../hinoto/hinoto.mjs";
import { main } from "./workers.mjs";

export default {
  async fetch(req, env, ctx) {
      return await hinoto.handle_request(req, { env, ctx }, main);
  },
};
