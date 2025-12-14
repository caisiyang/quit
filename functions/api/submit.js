export async function onRequestPost(context) {
    const { request, env } = context;

    try {
        const body = await request.json();
        const newInsult = body.text;

        if (!newInsult || newInsult.length > 50) {
            return new Response("Invalid Input", { status: 400 });
        }

        let communityData = [];

        // 1. Read existing community data
        if (env.EVA_QUOTES) {
            const object = await env.EVA_QUOTES.get('community.json');
            if (object) {
                communityData = await object.json();
            }
        }

        // 2. Append new insult
        // Limit total community insults to prevent abuse/bloat (e.g. 1000)
        if (communityData.length > 1000) {
            communityData.shift(); // Remove oldest
        }
        communityData.push(newInsult);

        // 3. Write back to R2
        if (env.EVA_QUOTES) {
            await env.EVA_QUOTES.put('community.json', JSON.stringify(communityData));
        }

        return new Response(JSON.stringify({ success: true, count: communityData.length }), {
            headers: { 'content-type': 'application/json' }
        });

    } catch (e) {
        return new Response(JSON.stringify({ error: e.message }), {
            status: 500,
            headers: { 'content-type': 'application/json' }
        });
    }
}
