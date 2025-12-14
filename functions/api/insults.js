export async function onRequest(context) {
    const { env } = context;

    try {
        // 1. Try to get from R2
        if (env.EVA_QUOTES) {
            const object = await env.EVA_QUOTES.get('insults.json');

            if (object) {
                const headers = new Headers();
                object.writeHttpMetadata(headers);
                headers.set('etag', object.httpEtag);
                // Ensure content-type is json
                headers.set('content-type', 'application/json');
                return new Response(object.body, { headers });
            }
        }

        // 2. Fallback (if R2 is empty or not bound)
        return new Response(JSON.stringify([
            "R2 DISCONNECTED. USING LOCAL FALLBACK.",
            "SYSTEM OFFLINE.",
            "YOU ARE STILL WEAK."
        ]), {
            headers: { 'content-type': 'application/json' }
        });

    } catch (e) {
        return new Response(JSON.stringify({ error: e.message }), {
            status: 500,
            headers: { 'content-type': 'application/json' }
        });
    }
}
