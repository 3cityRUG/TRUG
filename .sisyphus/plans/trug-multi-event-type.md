# TRUG Multi-Event-Type Support

## TL;DR

> **Quick Summary**: Add support for two event types in TRUG Rails app - Formal TRUG (existing, ~100+ in prod with presentations) and Bar TRUG (new, informal restaurant meetups). Bar TRUG has attendance but no archive, no talks, optional number. Homepage shows both side-by-side with smaller hero.
> 
> **Deliverables**:
> - Database migration adding `event_type` column (enum: formal/bar)
> - Updated Meetup model with type-dependent validations
> - Dual event display on homepage (side-by-side cards)
> - Archive filters to show only Formal TRUG
> - Admin interface with Type column and filter
> - Updated CSS for smaller hero and new card styles
> - Test coverage for new functionality
> 
> **Estimated Effort**: Medium (~4-6 hours)
> **Parallel Execution**: NO - Sequential (migration must run first, then model, then UI)
> **Critical Path**: Migration → Model → Controllers → Views → CSS → Tests

---

## Context

### Original Request
User wants to support both formal TRUG meetups (monthly, Hackerspace, presentations) and informal Bar TRUG meetups (bi-weekly, restaurants, socializing). Current system only supports formal meetups.

### Interview Summary
**Key Discussions**:
- **Bar TRUG**: Informal restaurant meetups, no presentations, just socializing
- **Attendance**: Yes, track attendance with GitHub avatars (like formal)
- **Time**: Same as formal (18:00) for both types
- **Archive**: Hide Bar TRUG from archive completely (only Formal archived)
- **Display**: Side-by-side cards on homepage when both upcoming
- **Naming**: "TRUG" and "Bar TRUG" in Polish UI
- **Existing**: All ~100+ existing meetups default to "formal" type
- **Admin**: Same list with Type column and filter dropdown

**Research Findings**:
- Meetup model has `number` field that's currently required/unique
- Homepage shows ONE next meetup with talks, map, attendance
- Archive shows all meetups with talks and videos
- Admin has meetup CRUD with number field
- Hero is currently 85vh height

### Metis Review
**Identified Gaps** (addressed):
- Homepage must handle asymmetric layouts (only one type upcoming)
- Need validation preventing formal→bar conversion if talks exist
- `Meetup.maximum(:number)` must scope to formal only
- `ordered` scope must handle NULL numbers (NULLS LAST)
- Migration must set default 'formal' to preserve existing data
- Archive scope must explicitly filter formal only
- Need partial for event card (DRY principle)

---

## Work Objectives

### Core Objective
Transform TRUG Rails app to support two distinct event types: Formal TRUG (existing) and Bar TRUG (new), with appropriate UI, database, and admin changes.

### Concrete Deliverables
- [ ] Database migration: `event_type` enum column, nullable `number`
- [ ] Meetup model: enum definition, type-dependent validations, scopes
- [ ] Pages controller: Query both types separately for homepage
- [ ] Homepage view: Dual event cards (formal + bar), smaller hero
- [ ] Archive view: Filter to show only formal events
- [ ] Admin views: Type column, filter dropdown, conditional form fields
- [ ] CSS: Reduced hero height (~40vh), Bar TRUG card styles
- [ ] Tests: Model, controller, and system tests updated

### Definition of Done
- [ ] All existing meetups have `event_type='formal'` after migration
- [ ] Homepage displays both event types side-by-side when both upcoming
- [ ] Archive page shows only Formal TRUG events
- [ ] Admin can create/edit both types with appropriate validations
- [ ] Bar TRUG cannot have talks added
- [ ] Formal TRUG requires number, Bar TRUG has nil number
- [ ] All tests pass (`bin/rails test`)

### Must Have
- Migration preserving existing ~100+ meetups as 'formal'
- Side-by-side event cards on homepage
- Bar TRUG hidden from archive
- Type column and filter in admin
- Attendance tracking for both types

