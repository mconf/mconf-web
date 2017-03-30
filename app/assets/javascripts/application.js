//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require lodash
//= require handlebars.runtime
//= require diacritics

// To use placeholders in inputs in browsers that do not support it
// natively yet.
//= require jquery/jquery.placeholder

// Notifications (flash messages).
//= require toastr

// To crop logos.
//= require jquery/jquery.Jcrop

// For modals.
//= require bootstrap/bootstrap-modal
//= require bootstrap/bootstrap-modalmanager

// Used in crop, modals and possibly other places. Grep for `ajaxForm`
// and `ajaxSubmit`.
//= require jquery/jquery.form

// Use to search for models (e.g. users) dynamically.
//= require select2

//= require i18n/translations

// Moment.js for dates
//= require moment
//= require moment/pt-br
//= require moment/de
//= require moment/es
//= require moment/bg
//= require moment/ru

// Datetime picker for bootstrap
//= require bootstrap-datetimepicker

//= require fineuploader

// 'base' HAS to be the first one included
//= require ./app/application/base
//= require_tree ./templates
//= require_tree ./app/application/
//= require_tree ./app/_all/
