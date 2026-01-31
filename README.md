# TRUG Rails

TRUG (Trójmiasto Ruby User Group) website - a modern Rails 8 application for managing and displaying meetup information. Migrated from Middleman static site generator.

## Tech Stack

- **Framework**: Rails 8.1.2
- **Ruby**: 4.0.0
- **Database**: SQLite (with separate databases for cache and queue)
- **CSS**: Pure CSS with CSS custom properties (no preprocessors)
- **JavaScript**: Vanilla ES6 with Importmaps, Turbo Rails
- **Testing**: Minitest + Capybara + Selenium
- **Deployment**: Kamal
- **Authentication**: GitHub OAuth (Rails 8 built-in)

## Quick Start

```bash
# Install dependencies
bin/setup

# Start development server
bin/rails server

# Run tests
bin/rails test
```

## Project Structure

```
trug-rails/
├── app/
│   ├── assets/
│   │   ├── images/          # Logo, icons, backgrounds
│   │   └── stylesheets/     # Modular CSS files
│   ├── controllers/
│   │   ├── admin/           # Admin controllers (layout: admin)
│   │   ├── application_controller.rb
│   │   ├── attendances_controller.rb
│   │   ├── github_sessions_controller.rb
│   │   ├── pages_controller.rb
│   │   └── video_thumbnails_controller.rb
│   ├── javascript/          # Importmap entry point
│   ├── models/
│   │   ├── meetup.rb
│   │   ├── talk.rb
│   │   ├── user.rb
│   │   ├── attendance.rb
│   │   └── session.rb
│   └── views/
│       ├── layouts/         # application.html.erb, admin.html.erb
│       ├── pages/           # home, archive
│       └── admin/           # dashboard, meetups, talks
├── config/
│   ├── routes.rb
│   ├── importmap.rb         # JavaScript imports
│   ├── deploy.yml           # Kamal deployment config
│   └── database.yml
├── db/
│   ├── migrate/
│   └── schema.rb
├── test/
│   ├── system/              # E2E tests with Capybara
│   ├── models/
│   └── controllers/
└── lib/tasks/
    └── migrate_meetups.rake
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `GITHUB_CLIENT_ID` | GitHub OAuth app client ID |
| `GITHUB_CLIENT_SECRET` | GitHub OAuth app secret |
| `GITHUB_TOKEN` | GitHub personal access token (for admin checks) |
| `GITHUB_REPO` | Repository for admin authorization (default: 3cityRUG/TRUG) |
| `RAILS_MASTER_KEY` | Rails encryption key for credentials |

## Models

### Meetup
Central entity for meetup events with associated talks and attendances.

```ruby
class Meetup < ApplicationRecord
  has_many :talks, dependent: :destroy
  has_many :attendances, dependent: :destroy
  validates :number, presence: true, uniqueness: true
  validates :date, presence: true

  scope :ordered, -> { order(date: :desc) }
  scope :upcoming, -> { where("date >= ?", Date.today).order(date: :asc) }
  scope :past, -> { where("date < ?", Date.today).order(date: :desc) }
end
```

### Talk
Presentation talks belonging to meetups.

```ruby
class Talk < ApplicationRecord
  belongs_to :meetup
  validates :title, presence: true
  validates :speaker_name, presence: true

  scope :for_meetup, ->(meetup) { where(meetup_id: meetup.id) }
end
```

### Attendance
Tracks attendee participation with GitHub username and status.

```ruby
class Attendance < ApplicationRecord
  belongs_to :meetup
  belongs_to :user, optional: true

  STATUSES = { maybe: 0, yes: 1, no: 2 }.freeze

  scope :for_meetup, ->(meetup) { where(meetup_id: meetup.id) }
  scope :confirmed, -> { where(status: STATUSES[:yes]) }

  def status_name
    STATUSES.key(status).to_s if status.present?
  end
end
```

### User
Rails 8 authentication with GitHub OAuth integration.

```ruby
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def self.from_github(github_data)
    user = find_or_initialize_by(github_id: github_data["id"].to_s)
    unless user.persisted?
      user.github_username = github_data["login"]
      user.email_address = github_data["email"] || "#{github_data["login"]}@github.local"
      user.password = SecureRandom.hex(32)
      user.save!
    end
    user
  end

  def github?
    github_id.present?
  end
