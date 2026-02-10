import { UqClient, KeyPair, sync } from "./index.js";

export interface LoggerOptions {
  client: UqClient;
  identity: KeyPair;
  /**
   * Topic for log events. Defaults to "client_logs" (UTF-8 bytes).
   */
  topic?: Uint8Array;
}

/**
 * Built-in error reporting and logging to the server.
 */
export class UqLogger {
  private client: UqClient;
  private identity: KeyPair;
  private topic: Uint8Array;
  private encoder = new TextEncoder();

  constructor(options: LoggerOptions) {
    this.client = options.client;
    this.identity = options.identity;
    this.topic = options.topic || this.encoder.encode("client_logs");
  }

  /**
   * Sends a log message to the backend.
   * @param level The log level (e.g., 'ERROR', 'WARN', 'INFO').
   * @param message The message to log.
   */
  async log(level: string, message: string) {
    if (!navigator.onLine) {
        return;
    }
    
    const logData = { level, message, timestamp: new Date().toISOString() };
    const payload = this.encoder.encode(JSON.stringify(logData));

    try {
      // Use max uint64 (approx) for since to avoid fetching events, just push
      // 9223372036854775807n is max int64
      await sync(this.client, 9223372036854775807n, this.identity.publicKey, {
        topicPk: this.topic,
        payload,
        author: this.identity,
      });
    } catch (error) {
      // Fallback to console if network logging fails
      console.error("Failed to send log to server:", error);
    }
  }

  /**
   * Formats an error object into a string.
   */
  formatError(error: unknown): string {
    if (error instanceof Error && error.stack) {
      return error.stack;
    }
    return String(error);
  }

  /**
   * Hooks into the global window error handlers (onerror, unhandledrejection)
   * to automatically log uncaught errors.
   */
  installGlobalHandlers() {
    if (typeof window === "undefined") return;

    window.addEventListener("error", (event: ErrorEvent) => {
      this.log("ERROR", this.formatError(event.error));
    });

    window.addEventListener("unhandledrejection", (event: PromiseRejectionEvent) => {
      this.log("ERROR", this.formatError(event.reason));
    });

    console.log("UqLogger global handlers installed.");
  }
}
