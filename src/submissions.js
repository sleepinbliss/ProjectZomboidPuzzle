const environment = import.meta.env ?? {};

export async function saveSubmission(answer) {
    if (!/^[A-Za-z]{8}$/.test(answer)) {
        throw new Error('Enter exactly 8 letters.');
    }
    const projectUrl = environment.VITE_SUPABASE_URL;
    const publishableKey = environment.VITE_SUPABASE_PUBLISHABLE_KEY;
    if (!projectUrl || !publishableKey) {
        throw new Error('Submissions are unavailable. Please try again later.');
    }
    const response = await fetch(`${projectUrl.replace(/\/$/, '')}/rest/v1/submissions`, {
        method: 'POST',
        headers: {
            apikey: publishableKey,
            'Content-Type': 'application/json',
            Prefer: 'return=minimal',
        },
        body: JSON.stringify({ answer }),
    });
    if (!response.ok) {
        throw new Error('Could not save your answer. Please try again.');
    }
}