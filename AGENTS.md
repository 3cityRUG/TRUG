# TRUG Rails - Project Documentation

## Overview

TRUG (Trójmiasto Ruby User Group) website migrated from Middleman (static site generator) to Rails 8. The project includes a public-facing site with meetup archive and an admin panel for managing meetups and attendance.

## Technology Stack

- **Framework**: Rails 8.1.2
- **Ruby**: 3.2.2
- **Database**: SQLite
- **CSS**: Pure CSS with CSS custom properties (no preprocessors)
- **JavaScript**: Vanilla JS with Importmaps, Turbo Rails
- **Testing**: Minitest + Capybara + Selenium
- **Deployment**: Kamal
- **Authentication**: GitHub OAuth (Rails 8 built-in)

## Project Structure

```
trug-rails/
├── app/
│   ├── assets/
│   │   ├── images/          # Logo, icons, backgrounds
│   │   └── stylesheets/     # Modular CSS files
│   │       ├── application.css
│   │       ├── variables.css    # CSS custom properties
│   │       ├── reset.css
│   │       ├── grid.css
│   │       ├── buttons.css
│   │       ├── navbar.css
│   │       ├── footer.css
│   │       ├── landing.css      # Homepage styles
│   │       ├── archive.css      # Archive page styles
│   │       └── admin.css        # Admin panel styles
│   ├── controllers/
│   │   ├── admin/           # Admin controllers (layout: admin)
│   │   │   ├── dashboard_controller.rb
│   │   │   ├── meetups_controller.rb
│   │   │   └── talks_controller.rb
│   │   ├── pages_controller.rb
│   │   ├── github_sessions_controller.rb
│   │   ├── attendances_controller.rb
│   │   └── video_thumbnails_controller.rb
│   ├── javascript/
│   │   └── application.js   # Importmap entry point
│   ├── models/
│   │   ├── meetup.rb
│   │   ├── talk.rb
│   │   ├── user.rb
│   │   └── attendance.rb
│   └── views/
│       ├── layouts/
│       │   ├── application.html.erb
│       │   └── admin.html.erb
│       ├── pages/
│       │   ├── home.html.erb
│       │   └── archive.html.erb
│       └── admin/
│           ├── dashboard/
│           ├── meetups/
│           └── talks/
├── config/
│   ├── importmap.rb         # JavaScript imports
│   └── routes.rb
├── lib/
│   └── tasks/
│       └── migrate_meetups.rake
└── test/
    ├── system/              # E2E tests with Capybara
    └── models/
```

## CSS Architecture

### CSS Custom Properties (variables.css)

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
  --border-radius-sm: 8px;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 2rem;
  --transition-fast: 0.2s;
}
```

### Grid System (grid.css)

Flexbox-based responsive grid:
```css
.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px;
}

.grid {
  display: flex;
  flex-wrap: wrap;
  margin: 0 -15px;
}

.grid-item.half { width: 50%; }
.grid-item.one-third { width: 33.333%; }
.grid-item.two-thirds { width: 66.667%; }

@media (max-width: 768px) {
  .grid-item.half,
  .grid-item.one-third,
  .grid-item.two-thirds {
    width: 100%;
    max-width: 100%;
    flex-basis: 100%;
  }
}
```

### BEM Naming Convention

```css
/* Block */
.navbar { }

/* Element */
.navbar-brand { }
.navbar-logo { }
.navbar-actions { }

/* Modifier */
.btn-brand { }
.btn-ghost { }
.float-right { }
.text-center { }
.no-margin { }
```

## JavaScript Architecture

### Importmap (config/importmap.rb)

```ruby
pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "archive", to: "archive.js"
pin "site", to: "site.js"
```

### ES6 Video Player (app/assets/javascripts/archive.js)

```javascript
document.addEventListener('DOMContentLoaded', () => {
  const getVideoUrl = (videoId, provider) => {
    if (provider === 'youtube') {
      return `https://www.youtube.com/embed/${videoId}/?autoplay=1&rel=0`;
    } else if (provider === 'vimeo') {
      return `https://player.vimeo.com/video/${videoId}?autoplay=true`;
    }
    return '';
  };

  const createIframe = (videoId, provider) => {
    const iframe = document.createElement('iframe');
    iframe.src = getVideoUrl(videoId, provider);
    iframe.width = '560';
    iframe.height = '315';
    iframe.allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture';
    iframe.allowFullscreen = true;
    iframe.className = 'video-iframe';
    iframe.loading = 'lazy';
    return iframe;
  };

  const playVideo = (event) => {
    event.preventDefault();
    const button = event.currentTarget;
    const container = button.closest('.video-container');
    if (!container) return;

    const { videoId, videoProvider } = container.dataset;
    if (!videoId || !videoProvider) return;

    const iframe = createIframe(videoId, videoProvider);
    container.replaceChild(iframe, button);
  };

  document.querySelectorAll('.video-placeholder').forEach(placeholder => {
    placeholder.addEventListener('click', playVideo);
  });
});
```

## Models

### Meetup

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

```ruby
class Talk < ApplicationRecord
  belongs_to :meetup
  validates :title, presence: true
  validates :speaker_name, presence: true
  scope :for_meetup, ->(meetup) { where(meetup_id: meetup.id) }
