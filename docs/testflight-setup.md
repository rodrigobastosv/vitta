# TestFlight setup

One-time setup for the `v*` tag → TestFlight pipeline (`.github/workflows/testflight.yml`).
None of this lives in the repo, and until every step is done the workflow fails.

Once it's green, releasing is just:

```sh
git tag v1.2.3 && git push origin v1.2.3
```

App identity, for reference: bundle id `com.rodrigobastosv.vitta`, Apple team `SDRL4XQA74`.

---

## 1. Register the app (Apple)

1. <https://developer.apple.com/account/resources/identifiers> → **+** → App IDs → App.
   Description `Vitta`, Bundle ID **Explicit** = `com.rodrigobastosv.vitta`.
2. <https://appstoreconnect.apple.com/apps> → **+** → New App. Pick the bundle id from step 1.

Nothing below works before the app record exists — `latest_testflight_build_number` asks
App Store Connect about this app, and it has to be there to answer.

## 2. App Store Connect API key → 3 secrets

Used both to upload and to read the last build number. Needs Admin on the account.

<https://appstoreconnect.apple.com/access/integrations/api> → **Team Keys** tab → **+**.
Name `github-actions`, Access **App Manager** → Generate.

That page gives you all three values:

| GitHub secret | Where |
| --- | --- |
| `APP_STORE_CONNECT_KEY_ID` | The **Key ID** column, e.g. `2X9R4HXF34` |
| `APP_STORE_CONNECT_ISSUER_ID` | **Issuer ID**, shown once above the table, e.g. `57246542-96fe-1a63-e053-0824d011072a` |
| `APP_STORE_CONNECT_KEY_CONTENT` | Download `AuthKey_XXXX.p8` (**one download only**), then base64 it |

```sh
base64 -i ~/Downloads/AuthKey_XXXXXXXXXX.p8 | pbcopy
```

The lane sets `is_key_content_base64: true`, so paste the base64 blob, not the raw file.

## 3. Certificates repo → 3 secrets

`match` keeps the signing certificate and provisioning profile in a **private** git repo,
encrypted with a passphrase. This is the only piece with a chicken-and-egg step: it has to be
seeded from your Mac once, because that's where Apple lets you create a distribution
certificate.

1. Create an **empty private** repo, e.g. `rodrigobastosv/vitta-certificates`.
   It must be private — it holds your distribution certificate.
2. Seed it from this repo's `ios/` directory:

   ```sh
   cd ios
   MATCH_GIT_URL=https://github.com/rodrigobastosv/vitta-certificates.git \
     bundle exec fastlane match appstore
   ```

   It asks for a passphrase and invents one if you let it — **save whatever it uses**, that's
   `MATCH_PASSWORD`. Run this before the first release; CI is `readonly: true` and will fail
   rather than create a certificate itself.

3. Create a token that can read that repo:
   <https://github.com/settings/personal-access-tokens/new> → Repository access: only
   `vitta-certificates` → **Contents: Read-only** (CI only ever reads). Copy the
   `github_pat_...`, it's shown once.

| GitHub secret | Value |
| --- | --- |
| `MATCH_GIT_URL` | `https://github.com/rodrigobastosv/vitta-certificates.git` |
| `MATCH_PASSWORD` | The passphrase from step 2 |
| `MATCH_GIT_BASIC_AUTHORIZATION` | base64 of `user:token`, see below |

`MATCH_GIT_BASIC_AUTHORIZATION` is an HTTP Basic header, which is why `MATCH_GIT_URL` has to
be `https://` and not SSH:

```sh
printf 'rodrigobastosv:github_pat_XXXX' | base64 | pbcopy
```

**`printf`, not `echo`.** `echo` appends a newline, the newline gets encoded, and the header
is then quietly wrong — git fails with a bare `403` that says nothing about base64. (macOS
`base64` doesn't wrap long lines, so nothing else is needed here; GNU `base64` on Linux wraps
at 76 columns and would want `| tr -d '\n'`.)

## 4. App credentials → 3 secrets

`.env` is a bundled asset and gitignored, so CI rebuilds it from these. They're the same
values as your local `.env` — the build ships unable to reach Supabase without them, so the
workflow fails fast on an empty one.

| GitHub secret | Where |
| --- | --- |
| `SUPABASE_URL` | Supabase dashboard → Project Settings → API → Project URL |
| `SUPABASE_PUBLISHABLE_KEY` | same page → publishable / anon public key |
| `SENTRY_DSN` | Sentry → Settings → Projects → (project) → Client Keys (DSN) |

## 5. Add them all

<https://github.com/rodrigobastosv/vitta/settings/secrets/actions> → New repository secret,
nine in total:

```
APP_STORE_CONNECT_KEY_ID
APP_STORE_CONNECT_ISSUER_ID
APP_STORE_CONNECT_KEY_CONTENT
MATCH_GIT_URL
MATCH_PASSWORD
MATCH_GIT_BASIC_AUTHORIZATION
SUPABASE_URL
SUPABASE_PUBLISHABLE_KEY
SENTRY_DSN
```

---

## Notes

- **The tag sets the version.** `v1.2.3` ships as `1.2.3`; the build number is whatever
  TestFlight last saw, plus one. `pubspec.yaml`'s `version:` is only a local-build default and
  the lane never reads it. A tag that isn't `vX.Y.Z` is rejected in seconds.
- **Don't delete the certificates repo.** Losing it means revoking and re-issuing the
  distribution certificate.
- **Rerunning a tag** re-uploads with a *new* build number, which is fine — build numbers are
  what App Store Connect dedupes on, not the version.