end
```

## Routes

```ruby
Rails.application.routes.draw do
  root "pages#home"
  get "/archive", to: "pages#archive"

  resource :session, only: :destroy
  resource :github_session, controller: :github_sessions
  get "/auth/:provider", to: redirect { ... }

  resources :attendances, only: [ :new, :create ]

  get "/video-thumbnails/:provider/:id", to: "video_thumbnails#show"
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :admin do
    root "dashboard#index"
    resources :meetups do
      resources :talks, except: [ :index ]
    end
    resources :talks, only: [ :edit, :update, :destroy ]
  end
end
```

## CSS Architecture

### Custom Properties (variables.css)
Design tokens for consistent theming:

```css
:root {
  --color-brand: #e25454;
  --color-brand-dark: #c23e3e;
  --color-dark: #505050;
  --color-light: #ffffff;
  --color-gray-light: #e0e0e0;
  --color-gray-dark: #333;
  --font-family: Lato, -apple-system, BlinkMacSystemFont, sans-serif;
  --border-radius: 50px;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 2rem;
}
```

### Responsive Grid
Flexbox-based grid with breakpoint at 768px:

```css
.container { max-width: 1200px; margin: 0 auto; padding: 0 24px; }
.grid { display: flex; flex-wrap: wrap; margin: 0 -15px; }
.grid-item.half { width: 50%; }
.grid-item.one-third { width: 33.333%; }

@media (max-width: 768px) {
  .grid-item.half, .grid-item.one-third { width: 100%; }
}
```

### Naming Convention
BEM-like component-modifier pattern:
- Blocks: `.navbar`, `.btn`, `.video-container`
- Elements: `.navbar-brand`, `.btn-icon`
- Modifiers: `.btn-brand`, `.btn-ghost`, `.video-playing`

## JavaScript

### Importmap Configuration
```ruby
pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "archive", to: "archive.js"
pin "site", to: "site.js"
```

### Video Player (archive.js)
Lazy-loading video player for YouTube and Vimeo with click-to-play functionality.

## Deployment (Kamal)

```yaml
# config/deploy.yml
service: trug
image: trug-rails
servers:
  web:
    - 192.0.2.1
registry:
  username: trug-bot
  password:
    - KAMAL_REGISTRY_PASSWORD
volumes:
  - "trug-storage:/rails/storage"
  - "trug-sqlite:/rails/db"
traefik:
  options:
    - "--entrypoints.websecure.http.tls=true"
```

## Testing

```bash
bin/rails test                    # All tests
bin/rails test test/system/       # E2E tests
bin/rails test test/models/       # Model tests
bin/rails test test/controllers/  # Controller tests
```

System tests use Capybara with Selenium (headless Chrome).

## Rake Tasks

```bash
bin/rails meetups:migrate_from_yaml  # Import from legacy Middleman data
bin/rails meetups:fetch_vimeo_thumbs # Fetch Vimeo video thumbnails
bin/rails db:drop db:create          # Reset database
bin/rails assets:clobber             # Clear asset cache
```

## Code Quality & Testing

### Recent Fixes

**GitHub OAuth Tests**: Fixed test failures caused by fixture conflicts. Tests now use unique GitHub IDs that don't conflict with fixture data.

**OmniAuth CSRF Protection**: Updated `omniauth-rails_csrf_protection` from 1.0.2 to 2.0.1 to fix Rails 8.2 deprecation warning.

**Favicon**: Updated from placeholder to use the TRUG logo SVG (`public/icon.svg`).

**Landing Page Typography**: Enhanced `.landing-lead` ("Trójmiejska Grupa Użytkowników Ruby" heading) with:
- Increased font-size from 2.5rem to 3rem
- Increased font-weight from 600 to 700
- Added text-shadow for better visibility

## Known Issues & Solutions

### Vimeo Thumbnails CORS
Vimeo CDN doesn't allow cross-origin requests. Solution: Use oEmbed API proxy endpoint at `/video-thumbnails/vimeo/:id`.

### Turbo Delete Buttons
Use `button_to` with `method: :delete` and `form: { data: { turbo_confirm: "..." } }` instead of `link_to` with `data: { turbo_method: :delete }`.

### Admin Authorization
Admin checks require GitHub repo collaborator status. In development mode, admin check is bypassed.