### Must NOT Have (Guardrails)
- NO: Bar TRUG appearing in archive
- NO: Formal TRUG converted to Bar if talks exist
- NO: Talks on Bar TRUG events
- NO: Number field required for Bar TRUG
- NO: Duplicate numbering for Formal TRUG
- NO: Breaking changes to existing Formal TRUG functionality
- NO: Mobile layout broken - MUST be mobile-first with stacked cards

---

## Verification Strategy (MANDATORY)

### Test Decision
- **Infrastructure exists**: YES (Minitest + Capybara + Selenium)
- **User wants tests**: Tests-after (add tests after implementation)
- **Framework**: Rails Minitest (existing)

### Verification Approach
Each TODO includes automated verification procedures:

**By Deliverable Type:**

| Type | Verification Tool | Automated Procedure |
|------|------------------|---------------------|
| **Database/Model** | Rails console via Bash | Agent runs `bin/rails console` commands to verify enum, validations, scopes |
| **Frontend/UI** | Capybara system tests | Agent runs `bin/rails test test/system/` for homepage, archive views |
| **Admin** | Capybara system tests | Agent runs admin tests with Capybara for CRUD operations |
| **CSS** | Visual regression | Agent checks computed styles via Capybara or manual verification |

**Evidence Requirements (Agent-Executable):**
- Test output captured showing PASS status
- Database state verified via console commands
- UI state verified via Capybara assertions
- Commit messages follow conventional format

---

## Execution Strategy

### Sequential Execution (NO Parallel)

This work is inherently sequential - each layer depends on the previous:

```
Phase 1: Database Layer
└── Migration (must run first)

Phase 2: Model Layer  
└── Meetup model updates (depends on migration)

Phase 3: Controller Layer
└── Controllers updated (depends on model)

Phase 4: View Layer
└── Views updated (depends on controllers providing data)

Phase 5: CSS Layer
└── Styles updated (depends on view HTML structure)

Phase 6: Test Layer
└── Tests written/updated (depends on implementation)
```

### Dependency Matrix

| Task | Depends On | Blocks | Can Parallelize With |
|------|------------|--------|---------------------|
| 1 (Migration) | None | 2 | None |
| 2 (Model) | 1 | 3 | None |
| 3 (Controllers) | 2 | 4 | None |
| 4 (Views) | 3 | 5 | None |
| 5 (CSS) | 4 | 6 | None |
| 6 (Tests) | 5 | None | None |

---

## TODOs

> Implementation + Test = ONE Task. Never separate.
> EVERY task MUST have: Recommended Agent Profile + Parallelization info.

---

### Task 1: Database Migration - Add Event Type Support

**What to do**:
1. Create migration file: `db/migrate/XXXXXX_add_event_type_to_meetups.rb`
2. Add `event_type` column as string with default: 'formal'
3. Change `number` column to allow NULL values
4. Add index on `event_type` for query performance

**Must NOT do**:
- Don't remove or rename existing columns
- Don't set default on number (keep existing values)
- Don't add NOT NULL constraint to event_type (let default handle it)

**Recommended Agent Profile**:
- **Category**: `quick`
  - Reason: Simple migration following Rails conventions
- **Skills**: 
  - `git-master`: For proper commit workflow
- **Skills Evaluated but Omitted**:
  - `supabase-postgres-best-practices`: SQLite database, not Postgres

**Parallelization**:
- **Can Run In Parallel**: NO
- **Parallel Group**: Sequential - Phase 1
- **Blocks**: Task 2 (Model updates)
- **Blocked By**: None (can start immediately)

**References**:
- Current schema: `db/schema.rb` lines 23-31 (meetups table)
- Rails migrations guide: https://guides.rubyonrails.org/active_record_migrations.html

**Acceptance Criteria**:
- [ ] Migration file created and exists
- [ ] `bin/rails db:migrate` runs successfully
- [ ] Verify in console: `Meetup.columns_hash['event_type']` returns column info
- [ ] Verify: `Meetup.columns_hash['number'].null` is true (allows NULL)
- [ ] Verify sample record: `Meetup.first.event_type` returns 'formal' (existing meetups get default)

