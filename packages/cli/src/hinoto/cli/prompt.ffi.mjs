import { readSync } from 'node:fs';

// Runtime detection
const isNode = typeof process !== 'undefined' && process.versions && process.versions.node;
const isDeno = typeof Deno !== 'undefined';
const isBun = typeof Bun !== 'undefined';

// Prompt function for text input
export function prompt(message) {
  if (isDeno) {
    return promptDeno(message);
  } else if (isBun) {
    return promptBun(message);
  } else if (isNode) {
    return promptNode(message);
  } else {
    throw new Error('Unsupported runtime environment');
  }
}

// Confirmation prompt function (y/n)
export function confirm(message) {
  if (isDeno) {
    // Use Deno's built-in confirm function
    return globalThis.confirm(message);
  } else {
    const response = prompt(message + ' (y/N): ').toLowerCase().trim();
    return response === 'y' || response === 'yes';
  }
}

// Node.js implementation using synchronous readline
function promptNode(message) {
  process.stdout.write(message);

  let input = '';
  const fd = process.stdin.fd;
  const buffer = Buffer.alloc(1);

  while (true) {
    try {
      const bytesRead = readSync(fd, buffer, 0, 1, null);
      if (bytesRead === 0) break;

      const char = buffer.toString('utf8');
      if (char === '\n' || char === '\r') break;

      input += char;
    } catch (error) {
      if (error.code === 'EAGAIN' || error.code === 'EWOULDBLOCK') {
        // Resource temporarily unavailable, try again after a short delay
        continue;
      }
      throw error;
    }
  }

  return input.trim();
}

// Deno implementation
function promptDeno(message) {
  // Use Deno's built-in prompt function
  const result = globalThis.prompt(message);
  // Return empty string if user cancels (result is null)
  return result || '';
}

function promptPasswordDeno(message) {
  const encoder = new TextEncoder();
  Deno.stderr.writeSync(encoder.encode(message));

  const buf = new Uint8Array(1024);
  const n = Deno.stdin.readSync(buf);
  const decoder = new TextDecoder();
  return decoder.decode(buf.subarray(0, n)).trim();
}

// Bun implementation
function promptBun(message) {
  process.stdout.write(message);

  const fd = process.stdin.fd;
  const buffer = Buffer.alloc(1024);
  const bytesRead = readSync(fd, buffer, 0, buffer.length, null);

  return buffer.toString('utf8', 0, bytesRead).trim();
}
