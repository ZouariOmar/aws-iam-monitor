# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = "aws-iam-monitor"
copyright = "2026, Zouari Omar"
author = "Zouari Omar"
release = "0.1.0"
contributors_repository = "ZouariOmar/aws-iam-monitor"

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = ["sphinx_contributors", "sphinxcontrib.mermaid", "sphinx_iconify"]

templates_path = ["_templates"]
exclude_patterns = []


# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_logo = "_static/aws-iam-monitor-icon.png"
html_favicon = "_static/aws-iam-monitor-icon.png"
html_theme = "sphinx_rtd_theme"
html_theme_options = {
    "logo_only": False,
    "prev_next_buttons_location": "bottom",
    "style_external_links": True,
    "collapse_navigation": True,
}
html_static_path = ["_static"]
