editorLoaded = false
editorQueue  = []

basePath = '../vendor/summernote/'
getLocalesPath = -> basePath + 'lang/'

# Summernote locales are deffined using IETF language tags, with the country tag
# so if the page lang is deffined using just the ISO code, map it to the appropiate file
localesMap =
  'ca': 'ca-ES'
  'de': 'de-DE'
  'en': 'en-US'
  'es': 'es-ES'
  'fr': 'fr-FR'
  'it': 'it-IT'
  'nl': 'nl-NL'

# default summernote options
defaults =
  iconPrefix: 'icon icon-'

# cache some selectors
$doc  = $ document
$root = $ 'html'


###
@return {String} the page language
###
getLang = ->
  lang = $root.attr('lang') or 'en'
  localesMap[lang] or lang


###
Load a Summernote locale file

@param {String} lang
###
loadLocale = (lang) ->
  # english language is already included
  if lang is localesMap['en'] then return

  unless $("[data-summernote-locale='#{lang}']").length
    localeJS = document.createElement('script')
    localeJS.setAttribute 'data-summernote-locale', lang
    localeJS.setAttribute 'src', getLocalesPath() + "summernote-#{lang}.js"
    document.querySelector('head').appendChild localeJS


###
Turn a textarea into a Summernote editor

@param  {jQuery wrapped DOM element} elem textarea to replace by a Summernote instance
###
setupEditor = (elem) ->
  if !elem or !elem.length
    return

  # The Summernote settings can be customised for each textarea.
  # Just set a data-editor-settings attribute with the settings.
  # It must be a valid JSON
  instanceSettings = elem.data('editorSettings') or {}

  settings = $.extend {}, defaults, instanceSettings

  unless settings.lang
    settings.lang = getLang()

  loadLocale settings.lang
  elem.summernote settings


###
Setup a textarea to be transformed into a Summernote editor

The Summernote files are only loaded if required. So if the textarea
is initialised before Summernote is loaded, the action gets queued

@param  {jQuery wrapped DOM element} elem textarea to replace by a Summernote instance
###
prepareEditor = (elem) ->
  if editorLoaded
    setupEditor elem
  else
    editorQueue.push elem


###
Destroy the Summernote instance

@param  {jQuery wrapped DOM element} elem textarea to replace by a Summernote instance
###
destroyEditor = (elem) ->
  if editorLoaded
    elem.destroy()


###
Inject the Summernote css and js files

Using native js methods instead of jQuery because when injecting a js
file using jQuery, jQuery performs an AJAX request and that causes a
weird warning (thrown by pace.js)
###
attachEditor = ->
  summernoteCSS = document.createElement('link')
  summernoteCSS.setAttribute 'rel', 'stylesheet'
  summernoteCSS.setAttribute 'href', basePath + 'dist/summernote.css'

  summernoteJS = document.createElement('script')
  summernoteJS.setAttribute 'src', basePath + 'dist/summernote.min.js'

  summernoteJS.onload = ->
    editorLoaded = true
    if editorQueue.length
      editorQueue.forEach setupEditor

  document.querySelector('head').appendChild summernoteCSS
  document.querySelector('body').appendChild summernoteJS


# Initialization
# ------------------------------------------

$ ->

  # override the default Summernote path
  script = document.querySelector('script[src$="summernote-adapter.js"][data-summernote-path]') or document.querySelector('script[src$="summernote-adapter.min.js"][data-summernote-path]')
  if script
    basePath = script.getAttribute 'data-summernote-path'


  # load it
  attachEditor()


  # Init/destroy the summernote instances when needed
  $doc.on 'MOSAIQO.editor.rendered', (e, elems) ->
    elems.each (i, el) ->
      prepareEditor $(el)

  $doc.on 'MOSAIQO.editor.beforeDestroy', (e, elems) ->
    elems.each (i, el) ->
      destroyEditor $(el)
