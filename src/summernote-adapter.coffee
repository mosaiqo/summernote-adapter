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
  onImageUpload: (files) ->
    note = $(this)
    for file in files
      _sendFile file, (data) -> note.summernote 'insertImage', data.url


# default toolbar options
defaultToolbar =
  style:
    style:         true
  fontStyle:
    bold:          true
    italic:        true
    strikethrough: true
    underline:     false
    superscript:   false
    subscript:     false
    paragraph:     true
    clear:         false
  font:
    fontname:      false
    fontsize:      false
    height:        false
  insert:
    ul:            true
    ol:            true
    table:         true
    link:          true
    picture:       true
    hr:            true
  view:
    fullscreen:    true
    codeview:      false



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

@param {String}   lang
@param {Function} callback  executed when the locale is loaded
###
loadLocale = (lang, callback) ->
  # english language is already included
  # also don't load the locale if it has been loaded before
  if (lang is localesMap['en']) or $("[data-summernote-locale='#{lang}']").length
    if $.isFunction callback then callback()
  else
    localeJS = document.createElement('script')
    localeJS.setAttribute 'data-summernote-locale', lang
    localeJS.setAttribute 'src', getLocalesPath() + "summernote-#{lang}.js"

    localeJS.onload = ->
      if $.isFunction callback then callback()

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

  settings = $.extend true, {}, defaults, _parseOpts(instanceSettings)

  unless settings.lang
    settings.lang = getLang()

  loadLocale settings.lang, =>
    elem.summernote settings
    _preventEmptyValuesOnSubmit elem


###
Inline (per instance) settings parsing
###
_parseOpts = (opts = {}) ->
  toolbarOpts = $.extend true, {}, defaultToolbar

  if opts.lists?
    toolbarOpts.insert.ul = opts.lists
    toolbarOpts.insert.ol = opts.lists

  if opts.table?          then toolbarOpts.insert.table          = opts.table
  if opts.picture?        then toolbarOpts.insert.picture        = opts.picture
  if opts.link?           then toolbarOpts.insert.link           = opts.link
  if opts.horizontalrule? then toolbarOpts.insert.horizontalrule = opts.tables

  if opts.source?         then toolbarOpts.view.codeview         = opts.source
  if opts.fullscreen?     then toolbarOpts.view.fullscreen       = opts.fullscreen

  if opts.fonts?          then toolbarOpts.font.fontname         = opts.fonts
  if opts.fontsize?       then toolbarOpts.font.fontsize         = opts.fontsize
  if opts.lineheight?     then toolbarOpts.font.height           = opts.lineheight

  if opts.align?          then toolbarOpts.fontStyle.paragraph   = opts.align
  if opts.underline?      then toolbarOpts.fontStyle.underline   = opts.underline
  if opts.superscript?    then toolbarOpts.fontStyle.superscript = opts.superscript
  if opts.subscript?      then toolbarOpts.fontStyle.subscript   = opts.subscript

  if opts.styles          then toolbarOpts.style.style           = opts.styles

  toolbar = []

  for own group, buttons of toolbarOpts
    groupButtons = []

    for own k, v of buttons
      if v then groupButtons.push k

    if groupButtons.length then toolbar.push [group, groupButtons]

  { toolbar: toolbar }


###
Value sanitization

Prevent empty values being converted to '<p><br></p>'# prevent empty values being converted to '<p><br></p>'
###
_preventEmptyValuesOnSubmit = (elem) ->
  parentForm = elem.parents('div').first()

  if parentForm.legth
    parentForm.on 'submit', ->
      if elem.summernote('isEmpty') or elem.val() is '<p><br></p>'
        elem.val ''


###
Custom upload handler
###
_sendFile = (file, callback) ->
  data = new FormData()
  data.append 'file', file
  $.ajax
    url: '/api/uploads'
    data: data
    cache: false
    contentType: false
    processData: false
    type: 'POST'
    success: (data) ->
      data = data.data or data
      callback(data)



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