**Automated Verification**:
```bash
# Agent runs:
bin/rails db:migrate
bin/rails runner "puts Meetup.columns_hash['event_type'].inspect"
bin/rails runner "puts Meetup.columns_hash['number'].null.inspect"
bin/rails runner "puts Meetup.first.event_type.inspect"
# Assert: All commands succeed with expected output
```

**Commit**: YES
- Message: `feat(db): add event_type to meetups, make number nullable`
- Files: `db/migrate/XXXXXX_add_event_type_to_meetups.rb`, `db/schema.rb`
- Pre-commit: `bin/rails db:migrate` must succeed

---

### Task 2: Update Meetup Model - Enum, Validations, and Scopes

**What to do**:
1. Add `event_type` enum: `enum event_type: { formal: 'formal', bar: 'bar' }, default: 'formal'`
2. Update number validation: `validates :number, presence: true, if: :formal?`
3. Add validation preventing formal→bar conversion if talks exist:
   ```ruby
   validate :cannot_change_to_bar_if_talks_exist, if: -> { bar? && event_type_changed? }
   
   def cannot_change_to_bar_if_talks_exist
     errors.add(:event_type, "cannot be changed to Bar TRUG because it has talks") if talks.any?
   end
   ```
4. Update scopes:
   - `scope :formal, -> { where(event_type: 'formal') }`
   - `scope :bar, -> { where(event_type: 'bar') }`
   - `scope :archived, -> { formal.past }` (only formal in archive)
   - Update `ordered`: `order(Arel.sql("CASE WHEN event_type = 'bar' THEN 1 ELSE 0 END, date DESC"))` (formal first, then bar)

**Must NOT do**:
- Don't remove existing associations or validations
- Don't change the default scope behavior (keep as-is for backwards compatibility)
- Don't add validation preventing bar creation with talks (handled by controller/UI)

**Recommended Agent Profile**:
- **Category**: `ultrabrain`
  - Reason: Complex validation logic and scope ordering requires careful handling
- **Skills**:
  - `supabase-postgres-best-practices`: For understanding SQL scope behavior
  - `git-master`: For commit workflow
- **Skills Evaluated but Omitted**:
  - None

**Parallelization**:
- **Can Run In Parallel**: NO
- **Parallel Group**: Sequential - Phase 2
- **Blocks**: Task 3 (Controllers)
- **Blocked By**: Task 1 (Migration must run first)

**References**:
- Current model: `app/models/meetup.rb` lines 1-9
- Rails enums: https://api.rubyonrails.org/classes/ActiveRecord/Enum.html
- Conditional validations: https://guides.rubyonrails.org/active_record_validations.html#conditional-validation

**Acceptance Criteria**:
- [ ] Enum defined with formal/bar values
- [ ] Number validation only applies to formal type
- [ ] Conversion validation prevents formal→bar if talks exist
- [ ] Scopes work correctly:
  - `Meetup.formal` returns only formal meetups
  - `Meetup.bar` returns only bar meetups
  - `Meetup.archived` returns only past formal meetups
  - `Meetup.ordered` orders formal before bar, then by date DESC

**Automated Verification**:
```bash
# Agent runs:
bin/rails runner "m = Meetup.new(event_type: 'formal', date: Date.today); puts m.valid?; puts m.errors.full_messages"
# Assert: false (number missing for formal)

bin/rails runner "m = Meetup.new(event_type: 'bar', date: Date.today); puts m.valid?"
# Assert: true (no number needed for bar)

bin/rails runner "puts Meetup.formal.to_sql"
# Assert: Contains WHERE event_type = 'formal'

bin/rails runner "puts Meetup.bar.to_sql"
# Assert: Contains WHERE event_type = 'bar'
```

**Commit**: YES
- Message: `feat(model): add event_type enum with validations and scopes`
- Files: `app/models/meetup.rb`
- Pre-commit: `bin/rails test test/models/meetup_test.rb` must pass

---

