# Project Zomboid Puzzle

## Submission Storage

Valid eight-letter answers are saved to Supabase before the existing local answer
feedback is shown. Only the submitted answer and a database-generated timestamp
are stored. Invalid entries are not saved. A failed save shows an error and can
be retried; the form prevents concurrent submissions while a request is pending.
The form also displays the number of attempts used from the hourly IP-based limit.

### Set Up Supabase

1. Create a project at https://supabase.com/dashboard.
2. Open the project's SQL Editor and run [supabase/schema.sql](supabase/schema.sql).
   It creates the `submissions` table and enables row-level security. Run the
   script again after pulling updates to apply schema changes to an existing
   project.
3. In a separate SQL Editor query, set the correct answer in the private
   database table. Replace `xxxxxxxx` with the eight-letter answer;
   do not put the real answer in this repository or frontend environment:

   ```sql
   insert into private.puzzle_answer (id, answer)
   values (true, 'xxxxxxxx')
   on conflict (id) do update set answer = excluded.answer;
   ```

4. Find the project URL and **publishable** API key in the project's Connect
   dialog or Settings / API Keys. Never use a secret or `service_role` key.
5. Create `.env.local` in the project root using [.env.example](.env.example) as
   the template, and enter the URL and publishable key there. Restart the Vite
   development server after changing environment settings.
6. Submit an eight-letter answer, then open Supabase's Table Editor and select
   `submissions`. Sort `submitted_at` descending to see the newest attempts.
   The timestamp represents the server time, independent of the visitor's clock.

### GitHub Pages

In the GitHub repository's Settings / Secrets and variables / Actions / Variables,
add these repository variables:

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_PUBLISHABLE_KEY`

Run the Pages deployment workflow again after setting or changing them. Vite
embeds these public settings in the built site; they are not admin credentials.

### Access And Rate Limiting

Anonymous visitors submit guesses through a database function, which checks the
answer stored in the non-exposed `private.puzzle_answer` table and returns only
whether the guess is correct. They cannot directly insert, select, update, or
delete submissions, or read the correct answer. View submissions through your
authenticated Supabase dashboard. Do not add public read policies or place
privileged database keys in frontend code.

The database permits at most 20 attempts per IP address in each UTC clock hour.
The limit is enforced on inserts, including direct API requests, and the
rate-limit records are not accessible to anonymous visitors. Supabase request
headers must include a client address in `cf-connecting-ip`, `x-real-ip`, or
`x-forwarded-for`; inserts without a usable address are rejected. This rate
limit is not CAPTCHA or broader bot protection. Network failures can also make
a retry create a duplicate if the first insert reached the server before its
response was lost.

The `ucheated` easter egg remains in the browser. The real answer is checked
case-insensitively by the database and is not included in frontend code.

## Development

```sh
npm install
npm run dev
```

```sh
npm run build
```
