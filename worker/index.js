
export default {
    async fetch(request, env) {
        const url = new URL(request.url);

        // Endpoint: GET /api/insults
        if (url.pathname === '/api/insults') {
            try {
                // 1. Try to get from R2
                if (env.EVA_QUOTES) {
                    const object = await env.EVA_QUOTES.get('insults.json');
                    if (object) {
                        const headers = new Headers();
                        object.writeHttpMetadata(headers);
                        headers.set('etag', object.httpEtag);
                        return new Response(object.body, { headers });
                    }
                }

                // 2. Fallback (if R2 not bound or empty): Return static error or local list
                // In a real deployed worker, we can't easily access local assets unless they are bundled.
                // We'll return a basic JSON list so the app doesn't crash if it fetches this.
                return new Response(JSON.stringify([
                    "R2 DISCONNECTED. USING LOCAL FALLBACK.",
                    "SYSTEM OFFLINE.",
                    "YOU ARE STILL WEAK."
                ]), {
                    headers: { 'content-type': 'application/json' }
                });

            } catch (e) {
                return new Response(`Error: ${e.message}`, { status: 500 });
            }
        }

        // Default
        return new Response("EVA SYSTEM WORKER. ENDPOINT NOT FOUND.", { status: 404 });
    }
};