### Task 3: Update Controllers - Query Both Event Types

**What to do**:
1. **PagesController** (`app/controllers/pages_controller.rb`):
   - Update `home` action to query both types separately:
     ```ruby
     def home
       @next_formal_meetup = Meetup.formal.upcoming.first
       @next_bar_meetup = Meetup.bar.upcoming.first
       @recent_meetups = Meetup.formal.ordered.offset(1).limit(5)
     end
     ```
   - Update `archive` action to filter to formal only:
     ```ruby
     def archive
       @meetups = Meetup.formal.ordered.includes(:talks)
     end
     ```

2. **Admin::MeetupsController** (`app/controllers/admin/meetups_controller.rb`):
   - Update `index` to support filtering by type:
     ```ruby
     def index
       @meetups = Meetup.ordered.includes(:talks)
       @meetups = @meetups.where(event_type: params[:type]) if params[:type].present?
       # ... rest of stats calculation
     end
     ```
   - Update `new` action to scope number calculation to formal only:
     ```ruby
     def new
       next_number = Meetup.formal.maximum(:number).to_i + 1
       @meetup = Meetup.new(number: next_number, date: Date.current, event_type: params[:type] || 'formal')
     end
     ```
   - Update strong params to include `event_type`:
     ```ruby
     def meetup_params
       params.require(:meetup).permit(:number, :date, :description, :location, :event_type)
     end
     ```

**Must NOT do**:
- Don't remove existing instance variables (maintain backwards compatibility)
- Don't change pagination logic
- Don't add authorization checks beyond existing

**Recommended Agent Profile**:
- **Category**: `quick`
  - Reason: Standard controller updates following existing patterns
- **Skills**:
  - `git-master`: For commit workflow
- **Skills Evaluated but Omitted**:
  - None

**Parallelization**:
- **Can Run In Parallel**: NO
- **Parallel Group**: Sequential - Phase 3
- **Blocks**: Task 4 (Views)
- **Blocked By**: Task 2 (Model must be updated first)

**References**:
- Current pages controller: `app/controllers/pages_controller.rb` lines 1-16
- Current admin controller: `app/controllers/admin/meetups_controller.rb` lines 1-55

**Acceptance Criteria**:
- [ ] `home` action sets `@next_formal_meetup` and `@next_bar_meetup`
- [ ] `archive` action only returns formal meetups
- [ ] `admin/index` supports type filter via params
- [ ] `admin/new` generates next number for formal only
- [ ] Strong params include event_type

**Automated Verification**:
```bash
# Agent runs:
bin/rails runner "puts PagesController.instance_method(:home).source_location"
# Verify: Method exists and has been updated

bin/rails test test/controllers/pages_controller_test.rb
# Assert: All tests pass

bin/rails test test/controllers/admin/meetups_controller_test.rb
# Assert: All tests pass
```

**Commit**: YES
- Message: `feat(controllers): update pages and admin for dual event types`
- Files: `app/controllers/pages_controller.rb`, `app/controllers/admin/meetups_controller.rb`
- Pre-commit: Controller tests must pass

---

### Task 4: Update Views - Dual Event Display and Admin Interface

**What to do**:

**1. Homepage** (`app/views/pages/home.html.erb`):
- Reduce hero height from 85vh to 45vh (update CSS class or inline style)
- Change "Najbliższe spotkanie" to "Najbliższe spotkania"
- Create two-column layout for events:
  ```erb
  <div class="grid">
    <!-- Formal TRUG -->
    <div class="grid-item one-half compact-one">
      <% if @next_formal_meetup %>
        <%= render partial: 'pages/event_card', locals: { 
          meetup: @next_formal_meetup, 
          type: 'formal',
          title: 'TRUG' 
        } %>
      <% end %>
    </div>
    
    <!-- Bar TRUG -->
    <div class="grid-item one-half compact-one">
      <% if @next_bar_meetup %>
        <%= render partial: 'pages/event_card', locals: { 
          meetup: @next_bar_meetup, 
          type: 'bar',
          title: 'Bar TRUG' 
        } %>
      <% end %>
    </div>
  </div>
  ```
