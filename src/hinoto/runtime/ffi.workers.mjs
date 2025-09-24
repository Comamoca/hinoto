import { Ok, Error } from "../../gleam.mjs"

export function env_get(env, key) {
    if (!env || !(key in env)) {
	return new Error(undefined)
    } else {
	return new Ok(env[key])
    }
}

export function  env_set(env, key, value) {    
    const getEnv = env_get(env, key)
    if (!getEnv) {	
	return new Error(undefined)
    } else {
	getEnv.set(value)
	return Ok(undefined)
    }
}
