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

// Used internally in the chat.
//= require jquery/jquery.autosize

// For modals.
//= require bootstrap/bootstrap-modal
//= require bootstrap/bootstrap-modalmanager

// Used in crop, modals and possibly other places. Grep for `ajaxForm`
// and `ajaxSubmit`.
//= require jquery/jquery.form

// Use to search for models (e.g. users) dynamically.
//= require select2

// Use for XMPP in the chat.
//= require strophe

//= require i18n/translations

// Moment.js for dates
//= require moment
//= require moment/pt-br

// Datetime picker for bootstrap
//= require bootstrap-datetimepicker

// TODO: remove this dependecy, this is only used in attachments now and
//       can be easily replaced by standard jquery methods.
//= require jquery/jquery.livequery

//= require fineuploader

// 'base' HAS to be the first one included
//= require ./app/application/base
//= require_tree ./templates
//= require_tree ./app/application/
//= require_tree ./app/_all/
