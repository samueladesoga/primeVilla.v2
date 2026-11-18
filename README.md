# Prime Villa (SS Hall)

A small Rails 8 app for running the SS Hall hostel: rooms, tenants and tenancies,
with automatic rent-due and overdue reminder emails.

- **Admins** see a dashboard of overdue, expiring and vacant rooms, create tenants,
  assign rooms, renew tenancies when rent is paid, and end tenancies.
- **Tenants** see their current room, tenancy dates and status, how to pay rent,
  and can update their contact details and password.

## Requirements

- Ruby 3.4 (see `Dockerfile`)
- SQLite 3

## Setup

```sh
bundle install
bin/rails db:prepare
bin/rails user:create_admin   # prompts for an admin email and password
bin/dev                       # web server, Tailwind watcher and Solid Queue worker
```

Then open http://localhost:3000 and log in as the admin.

`config/master.key` must match `config/credentials.yml.enc`; the app reads the
SendGrid API key and the Mission Control (`/jobs`) basic-auth login from credentials.

## Configuration

Hostel details used on the tenant page and in emails can be overridden with
environment variables (defaults are in `config/initializers/hostel.rb`):

| Variable | Purpose |
| --- | --- |
| `HOSTEL_NAME`, `HOSTEL_WEBSITE` | Email signature |
| `ADMIN_EMAIL` | Copied (bcc) on rent reminder emails |
| `BANK_ACCOUNT_NAME`, `BANK_NAME`, `BANK_ACCOUNT_NUMBER` | Where tenants pay rent |
| `ROOT_URL` | Host used in email links |

## Typical admin workflow

1. **+ New tenant**: enter their details. They're emailed a link to set their own
   password (valid for 7 days), and you're taken straight to assigning a room.
2. **Renew** (dashboard, tenancies list, or tenancy page) when rent is paid. This
   ends the current tenancy and starts the next one with the same room, pre-filled
   to start on the old end date for the same length of time.
3. **End** a tenancy when a tenant leaves. The room becomes vacant and the tenancy
   stays in the room's history.

Rooms and tenants with tenancy history can't be deleted, so records are never lost.

## Background jobs

Solid Queue runs `rent_expiring:send_emails_to_tenants` monthly (see
`config/recurring.yml`). It emails tenants whose rent expires within 30 days or
has already expired. Monitor jobs at `/jobs`.

Preview emails at http://localhost:3000/rails/mailers.

## Tests

```sh
bin/rails test
```

## Deployment

Deployed with Kamal (`config/deploy.yml`). `RAILS_MASTER_KEY` and
`KAMAL_REGISTRY_PASSWORD` are read from `.kamal/secrets`.

```sh
bin/kamal deploy
```
