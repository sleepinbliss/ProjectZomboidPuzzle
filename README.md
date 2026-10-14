# Project Zomboid Puzzle

## Submission Storage

Valid eight-letter answers are saved to Supabase before the existing local answer
feedback is shown. Only the submitted answer and a database-generated timestamp
are stored. Invalid entries are not saved. A failed save shows an error and can
be retried; the form prevents concurrent submissions while a request is pending.

### Set Up Supabase

1. Create a project at https://supabase.com/dashboard.
2. Open the project's SQL Editor and run [supabase/schema.sql](supabase/schema.sql)
   once. It creates the `submissions` table and enables row-level security.
3. Find the project URL and **publishable** API key in the project's Connect
   dialog or Settings / API Keys. Never use a secret or `service_role` key.
4. Create `.env.local` in the project root using [.env.example](.env.example) as
   the template, and enter the URL and publishable key there. Restart the Vite
   development server after changing environment settings.
5. Submit an eight-letter answer, then open Supabase's Table Editor and select
   `submissions`. Sort `submitted_at` descending to see the newest attempts.
   The timestamp represents the server time, independent of the visitor's clock.

### GitHub Pages

In the GitHub repository's Settings / Secrets and variables / Actions / Variables,
add these repository variables:

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_PUBLISHABLE_KEY`

Run the Pages deployment workflow again after setting or changing them. Vite
embeds these public settings in the built site; they are not admin credentials.

### Access And Limitations

Anonymous visitors can insert only the `answer` column. They cannot select,
update, or delete submissions, and cannot supply the database timestamp. View
submissions through your authenticated Supabase dashboard. Do not add public
read policies or place privileged database keys in frontend code.

This direct insert endpoint is public and does not provide per-visitor rate
limiting or bot protection. Before exposing it to heavy traffic, route inserts
through a backend or Edge Function with server-side rate limiting and CAPTCHA
verification. A malicious visitor can bypass client-side controls. Network
failures can also make a retry create a duplicate if the first insert reached
the server before its response was lost.

Answer checking remains in the browser, including the existing case-insensitive
match and alert. This integration does not hide the answer or change the puzzle's
global status.

## Development

```sh
npm install
npm run dev
```

```sh
npm run build
```
