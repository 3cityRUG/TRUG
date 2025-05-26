# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page "/*.xml", layout: false
page "/*.json", layout: false
page "/*.txt", layout: false

# With alternative layout
# page "/path/to/file.html", layout: "other_layout"

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

# proxy(
#   "/this-page-has-no-template.html",
#   "/template-file.html",
#   locals: {
#     which_fake_page: "Rendering a fake page with a local variable"
#   },
# )

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/

helpers do
  def meetup_header(meetup)
    [].tap do |header|
      header.push("TRUG##{meetup.number}")
      header.push("(#{meetup.date})")
    end.join(" ")
  end

  def talk_title(talk)
    return talk.title unless talk.slides
    "<a href='#{talk.slides}' target='_blank'>#{talk.title}</a>"
  end

  def talk_speaker(talk)
    return talk.full_name unless talk.home_page
    "<a href='#{talk.home_page}' target='_blank'>#{talk.full_name}</a>"
  end

  def talk_source_code(talk)
    return unless talk.source_code
    "Source code: <a href='#{talk.source_code}' target='_blank'>#{talk.source_code}</a>"
  end
end

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

configure :build do
  activate :minify_css
  activate :minify_html
  activate :minify_javascript
end