- Update "Spotkania" section text to mention both types:
  - Change: "Przeważnie odbywają się w przedostanią środę każdego miesiąca..."
  - To mention monthly formal meetups AND bi-weekly bar meetups

**2. Create Event Card Partial** (`app/views/pages/_event_card.html.erb`):
```erb
<div class="event-card event-card--<%= type %>">
  <div class="event-card__header">
    <span class="event-card__title"><%= title %></span>
    <% if type == 'formal' %>
      <span class="event-card__number">#<%= meetup.number %></span>
    <% end %>
    <span class="event-card__date">
      <%= l(meetup.date, format: '%Y-%m-%d') %> (<%= l(meetup.date, format: '%A', locale: :pl) %>)
    </span>
  </div>
  
  <div class="info-row">
    <svg class="info-row__icon" viewBox="0 0 24 24" aria-hidden="true">
      <path d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20zm1 11.4V7a1 1 0 1 0-2 0v7c0 .3.1.6.3.8l3.8 3.8a1 1 0 1 0 1.4-1.4z" />
    </svg>
    <div class="info-row__content">
      <div class="info-row__label">Godzina</div>
      <div class="info-row__value">18:00</div>
    </div>
  </div>
  
  <div class="info-row">
    <svg class="info-row__icon" viewBox="0 0 24 24" aria-hidden="true">
      <path d="M12 2a7 7 0 0 0-7 7c0 5.3 7 13 7 13s7-7.7 7-13a7 7 0 0 0-7-7zm0 9.5a2.5 2.5 0 1 1 0-5 2.5 2.5 0 0 1 0 5z" />
    </svg>
    <div class="info-row__content">
      <div class="info-row__label">Miejsce</div>
      <div class="info-row__value">
        <%= type == 'formal' ? 'Hackerspace, al. Wojska Polskiego 41, Gdańsk' : meetup.location %>
      </div>
    </div>
  </div>
  
  <% if type == 'formal' && meetup.talks.any? %>
    <div class="talks-section">
      <div class="talks-section__title">Agenda</div>
      <% meetup.talks.each do |talk| %>
        <div class="talk-item">
          <div class="talk-item__title"><%= talk.title %></div>
          <div class="talk-item__speaker">
            <% if talk.speaker_homepage.present? %>
              <%= link_to talk.speaker_name, talk.speaker_homepage, target: "_blank", rel: "noopener" %>
            <% else %>
              <%= talk.speaker_name %>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
  <% elsif type == 'formal' %>
    <div class="talks-section">
      <div class="talks-section__title">Agenda</div>
      <div class="talk-item">
        <div class="talk-item__title">Brak informacji o prezentacjach</div>
      </div>
    </div>
  <% end %>
  
  <% if type == 'formal' %>
    <div class="map-container">
      <h3>Lokalizacja</h3>
      <a href="https://www.google.com/maps/place/Hackerspace+Tr%C3%B3jmiasto/@54.3896224,18.5792051,17z" target="_blank" rel="noopener">
        <%= image_tag "mapa.png", alt: "Mapa dojazdu do Hackerspace Trójmiasto", class: "map-container__image" %>
      </a>
      <div class="map-container__caption">
        <svg class="map-container__icon" viewBox="0 0 24 24" aria-hidden="true">
          <path d="M12 2a7 7 0 0 0-7 7c0 5.3 7 13 7 13s7-7.7 7-13a7 7 0 0 0-7-7zm0 9.5a2.5 2.5 0 1 1 0-5 2.5 2.5 0 0 1 0 5z" />
        </svg>
        <span>Hackerspace Trójmiasto, al. Wojska Polskiego 41, Gdańsk</span>
      </div>
    </div>
  <% end %>
  
  <%= turbo_frame_tag "attendance_section_#{meetup.id}" do %>
    <%= render partial: "pages/attendance_section", locals: { next_meetup: meetup } %>
  <% end %>
</div>
```

