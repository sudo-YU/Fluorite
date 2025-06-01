# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'navStupro'
copyright = '2025, nav'
author = 'nav'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    'sphinx.ext.autodoc',  # Pythonコードの自動ドキュメント化
    'sphinx.ext.viewcode',  # ドキュメントからソースコードへのリンク
    'sphinx.ext.napoleon',  # Google/NumPyスタイルのdocstring対応
]

# システムパスにソースコードのディレクトリを追加
import os
import sys
sys.path.insert(0, os.path.abspath('..'))

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

language = 'ja'

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_rtd_theme'  # Read the Docsテーマ
html_static_path = ['_static']
