# TRUG - Trójmiasto Ruby User Group

This site is built with [Middleman](https://middlemanapp.com/) and deployed via [GitHub Pages](https://pages.github.com/).
The static site is automatically generated using [GitHub Actions](https://docs.github.com/en/actions).

## Getting started

To run the site locally, make sure you have:

- Ruby (version specified in `.ruby-version`)
- Bundler (`gem install bundler`)

Then install dependencies:

```sh
bundle install
```

To start the local server:

```sh
bundle exec middleman server
```

The site will be available at `http://localhost:4567`.

## Building the site

To build the site locally:

```sh
bundle exec middleman build
```

The static files will be generated in the `build/` directory.

## Deployment

Deployment is handled automatically via GitHub Actions on every push to the `master` branch.
The generated site is published to the `gh-pages` branch and hosted with GitHub Pages.

No manual deployment steps are required.

## Structure

- `source/` – source files for the static site (HTML, ERB, CSS, JS, etc.)
- `build/` – generated static site output (ignored in version control)
- `.github/workflows/` – CI/CD pipeline configuration
- `config.rb` – Middleman configuration file

## Extending the site

To add new content or pages:

1. Edit or add files in the `source/` directory.
2. Commit and push your changes to `master`.
3. GitHub Actions will automatically build and deploy the updated site.