**3. Admin Index** (`app/views/admin/meetups/index.html.erb`):
- Add filter dropdown for event type
- Add "Typ" column to table
- Show type badge/color indicator

**4. Admin Form** (`app/views/admin/meetups/_form.html.erb`):
- Add event type selector (dropdown or radio)
- Show/hide number field based on type selection (JavaScript or conditional)
- Update hints based on type

**Must NOT do**:
- Don't remove existing view logic
- Don't change URL routes
- Don't remove attendance sections

**Recommended Agent Profile**:
- **Category**: `visual-engineering`
  - Reason: Complex view changes requiring HTML/CSS expertise
- **Skills**:
  - `frontend-ui-ux`: For designing the dual-card layout
  - `better-icons`: If new icons needed
  - `git-master`: For commit workflow
- **Skills Evaluated but Omitted**:
  - None

**Parallelization**:
- **Can Run In Parallel**: NO
- **Parallel Group**: Sequential - Phase 4
- **Blocks**: Task 5 (CSS)
- **Blocked By**: Task 3 (Controllers)

**References**:
- Current homepage: `app/views/pages/home.html.erb`
- Current admin index: `app/views/admin/meetups/index.html.erb`
- Current admin form: `app/views/admin/meetups/_form.html.erb`

**Acceptance Criteria**:
- [ ] Homepage shows dual event cards when both types upcoming
- [ ] Homepage handles asymmetric case (only one type upcoming)
- [ ] Hero height reduced to ~45vh
- [ ] Event card partial created and reused
- [ ] Admin shows type column and filter
- [ ] Admin form has type selector with conditional fields

**Automated Verification**:
```bash
# Agent runs system tests:
bin/rails test test/system/pages_test.rb
# Assert: Tests verify both event cards appear when both types exist

# Verify partial exists:
ls app/views/pages/_event_card.html.erb
# Assert: File exists
```

**Commit**: YES
- Message: `feat(views): dual event display on homepage, admin type filter`
- Files: `app/views/pages/home.html.erb`, `app/views/pages/_event_card.html.erb`, `app/views/admin/meetups/index.html.erb`, `app/views/admin/meetups/_form.html.erb`
- Pre-commit: System tests pass

---

### Task 5: Update CSS - Smaller Hero and Bar TRUG Card Styles

**What to do**:

**1. Landing CSS** (`app/assets/stylesheets/landing.css`):
- Update `.landing-hero` height from `85vh` to `45vh`
- Update `.landing-hero-content` padding for smaller space
- Add new styles for event cards:
  ```css
  .event-card {
    background: var(--color-light);
    border-radius: var(--border-radius);
    padding: 1.5rem;
    box-shadow: var(--shadow-sm);
    height: 100%;
  }
  
  .event-card--bar {
    border-left: 4px solid var(--color-brand); /* Or different accent color */
  }
  
  .event-card--formal {
    border-left: 4px solid var(--color-dark);
  }
  
  .event-card__header {
    display: flex;
    flex-wrap: wrap;
    align-items: baseline;
    gap: 0.5rem;
    margin-bottom: 1rem;
    padding-bottom: 0.75rem;
    border-bottom: 2px solid var(--color-brand);
  }
  
  .event-card__title {
    font-size: 1.25rem;
    font-weight: 700;
    color: var(--color-dark);
  }
  
  .event-card__number {
    font-size: 1rem;
    font-weight: 600;
    color: var(--color-brand);
  }
  
  .event-card__date {
    font-size: 0.95rem;
    color: var(--color-gray);
    margin-left: auto;
  }
  ```

**2. Mobile-First Responsive Design (CRITICAL)**:
- **MOBILE FIRST**: Default styles should be for mobile (single column, stacked cards)
- **MOBILE (< 768px)**: Event cards stack vertically, full width, larger touch targets
- **TABLET (768px - 1024px)**: Cards side-by-side with proper spacing
- **DESKTOP (> 1024px)**: Cards side-by-side, equal height, max-width constraints
- Use CSS Grid or Flexbox with `flex-wrap: wrap` and `min-width` for mobile
- Ensure touch targets are at least 44px for mobile accessibility
- Test on actual mobile devices or Chrome DevTools mobile emulation
- Verify text remains readable on small screens (min 16px font for inputs)