end
```

### Attendance

```ruby
class Attendance < ApplicationRecord
  belongs_to :meetup
  belongs_to :user, optional: true

  STATUSES = { maybe: 0, yes: 1, no: 2 }.freeze

  validates :meetup_id, presence: true
  validates :github_username, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES.values }

  scope :for_meetup, ->(meetup) { where(meetup_id: meetup.id) }
  scope :confirmed, -> { where(status: STATUSES[:yes]) }

  def status_name
    STATUSES.key(status).to_s if status.present?
  end
end
```

### User (Rails 8 Authentication)

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

## Controllers

### Admin Controllers Pattern

```ruby
class Admin::MeetupsController < ApplicationController
  layout "admin"
  before_action :require_authentication
  before_action :require_admin!

  def index
    @meetups = Meetup.ordered
  end

  def new
    @meetup = Meetup.new(number: Meetup.maximum(:number).to_i + 1, date: Date.current)
  end

  def create
    @meetup = Meetup.new(meetup_params)
    if @meetup.save
      redirect_to admin_meetups_path, notice: "Utworzono."
    else
      render :new
    end
  end

  private

  def meetup_params
    params.require(:meetup).permit(:number, :date, :description)
  end
end
```

### GitHub OAuth (GithubSessionsController)

```ruby
class GithubSessionsController < ApplicationController
  allow_unauthenticated_access only: [ :create, :show ]

  def show
    if params[:code]
      create
    else
      redirect_to root_path, alert: "Brak kodu autoryzacji."
    end
  end

  def create
    github_data = exchange_code_for_token(params[:code])
    user = User.from_github(github_data)
    start_new_session_for user
    redirect_to after_authentication_url
  end

  private

  def exchange_code_for_token(code)
    # Exchange code for access token, then fetch user data
  end
end
```

### Admin Authorization (authentication.rb)

```ruby
def admin?
  return false unless current_user&.github?
  return true if Rails.env.development?

  token = ENV.fetch("GITHUB_TOKEN")
  repo = ENV.fetch("GITHUB_REPO", "3cityRUG/TRUG")

  client = Octokit::Client.new(access_token: token)
  client.collaborator?(repo, current_user.github_username)
rescue Octokit::Error, Octokit::NotFound
  false
end

def require_admin!
  unless admin?
    redirect_to root_path, alert: "Nie masz uprawnień administratora."
  end
end
```

## Routes

```ruby
Rails.application.routes.draw do
  resource :session, only: :destroy

  resource :github_session, controller: :github_sessions
  get "/auth/:provider", to: redirect { |params|
    client_id = ENV.fetch("GITHUB_CLIENT_ID")
    redirect_uri = CGI.escape("http://localhost:3000/github_session")
    "https://github.com/login/oauth/authorize?client_id=#{client_id}&redirect_uri=#{redirect_uri}&scope=read:user"
  }, as: :auth_provider

  resources :attendances, only: [ :new, :create ]

  root "pages#home"
  get "/archive", to: "pages#archive"

  namespace :admin do
    root "dashboard#index"
    resources :meetups do
      resources :talks, except: [ :index ]
    end
    resources :talks, only: [ :edit, :update, :destroy ]
  end
end
```

## Video Thumbnails

### YouTube
Direct URL: `https://img.youtube.com/vi/{video_id}/sddefault.jpg`

### Vimeo (Proxy Endpoint)
```ruby
class VideoThumbnailsController < ApplicationController
  def show
    video_id = params[:id]
    provider = params[:provider]

    if provider == "vimeo"
      thumbnail = fetch_vimeo_thumbnail(video_id)
    elsif provider == "youtube"
      thumbnail = "https://img.youtube.com/vi/#{video_id}/sddefault.jpg"
    end

    if thumbnail
      redirect_to thumbnail, allow_other_host: true
    else
      head :not_found
    end
  end

  private

  def fetch_vimeo_thumbnail(video_id)
    return nil if video_id.blank?

    cache_key = "vimeo_thumb_#{video_id}"
    Rails.cache.fetch(cache_key, expires_in: 24.hours) do
      uri = URI("https://vimeo.com/api/oembed.json?url=https://vimeo.com/#{video_id}")
      response = Net::HTTP.get_response(uri)
      return nil unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)
      data["thumbnail_url"]
    end
  end
end
```

## Environment Variables

```bash
GITHUB_CLIENT_ID=your_client_id
GITHUB_CLIENT_SECRET=your_client_secret
GITHUB_TOKEN=your_personal_access_token
GITHUB_REPO=3cityRUG/TRUG
```

## Testing

### E2E Test Pattern (test/system/pages_test.rb)

