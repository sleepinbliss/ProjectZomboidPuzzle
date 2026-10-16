const environment = import.meta.env ?? {};
const hourlyLimit = 20;

function getSupabaseConfig() {
    const projectUrl = environment.VITE_SUPABASE_URL;
    const publishableKey = environment.VITE_SUPABASE_PUBLISHABLE_KEY;
    if (!projectUrl || !publishableKey) {
        throw new Error('Submissions are unavailable. Please try again later.');
    }
    return {
        projectUrl: projectUrl.replace(/\/$/, ''),
        publishableKey,
    };
}

export async function getSubmissionAttemptCount() {
    const { projectUrl, publishableKey } = getSupabaseConfig();
    const response = await fetch(`${projectUrl}/rest/v1/rpc/get_submission_attempt_count`, {
        method: 'POST',
        headers: {
            apikey: publishableKey,
            'Content-Type': 'application/json',
        },
        body: '{}',
    });
    if (!response.ok) {
        throw new Error('Could not load the hourly attempt count.');
    }
    const count = await response.json();
    if (!Number.isInteger(count) || count < 0 || count > hourlyLimit) {
        throw new Error('The hourly attempt count was invalid.');
    }
    return count;
}

export async function saveSubmission(answer) {
    if (!/^[A-Za-z]{8}$/.test(answer)) {
        throw new Error('Enter exactly 8 letters.');
    }
    const { projectUrl, publishableKey } = getSupabaseConfig();
    const response = await fetch(`${projectUrl}/rest/v1/submissions`, {
        method: 'POST',
        headers: {
            apikey: publishableKey,
            'Content-Type': 'application/json',
            Prefer: 'return=minimal',
        },
        body: JSON.stringify({ answer }),
    });
    if (!response.ok) {
        const error = await response.json().catch(() => null);
        if (error?.message === 'Hourly submission limit reached') {
            throw new Error('Hourly limit reached (20 submissions). Try again next hour.');
        }
        throw new Error('Could not save your answer. Please try again.');
    }
}