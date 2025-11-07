import { Ok, Error } from "../../gleam.mjs"

export function env_get(env, key) {
    if (!env || !(key in env)) {
	return Promise.resolve(new Error(undefined))
    } else {
	return Promise.resolve(new Ok(env[key]))
    }
}

export function env_set(env, key, value) {
    if (!env) {
	return Promise.resolve(new Error(undefined))
    } else {
	env[key] = value
	return Promise.resolve(new Ok(undefined))
    }
}
