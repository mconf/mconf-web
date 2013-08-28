# In-place editing of form fields
# Uses as much as possible of what is already done in Rails for submitting forms via ajax.
# Currently works only for text inputs or checkboxes.
#
# Examples:
#
# Use forms with a single input inside, so when it is submitted only the target input
# is submitted:
#   = simple_form_for resource, :url => my_url_path, :remote => true, :html => { :class => "in-place-edit" } do |f|
#     = f.input :record, :as => :text, :input_html => { :class => "in-place-edit" }
#     = in_place_edit_indicators
#
# For checkboxes:
#   = simple_form_for resource, :url => my_url_path, :remote => true, :html => { :class => "in-place-edit" } do |f|
#     = f.input :record, :as => :boolean, :input_html => { :class => "in-place-edit" }
#     = in_place_edit_indicators
#
# Triggers the following events on the target input:
# * `in-place-edit-submitting`: when it's about to submit the form
# * `in-place-edit-success`: when the ajax request was successful
# * `in-place-edit-error`: when the ajax request failed

# local configuration variables
classForInProgress = "in-progress"
classForSuccess = "success"
classForError = "error"
namespace = "mconfInPlaceEdit"

class mconf.InPlaceEdit

  @bind: ->
    $("input.in-place-edit").each ->
      # the target input
      $target = $(this)
      # the form in which the input is
      $form = $target.parents("form")

      if $target.attr("type") is "checkbox"
        $target.off "change.#{namespace}"
        $target.on "change.#{namespace}", ->
          $form.removeClass(classForSuccess)
          $form.addClass(classForInProgress)
          $target.trigger("in-place-edit-submitting")
          $form.submit()

      else if $target.attr("type") is "text"
        # for text inputs we store the previous value in the input to trigger a submit
        # only when the value is changed
        $target.attr("data-in-place-edit-before", $target.val())

        $target.off "blur.#{namespace}"
        $target.on "blur.#{namespace}", ->
          if $target.val() isnt $target.attr("data-in-place-edit-before")
            $target.attr("data-in-place-edit-before", $target.val())
            $form.removeClass(classForSuccess)
            $form.addClass(classForInProgress)
            $target.trigger("in-place-edit-submitting")
            $form.submit()

      # listen for success or error when the form is submitted
      $form.off "ajax:success.#{namespace}"
      $form.on "ajax:success.#{namespace}", (evt, data, status, xhr) ->
        $form.removeClass(classForInProgress)
        $form.addClass(classForSuccess)
        $target.trigger("in-place-edit-success")
      $form.off "ajax:error.#{namespace}"
      $form.on "ajax:error.#{namespace}", (evt, data, status, xhr) ->
        $form.removeClass(classForInProgress)
        $form.addClass(classForError)
        $target.trigger("in-place-edit-error")

$ ->
  mconf.InPlaceEdit.bind()
