import { createHash, randomBytes, randomUUID, timingSafeEqual } from "node:crypto";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { createServer } from "node:http";
import { dirname, resolve } from "node:path";

const port = Number(process.env.PORT || 8787);
const host = process.env.HOST || "0.0.0.0";
const adminToken = process.env.ADMIN_TOKEN;
const maxDevices = Number(process.env.MAX_DEVICES || 2);
const dataFile = resolve(process.env.DATA_FILE || "./data/licenses.json");
const attempts = new Map();

if (!adminToken || adminToken.length < 24) {
  throw new Error("ADMIN_TOKEN must be set and at least 24 characters long");
}

async function loadData() {
  try {
    return JSON.parse(await readFile(dataFile, "utf8"));
  } catch (error) {
    if (error.code !== "ENOENT") throw error;
    return { licenses: {} };
  }
}

async function saveData(data) {
  await mkdir(dirname(dataFile), { recursive: true });
  await writeFile(dataFile, `${JSON.stringify(data, null, 2)}\n`, { mode: 0o600 });
}

function hashKey(key) {
  return createHash("sha256").update(key.trim().toUpperCase()).digest("hex");
}

function generateKey() {
  const parts = Array.from({ length: 4 }, () => randomBytes(3).toString("hex").toUpperCase());
  return `OCEAN-${parts.join("-")}`;
}

function authorized(request) {
  const supplied = request.headers["x-admin-token"] || "";
  const expected = Buffer.from(adminToken);
  const actual = Buffer.from(supplied);
  return actual.length === expected.length && timingSafeEqual(actual, expected);
}

function limited(request) {
  const address = request.socket.remoteAddress || "unknown";
  const now = Date.now();
  const recent = (attempts.get(address) || []).filter((time) => now - time < 60000);
  recent.push(now);
  attempts.set(address, recent);
  return recent.length > 30;
}

async function body(request) {
  let raw = "";
  for await (const chunk of request) {
    raw += chunk;
    if (raw.length > 10000) throw new Error("Request too large");
  }
  return raw ? JSON.parse(raw) : {};
}

function send(response, status, payload) {
  response.writeHead(status, { "content-type": "application/json", "cache-control": "no-store" });
  response.end(JSON.stringify(payload));
}

const server = createServer(async (request, response) => {
  try {
    if (request.method === "OPTIONS") {
      response.writeHead(204, { "access-control-allow-methods": "POST, OPTIONS", "access-control-allow-headers": "content-type, x-admin-token" });
      response.end();
      return;
    }
    if (request.method !== "POST" || limited(request)) {
      send(response, 429, { message: "Request not allowed" });
      return;
    }

    const data = await loadData();
    const input = await body(request);

    if (request.url === "/admin/keys") {
      if (!authorized(request)) return send(response, 401, { message: "Unauthorized" });
      const key = generateKey();
      const licenseId = randomUUID();
      data.licenses[hashKey(key)] = {
        licenseId,
        plan: "Lifetime",
        expiresAt: null,
        devices: [],
        createdAt: new Date().toISOString()
      };
      await saveData(data);
      return send(response, 201, { key, licenseId, plan: "Lifetime" });
    }

    if (request.url === "/v1/activate") {
      const key = typeof input.key === "string" ? input.key : "";
      const deviceId = typeof input.deviceId === "string" ? input.deviceId : "";
      const license = data.licenses[hashKey(key)];
      if (!license || !deviceId) return send(response, 403, { valid: false, message: "Invalid license key" });
      if (!license.devices.includes(deviceId) && license.devices.length >= maxDevices) {
        return send(response, 403, { valid: false, message: "This license has reached its device limit" });
      }
      if (!license.devices.includes(deviceId)) license.devices.push(deviceId);
      await saveData(data);
      return send(response, 200, { valid: true, licenseId: license.licenseId, plan: license.plan, expiresAt: license.expiresAt });
    }

    send(response, 404, { message: "Not found" });
  } catch (error) {
    console.error(error);
    send(response, 400, { message: "Invalid request" });
  }
});

server.listen(port, host, () => {
  console.log(`License server listening on http://${host}:${port}`);
});
