import { Result$Ok, Result$Error } from "../../gleam.mjs"

export function env_get(env, key) {
    if (!env || !(key in env)) {
	return Promise.resolve(Result$Error(undefined))
    } else {
	return Promise.resolve(Result$Ok(env[key]))
    }
}

export function env_set(env, key, value) {
    if (!env) {
	return Promise.resolve(Result$Error(undefined))
    } else {
	env[key] = value
	return Promise.resolve(Result$Ok(undefined))
    }
}
