// Generated by CoffeeScript 1.10.0
(function() {
  var $doc, $root, attachEditor, basePath, defaults, destroyEditor, editorLoaded, editorQueue, getLocalesPath, loadLocale, localesMap, prepareEditor, setupEditor;

  editorLoaded = false;

  editorQueue = [];

  basePath = '../vendor/summernote/';

  getLocalesPath = function() {
    return basePath + 'lang/';
  };

  localesMap = {
    'ca': 'ca-ES',
    'de': 'de-DE',
    'en': 'en-US',
    'es': 'es-ES',
    'fr': 'fr-FR',
    'it': 'it-IT',
    'nl': 'nl-NL'
  };

  defaults = {
    iconPrefix: 'icon icon-'
  };

  $doc = $(document);

  $root = $('html');


  /*
  Load a Summernote locale file
  
  @param {String} lang
   */

  loadLocale = function(lang) {
    var locale, localeJS;
    if ((lang === 'en') || (lang === localesMap['en'])) {
      return;
    }
    locale = localesMap[lang] ? localesMap[lang] : lang;
    if (!$("[data-summernote-locale='" + locale + "']").length) {
      localeJS = document.createElement('script');
      localeJS.setAttribute('data-summernote-locale', locale);
      localeJS.setAttribute('src', getLocalesPath() + ("summernote-" + locale + ".js"));
      return document.querySelector('head').appendChild(localeJS);
    }
  };


  /*
  Turn a textarea into a Summernote editor
  
  @param  {jQuery wrapped DOM element} elem textarea to replace by a Summernote instance
   */

  setupEditor = function(elem) {
    var instanceSettings, settings;
    if (!elem || !elem.length) {
      return;
    }
    instanceSettings = elem.data('editorSettings') || {};
    settings = $.extend({}, defaults, instanceSettings);
    if (!settings.lang) {
      settings.lang = $root.attr('lang') || 'en';
    }
    loadLocale(settings.lang);
    return elem.summernote(settings);
  };


  /*
  Setup a textarea to be transformed into a Summernote editor
  
  The Summernote files are only loaded if required. So if the textarea
  is initialised before Summernote is loaded, the action gets queued
  
  @param  {jQuery wrapped DOM element} elem textarea to replace by a Summernote instance
   */

  prepareEditor = function(elem) {
    if (editorLoaded) {
      return setupEditor(elem);
    } else {
      return editorQueue.push(elem);
    }
  };


  /*
  Destroy the Summernote instance
  
  @param  {jQuery wrapped DOM element} elem textarea to replace by a Summernote instance
   */

  destroyEditor = function(elem) {
    if (editorLoaded) {
      return elem.destroy();
    }
  };


  /*
  Inject the Summernote css and js files
  
  Using native js methods instead of jQuery because when injecting a js
  file using jQuery, jQuery performs an AJAX request and that causes a
  weird warning (thrown by pace.js)
   */

  attachEditor = function() {
    var summernoteCSS, summernoteJS;
    summernoteCSS = document.createElement('link');
    summernoteCSS.setAttribute('rel', 'stylesheet');
    summernoteCSS.setAttribute('href', basePath + 'dist/summernote-bs3.css');
    summernoteJS = document.createElement('script');
    summernoteJS.setAttribute('src', basePath + 'dist/summernote.min.js');
    summernoteJS.onload = function() {
      editorLoaded = true;
      if (editorQueue.length) {
        return editorQueue.forEach(setupEditor);
      }
    };
    document.querySelector('head').appendChild(summernoteCSS);
    return document.querySelector('body').appendChild(summernoteJS);
  };

  $(function() {
    var script;
    script = document.querySelector('script[src$="summernote-adapter.js"][data-summernote-path]');
    if (script) {
      basePath = script.getAttribute('data-summernote-path');
    }
    attachEditor();
    $doc.on('MOSAIQO.editor.rendered', function(e, elems) {
      return elems.each(function(i, el) {
        return prepareEditor($(el));
      });
    });
    return $doc.on('MOSAIQO.editor.beforeDestroy', function(e, elems) {
      return elems.each(function(i, el) {
        return destroyEditor($(el));
      });
    });
  });

}).call(this);