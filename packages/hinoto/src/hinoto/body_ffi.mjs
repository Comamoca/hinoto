/**
 * FFI functions for reading HTTP body content
 *
 * This module provides functions to read body content from JavaScript Request objects
 * and convert them to appropriate Gleam types.
 */

import { Ok, Error } from "../gleam.mjs";
import {
  AlreadyRead,
  ParseError,
  ReadError,
  UnsupportedBodyType,
  RequestBody,
  StringBody,
  BitArrayBody,
  EmptyBody
} from "./body.mjs";
import { BitArray } from "../gleam.mjs";

/**
 * Reads the body content as text (String)
 *
 * @param {Body} body - The body to read (should be RequestBody variant)
 * @returns {Promise<Result<String, BodyReadError>>} Promise resolving to Ok(text) or Error
 */
export async function readText(body) {
  // If body is already a StringBody, return it directly
  if (body instanceof StringBody) {
    return new Ok(body[0]);
  }

  // If body is EmptyBody, return empty string
  if (body instanceof EmptyBody) {
    return new Ok("");
  }

  // If body is RequestBody, read from the Request object
  if (body instanceof RequestBody) {
    const req = body[0];

    // Check if body has already been used
    if (req.bodyUsed) {
      return new Error(new AlreadyRead());
    }

    try {
      const text = await req.text();
      return new Ok(text);
    } catch (e) {
      return new Error(new ReadError(e.message));
    }
  }

  // Unsupported body type for text reading
  return new Error(
    new UnsupportedBodyType(
      `Cannot read text from body type: ${body.constructor.name}`
    )
  );
}

/**
 * Reads the body content as binary data (BitArray)
 *
 * @param {Body} body - The body to read (should be RequestBody variant)
 * @returns {Promise<Result<BitArray, BodyReadError>>} Promise resolving to Ok(bits) or Error
 */
export async function readBits(body) {
  // If body is already a BitArrayBody, return it directly
  if (body instanceof BitArrayBody) {
    return new Ok(body[0]);
  }

  // If body is EmptyBody, return empty BitArray
  if (body instanceof EmptyBody) {
    return new Ok(new BitArray(new Uint8Array(0)));
  }

  // If body is RequestBody, read from the Request object
  if (body instanceof RequestBody) {
    const req = body[0];

    // Check if body has already been used
    if (req.bodyUsed) {
      return new Error(new AlreadyRead());
    }

    try {
      const arrayBuffer = await req.arrayBuffer();
      const uint8Array = new Uint8Array(arrayBuffer);
      return new Ok(new BitArray(uint8Array));
    } catch (e) {
      return new Error(new ReadError(e.message));
    }
  }

  // Unsupported body type for binary reading
  return new Error(
    new UnsupportedBodyType(
      `Cannot read bits from body type: ${body.constructor.name}`
    )
  );
}

/**
 * Reads the body content as JSON
 *
 * @param {Body} body - The body to read (should be RequestBody variant)
 * @returns {Promise<Result<Dynamic, BodyReadError>>} Promise resolving to Ok(json) or Error
 */
export async function readJson(body) {
  // If body is EmptyBody, return error
  if (body instanceof EmptyBody) {
    return new Error(new ParseError("Cannot parse JSON from empty body"));
  }

  // If body is RequestBody, read from the Request object
  if (body instanceof RequestBody) {
    const req = body[0];

    // Check if body has already been used
    if (req.bodyUsed) {
      return new Error(new AlreadyRead());
    }

    try {
      const json = await req.json();
      return new Ok(json);
    } catch (e) {
      // JSON parsing error or read error
      if (e instanceof SyntaxError) {
        return new Error(new ParseError(e.message));
      }
      return new Error(new ReadError(e.message));
    }
  }

  // If body is StringBody, try to parse it as JSON
  if (body instanceof StringBody) {
    try {
      const json = JSON.parse(body[0]);
      return new Ok(json);
    } catch (e) {
      return new Error(new ParseError(e.message));
    }
  }

  // Unsupported body type for JSON reading
  return new Error(
    new UnsupportedBodyType(
      `Cannot read JSON from body type: ${body.constructor.name}`
    )
  );
}