**3. Grid Layout for Event Cards (Mobile-First)**:
```css
/* Mobile first - stacked by default */
.events-grid {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

/* Tablet and up - side by side */
@media (min-width: 768px) {
  .events-grid {
    flex-direction: row;
  }
  
  .events-grid > * {
    flex: 1 1 0;
    min-width: 0; /* Prevent overflow */
  }
}
```

**Must NOT do**:
- Don't remove existing styles
- Don't break existing components
- Don't use CSS preprocessors (project uses pure CSS)
- Don't design desktop-first and try to retrofit mobile
- Don't use fixed widths that break on small screens

**Recommended Agent Profile**:
- **Category**: `visual-engineering`
  - Reason: CSS styling and responsive design
- **Skills**:
  - `frontend-ui-ux`: For visual design consistency
  - `better-icons`: For any icon adjustments
- **Skills Evaluated but Omitted**:
  - None

**Parallelization**:
- **Can Run In Parallel**: NO
- **Parallel Group**: Sequential - Phase 5
- **Blocks**: Task 6 (Tests)
- **Blocked By**: Task 4 (Views must exist first)

**References**:
- Current landing CSS: `app/assets/stylesheets/landing.css`
- CSS custom properties: `app/assets/stylesheets/variables.css`

**Acceptance Criteria**:
- [ ] Hero height is ~45vh (visually smaller)
- [ ] **MOBILE-FIRST**: Mobile layout works perfectly (stacked cards, readable text, touch-friendly)
- [ ] Event cards display side-by-side on desktop (768px+)
- [ ] Event cards stack vertically on mobile (< 768px)
- [ ] Bar TRUG card has distinct visual style (border/color)
- [ ] Touch targets are at least 44px on mobile
- [ ] Text remains readable on small screens (no horizontal scroll)
- [ ] Tested on mobile viewport (375px width) in Chrome DevTools
- [ ] No visual regressions in existing components

**Automated Verification**:
```bash
# Agent verifies via system test screenshots or manual check:
# 1. Start server: bin/rails server
# 2. Visit homepage
# 3. Verify hero is smaller
# 4. Verify both cards visible (if both types upcoming)
# 5. **MOBILE TESTING**: Open Chrome DevTools, set viewport to 375px width
# 6. Verify cards stack vertically on mobile
# 7. Verify text is readable (no zoom needed)
# 8. Verify touch targets are large enough (buttons, links)
# 9. Test on actual mobile device if available
```

**Commit**: YES
- Message: `style(css): smaller hero, dual event card styles`
- Files: `app/assets/stylesheets/landing.css`
- Pre-commit: Visual verification

---

### Task 6: Update Tests

**What to do**:

**1. Model Tests** (`test/models/meetup_test.rb`):
- Test enum values
- Test number validation (required for formal, not for bar)
- Test conversion validation (formal→bar blocked if talks exist)
- Test scopes (formal, bar, archived, ordered)

**2. Controller Tests**:
- Update existing tests to set event_type
- Add tests for type filtering in admin

**3. System Tests** (`test/system/pages_test.rb`):
- Test dual event display on homepage
- Test archive shows only formal
- Test asymmetric cases (only one type upcoming)

**Must NOT do**:
- Don't remove existing tests
- Don't skip test coverage for new functionality

**Recommended Agent Profile**:
- **Category**: `quick`
  - Reason: Standard test updates following existing patterns
- **Skills**:
  - `git-master`: For commit workflow
- **Skills Evaluated but Omitted**:
  - None

**Parallelization**:
- **Can Run In Parallel**: NO
- **Parallel Group**: Sequential - Phase 6 (Final)
- **Blocks**: None
- **Blocked By**: Tasks 1-5 (All implementation must be done)