```ruby
class PagesTest < ApplicationSystemTestCase
  driven_by :selenium, using: :headless_chrome

  test "homepage shows TRUG title" do
    visit root_url
    assert_text "Trójmiejska Grupa"
    assert_text "Użytkowników Ruby"
  end

  test "archive page shows YouTube video thumbnails" do
    youtube_talk = Talk.find_by(video_provider: "youtube")
    skip "No YouTube talks found in database" unless youtube_talk.present?

    visit archive_url
    assert_selector ".video-container[data-video-provider=\"youtube\"][data-video-id=\"#{youtube_talk.video_id}\"]"
  end

  test "clicking video placeholder loads iframe" do
    talk_with_video = Talk.where.not(video_id: nil).where.not(video_id: "").first
    skip "No talks with videos found" unless talk_with_video.present?

    visit archive_url
    video_container = find(".video-container[data-video-id=\"#{talk_with_video.video_id}\"]", wait: 5)
    video_container.find(".video-placeholder").click
    assert_selector ".video-container iframe.video-iframe", wait: 2
  end
end
```

## Deployment (Kamal)

```yaml
# config/deploy.yml
service: trug-rails
image: trug-rails
servers:
  web:
    - 192.0.2.1
registry:
  username: registry.gitlab.com
  password:
    - GEMFURY_TOKEN
env:
  secret:
    - RAILS_MASTER_KEY
  clear:
    - GITHUB_CLIENT_ID
    - GITHUB_CLIENT_SECRET
    - GITHUB_TOKEN
    - GITHUB_REPO
volumes:
  - "trug_rails_storage:/rails/storage"
  - "trug_rails_db:/rails/db"
```

## Key Commands

```bash
# Development
bin/rails server

# Tests
bin/rails test                    # All tests
bin/rails test test/system/       # E2E tests
bin/rails test test/models/       # Model tests

# Assets
bin/rails assets:clobber          # Clear asset cache

# Database
bin/rails db:migrate              # Run migrations
bin/rails db:drop db:create       # Reset database

# Meetups
bin/rails meetups:migrate_from_yaml
bin/rails meetups:fetch_vimeo_thumbs
```

## Recent Changes & Learnings

### Test Suite Fixes
- **GitHub OAuth Tests**: Updated to use unique GitHub IDs (99999, 88888, 77777) to avoid conflicts with fixture data (user_one has github_id: "12345")
- **Route Configuration**: Added POST support for `/auth/github/callback` to match OmniAuth callback behavior

### Dependency Updates
- **omniauth-rails_csrf_protection**: Updated from 1.0.2 to 2.0.1 to resolve Rails 8.2 deprecation warning about `ActiveSupport::Configurable`

### Visual Improvements
- **Favicon**: Replaced placeholder `icon.svg` with TRUG logo
- **Landing Lead**: Enhanced `.landing-lead` styling:
  ```css
  font-size: 3rem;  /* was 2.5rem */
  font-weight: 700; /* was 600 */
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); /* added */
  ```

## Deployment & Release Process

### Commit Conventions
This project uses **semantic commits** in English:
- `feat:` - New features
- `fix:` - Bug fixes
- `style:` - Visual/CSS changes
- `test:` - Test changes
- `docs:` - Documentation updates
- `wip:` - Work in progress

### Kamal Deployment
**Configuration** (`config/deploy.yml`):
- Service: `trug`
- Image: `trug-rails`
- Server: `pi5` (Raspberry Pi)
- Proxy Host: `trug.pl`
- Local Registry: `localhost:5555`

**Deploy Commands**:
```bash
# Standard deploy
kamal deploy

# Check deployment status
kamal details

# Build without deploying
kamal build

# View app logs
kamal app logs

# Rollback to previous version
kamal rollback [VERSION]
```

**Recent Deployment** (Jan 31, 2026):
5 commits deployed successfully:
1. `style: enhance landing-lead typography and update favicon`
2. `fix: update omniauth-rails_csrf_protection to 2.0.1 for Rails 8.2 deprecation`
3. `fix: add POST route for GitHub OAuth callback`
4. `test: fix GitHub OAuth tests with unique IDs to avoid fixture conflicts`
5. `docs: update README and AGENTS with recent changes`

## Known Issues & Solutions

### Vimeo Thumbnails CORS
Vimeo CDN doesn't allow cross-origin requests from browsers. Solution: Use oEmbed API proxy endpoint at `/video-thumbnails/vimeo/:id`.

### Turbo Delete Buttons
Use `button_to` with `method: :delete` and `form: { data: { turbo_confirm: "..." } }` instead of `link_to` with `data: { turbo_method: :delete }`.

### Admin Authorization
Admin checks require GitHub repo collaborator status or organization membership. In development mode, admin check is bypassed.

## Data Migration

Meetups and talks were imported from `data/meetups.yml` (original Middleman site) using:
- `Meetup` model with number, date, location, description
- `Talk` model with title, speaker_name, slides_url, source_code_url, video_id, video_provider, video_thumb

## Admin Features

- **Dashboard**: Stats, quick actions, next meetup, recent meetups
- **Meetups**: CRUD (number, date, description only - location removed)
- **Talks**: CRUD per meetup
- **OAuth**: GitHub login with organization membership check

## Public Features

- **Homepage**: Next meetup info, attendance form with GitHub avatars
- **Archive**: All meetups with talks, lazy-loading videos
- **Video Thumbnails**: YouTube (direct), Vimeo (proxy)
- **Attendance**: GitHub username + status (yes/maybe), shows avatars