**References**:
- Current model tests: `test/models/meetup_test.rb`
- Current system tests: `test/system/pages_test.rb`

**Acceptance Criteria**:
- [ ] All existing tests pass
- [ ] New tests for enum behavior
- [ ] New tests for validations
- [ ] New tests for scopes
- [ ] System tests for dual event display
- [ ] System tests for archive filtering

**Automated Verification**:
```bash
# Agent runs:
bin/rails test
# Assert: All tests pass (0 failures)

bin/rails test test/models/meetup_test.rb
# Assert: Model tests pass

bin/rails test test/system/pages_test.rb
# Assert: System tests pass
```

**Commit**: YES
- Message: `test: add tests for multi-event-type support`
- Files: `test/models/meetup_test.rb`, `test/controllers/pages_controller_test.rb`, `test/controllers/admin/meetups_controller_test.rb`, `test/system/pages_test.rb`
- Pre-commit: `bin/rails test` must pass (all tests)

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1 | `feat(db): add event_type to meetups, make number nullable` | Migration | `bin/rails db:migrate` |
| 2 | `feat(model): add event_type enum with validations and scopes` | meetup.rb | `bin/rails test test/models/` |
| 3 | `feat(controllers): update pages and admin for dual event types` | pages_controller.rb, admin/meetups_controller.rb | Controller tests pass |
| 4 | `feat(views): dual event display on homepage, admin type filter` | home.html.erb, _event_card.html.erb, admin views | System tests pass |
| 5 | `style(css): smaller hero, dual event card styles` | landing.css | Visual check |
| 6 | `test: add tests for multi-event-type support` | test files | `bin/rails test` (all) |

---

## Success Criteria

### Verification Commands
```bash
# Full test suite
bin/rails test
# Expected: All tests pass (0 failures, 0 errors)

# Database verification
bin/rails runner "puts Meetup.columns_hash['event_type'].inspect"
# Expected: Shows column info with default 'formal'

bin/rails runner "puts Meetup.first.event_type"
# Expected: 'formal' (existing meetups converted)

# Model verification
bin/rails runner "puts Meetup.formal.count"
# Expected: ~100+ (all existing)

bin/rails runner "m = Meetup.new(event_type: 'bar', date: Date.today); puts m.valid?"
# Expected: true

# Homepage verification (manual or via system test)
# Visit / and verify both event cards when both types exist
```

### Final Checklist
- [ ] All existing ~100+ meetups have event_type='formal'
- [ ] Homepage displays both event types side-by-side when both upcoming
- [ ] Archive page shows only Formal TRUG events
- [ ] Admin can create/edit both types
- [ ] Bar TRUG has attendance tracking
- [ ] Bar TRUG not visible in archive
- [ ] Hero height reduced to ~45vh
- [ ] All tests pass
- [ ] No breaking changes to existing functionality

---

## Notes for Executor

### Database Migration Strategy
The migration will:
1. Add `event_type` column with default 'formal' (all existing become formal)
2. Remove NOT NULL constraint from `number` column (allow nil for bar)
3. Add index on `event_type` for query performance

### Critical Implementation Details
- **Number generation**: In `admin/meetups#new`, use `Meetup.formal.maximum(:number)` to get next number (not all meetups, since bar has nil)
- **Archive scope**: `Meetup.formal.past` (never show bar in archive)
- **Homepage layout**: Use CSS Grid or Flexbox for side-by-side cards, stack on mobile
- **Attendance**: Both types use same attendance section partial, no changes needed

### Edge Cases to Handle
- Only formal upcoming, no bar (show single card)
- Only bar upcoming, no formal (show single card)
- Both on same day (show both side-by-side)
- Creating bar meetup (no number field, optional location)
- Converting formal→bar with talks (validation should block)

### Testing Priority
1. Model tests (enums, validations, scopes) - CRITICAL
2. Controller tests (params, filtering) - HIGH
3. System tests (homepage display, archive) - HIGH
4. Edge case tests (asymmetric layouts) - MEDIUM
