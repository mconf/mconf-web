# Change Log


## [2.3.0] - 2016-10-05

Upgraded ruby from 2.2.0 to 2.2.5.

This version includes a few new features such as support for reCaptcha and support for avatars
from Gravatar, new queues for resque that organize jobs by priority, and better error messages
in the log when in production.

Also includes several bug fixes over the previous version.

* Update ruby to 2.2.5 (from 2.2.0).
* [#787] Improve resque queues to be ordered by priority and not just by name. Now jobs are
  distributed in three queues ordered by priority (`high`, `normal`, `low`), plus the standard
  `mailer` queue and the queue `bigbluebutton_rails` from the gem.
* [#818] Log the entire stack trace on errors when in production.
* [#767] Added `current_sign_in_at` to Shibboleth and LDAP tokens. Now it's possible to know
  when the user signed in the last time for each of the 3 authentication mechanisms available.
* [#877] Fix redirection to `/pending` When the user signs in via Shibboleth when he wasn't
  already signed into the federation.
* [#868] Properly send user to pending approval page if he registers after failing the first
  registration attempt.
* [#839] Fix the highlight method in the management lists of users and spaces to properly
  show HTML entities (e.g. "&nbsp;") as text if they are set as part of the text by the user.
* [#516] Removing old references to digest emails and digest email frequency settings.
  Digest emails were disabled for a long time already, but were still available in views.
* [#871] Now only the description is editable in recordings, since all other attributes
  come from the web conference server and editing them in Mconf-Web wouldn't change them
  in the web conference server. Includes an upgrade in `bigbluebutton_rails`.
* [#876] Fix redirect loop if `shib_always_new_account` is on and there's an error creating
  the user.
* [#819] Inputs to edit LDAP configurations are not autocompleted anymore with username and
  password saved by the browser.
* Add `/secure/associate` to Apache's shibboleth routes. Since 2.1.0, the environment
  variables should be set when `/secure/associate` and Apache wasn't doing so.
* [#756] Fix access to `#new` for events when logged out, it would raise an exception.
* [#501, #353] Explicitly require file type in upload forms. Filters the type of images
  supported and prevents issues with e.g. `.svg` files.
* [#549] Fix the highlight of results in the management lists of users and spaces. It
  didn't work with special characters as for example `á` or `ô`.
* [#823] Fix `undefined method 'message' for nil:NilClass in ErrorsController`.
* [#425] Use avatars from Gravatar for users when the user has not uploaded any
  custom avatar. Off by default, can be turned in and configured in the website management
  page.
* [#335, #729] Add support for reCaptcha in the registration form and in the form to
  register as an anonymous user in an event. Off by default, can be turned in and
  configured in the website management page.
* Security fixes by upgrading uglifier and nokogiri.


## [2.2.0] - 2016-07-25

Added support for BigBlueButton 1.0. A few other improvements over 2.1.0, but no
major feature.

Important: `BigbluebuttonServer#salt` was renamed to `BigbluebuttonServer#secret`.
Might require changes in configuration files (see `setup_conf.yml`).

* Prevent DatesHelper#format_date from breaking if `date` is `nil`.
* Upgraded bigbluebutton_rails. Add two new metadata to create calls:
  the domain configured on Mconf-Web and the type of the room being created ("User"
  or "Space").
* [#873] Fix redirects after signing in via Shibboleth. Redirects were are always
  sending the user to `/home`.
* Upgraded bigbluebutton_rails. Fixes setting recordings as unavailable. When loading
  the recordings of a room, was setting all recordings from all other rooms as
  unavailable.
* Add "su" directive on logrotate's config.
* Upgraded bigbluebutton_rails. Improves how BigbluebuttonMeeting objects are created
  and ended. More reliable and works even if the resque workers are not running.
* [#768] Fix redirects to valid pages when using HTTPS.
* [#861] Fix how recent activities are created for meetings. Solves
  "undefined method `current_user' for nil:NilClass".
* [#447] Allow users to unpublish their recordings. They will be hidden from the user
  but still available for admins.
* Now accepts the version 1.0 for BigBlueButton.
* [#844] Create a recent activity when approving a user from `/users/:id/edit`.
* [#721] Fix `ActiveRecord::RecordNotUnique on table "bigbluebutton_meetings`.

------------------------------------

All tickets below use references to IDs in our old issue tracking system.
To find them, search for their description or IDs in the new issue tracker.

------------------------------------

## [2.1.0] - 2016-04-06

This release removes some underused features (news, private messages and the spam flag) in order to simplify the application. News can be replaced by posts in a space's wall; private messages will, in the future, be replaced by a notification system; the spam flag was not used at all and can be implemented properly in the future if necessary.

Also, the event module, that was previously in a separate repository, was moved to Mconf-Web in order to make it easier to update and adapt it.

* [#1938] Speed up access to `/spaces`. The query that orders the spaces was optimized and now runs in background only. Accessing `/spaces` will only run a very simple query that is very fast.
* [#1473] Overall improvement in recent activities, including the way the objects are stored and the way they are displayed, specially for recent activities related to resources that were removed (e.g. displaying a recent activity for an attachment that was removed).
* [#1895] Fix cookie overflow after signing in via Shibboleth. Now Shibboleth and LDAP data are stored in the database only, not in the session anymore.
* [#1802] Add pagination to the list of users in a space.
* [#1930] Properly set HTTP or HTTPS in devise emails according to what is configured in the website.
* [#1748] Never redirect the user back to an external URL. Prevents weird redirections after the user signed in.
* [#1776] Invitation to a private space now won't send the link to the space, since the user will not be able to view it anyway.
* [#1811] Don't allow users to change the flags "auto start audio", "auto start video" and "presenter share only". Prevents confusion and inconsistencies when the user saved the room options but didn't set any of these flags. Only admins can change these flags now.
* [#1928] Never show the page `events/new` for users who can't create space events or for unapproved and disabled events.
* [#1909] Fix invitation view for the languages `es` and `de`.
* [#1882] Explicitly fail LDAP authentication if the user has not informed a username or a password.
* [#1155] Improve messages when a user can't sign in via local authentication.
* [#1808] All code of the events module previously in the repository `mconf/mweb_events` was moved to the application. The separate repository is now deprecated. Includes also several smaller fixes and improvements in the events.
* [#1194] Restrict users that can create events that belong to spaces. Users that don't belong to the space cannot create events in the space.
* [#1293] Start date when creating an event was generating an error that was not shown in the form. Now it shows as any other error.
* [#1046] News were removed from the application. All existing news were not removed, but migrated to posts in the wall.
* [#1807] Remove private messages from the application. There's a plan on implementing a notification system in the future to replace them.
* [#1806] Remove the chat from the application. This feature was experimental only and very outdated.
* [#1801] Remove the "auto record" flag from the global configurations. Now the website will always behave as if this flag was checked.
* [#768] Part of the work to start using inherited resources in the controllers was started. Some controllers are already using it, some are not. Doesn't change functionality, only how the code is written.
* [#1898] Remove unnecessary capitalization in `/app/views/my/_webconference_room.html.haml` to help with translations.
* Upgrade rails to 4.1.14.
* Several gem updates and small fixes for security reasons, including modify protect from_forgery to prevent CSRF, update devise, escape more inputs in the HTML.
* Fix `Space.with_disabled` removing scopes other than `disabled: false`. It would remove all scopes, so if `with_disabled` was called in a chain after any other query, this other query would be ignored.
* Add translation to German (de) from Transifex.
* Fix typos on SMTP configurations.
* Approval and disable methods were moved from specific controllers/models to separate modules. Now any model/controller that needs to be approved and/or disabled can use these modules. Currently used for `User` and `Space`.
* Don't let admins have their password changed when not using local authentication, as was already done for normal users.
* Remove duplicated "max_participants" input when editing rooms.
* Prevent DoubleRender error when an error 500 view is rendered.


## [2.0.1] - 2016-01-05

Bugfixes over 2.0.0.

* [#1845] Fix `An AbstractController::DoubleRenderError occurred in spaces#index`.
* [#1857] Fix wrong tooltips and confirmation message when removing spaces in the administration pages.
* [#1872] Fix `undefined method 'find_by_id_with_disabled'`.
* [#1873] Fix `undefined method 'name' for nil:NilClass at app/models/join_request.rb:76:in 'role'`.
* [#1890] Fix `undefined method '[]' for nil:NilClass on ApplicationController#append_info_to_payload`.
* [#1859] Global administrators are now not able to change their password if they didn't use local authentication to sign in, the same way normal users aren't able to.
* [#1854] Some forms were being filled by the browser with saved username/password but they shouldn't. These forms fixed were: form admins use to create users (users/create), form to register a user (registrations/_signup_form) and the form to edit a user (users/edit).
* [#1892] Moved the translations of the names of the available languages out of the locale files, now they are configured directly in the application.


## [2.0.0] - 2015-10-30

This release is a completely new version of Mconf-Web, still using the same base and concepts of the 0.x versions, but with a lot of changes, improvements and optimizations in the code and also in the site's design, usability and consistency. Also, the application is in general more configurable, better structured and more optimized than before. We're calling it version 2.0 to make it clear that a lot has changed since the latest stable version. It also includes several new features, that are specified below.

### Bigger changes

* Updated Rails from 3.0 to 4.x
* Recommended way to install ruby is now with [rbenv](https://github.com/sstephenson/rbenv). We also use a much newer version of ruby.
* The library [station](https://github.com/mconf/station) was replaced by several other libraries that are better, are actively maintained and have bigger communities behind them, such as [devise](https://github.com/plataformatec/devise) and [cancancan](https://github.com/CanCanCommunity/cancancan).
* A new design, that is cleaner and should also be easier to be modified to apply custom visual identities to the website. Uses [Twitter's Bootstrap 2](http://getbootstrap.com/2.3.2/) and [Font Awesome](http://fontawesome.io/).

### Overall changes

* [#370] God, used for monitoring, replaced by [Monit](http://mmonit.com/monit/).
* [#246] Integration with LDAP for user authentication.
* [#412] Upload and crop of logos (user avatars, logos in spaces) was completely reimplemented. Includes the removal of the default logos available in the past version, as a way to simplify the feature (for both users and developers) and make the website cleaner (spaces will use a default logo unless one is uploaded, so there won't be random images that give no information of what the space really is).
* [#457] The feature to control invitations to spaces and requests to join spaces was completely reimplemented. In the previous versions this was done by [station](https://github.com/mconf/station), but now is done internally by Mconf-Web with another method that's a lot simpler.
* [#906] The feature to create the recent activities was completely reimplemented. In the previous versions this was done by [station](https://github.com/mconf/station), but now is done mostly by a library called [PublicActivity](https://github.com/pokonski/public_activity).
* [#333, #877, and others] New pages for the list of spaces, now with more information and pagination.
* [#866, and others] Better buttons and messages in the interface to start, join and finish web conferences.
* [#986] Users don't have to set the "record" flag, a title and description before creating a conference anymore. The flag is now set automatically and the title and description can be edited after the recording is made available. It was designed to work with versions of Mconf-Live/BigBlueButton that have the record button inside the session. This feature is optional: if disabled, the user will be prompted to set the record flag before opening a new session.
* [#953] Added option to require administrators to accept new accounts. With this option enabled, users can register new accounts but have to wait until an administrator accepts their accounts to be able to log in. It is optional and disabled by default.
* [#1778] Added option to moderate spaces. With this option enabled, users can create spaces but administrators have to accept them before they can be actively used.
* [#963] Administrators can now set a flag to allow/disallow users to record meetings. By default no user can record, except administrators (whose permissions ignore their record flag). When a user can record, he can record in his own web conference room and in the web conference room of the spaces he belongs to.
* [#1168] The application now uses [resque](https://github.com/resque/resque) and [resque-scheduler](https://github.com/resque/resque-scheduler) for all background tasks and scheduling. They replaced both delayed_job and whenever/cron.
* [#1368, #1404, #1423] Several improvements in the sign in via Shibboleth. See [this page](https://github.com/mconf/mconf-web/wiki/Shibboleth:-migrate-users-to-use-EPPN) to understand some part of what changed and check for possible issues when migrating.
* [#1114] A new event module was implemented, still considered in a beta stage but already with a lot of improvements over the events in the previous version of Mconf-Web.
* [#1202, #385, #386, #867, #1231, #1245, others] Several improvements in error pages and redirects to make it easier for the user to know what is happening in edge cases (no permission to access a page, not signed in, etc).
* [#457, #838, #1067] Improved process to invite people to join a space and to request to join a space.
* [#1148, #1513] Reviewed roles/permissions in web conferences.
* [#1153, #1045, #1604, #1552] Several new administration options, such as the option to permanently remove users and spaces (not only disable them), option to confirm a user via interface, option to automatically add users to spaces without requiring them to accept an invitation, option for space admins to remove users from spaces, and several others.
* [#1297] Made all emails use the same format, a very simple format but standard for all emails the application sends.

## [0.8.1] - 2014-07-28

This is a minor update over 0.8 that was developed in parallel with 2.0.

* [#908] Users had no permission to update their list of recordings
* [#972] Login via shibboleth failed when a user's name had accents
* [#918] The button "send" when cropping a logo was not clickable
* [#973] Fix wrong name for some users when logging in via shibboleth
* [#984] Fix wrong translations in the subject of some emails
* [#1020] Inviting a user to a web conference via private message wasn't sending the message added by the user
* Removed the option to invite people to spaces using just an email, now only registered users can be invited.
* [#1246] Updated the URL to download the mobile client and removed the QR code that doesn't work in the new mobile client.


## [0.8] - 2013-07-12

* Wiki moved to https://github.com/mconf/mconf-web/wiki/
* [#461] Support for recordings: the application shows the list of recordings for a webconference room (in the user's home and in the webconference section in a space), the user is now be able to select if the meeting will be recorded or not (as well as a title and description), and were also included administration pages to see all recordings, edit, delete, and so on. The support for recordings is only enabled for administrators.
* [#812] Fix unclosed \<b\> tags in the user's home page
* [#775] Fix error that sometimes the account page couldn't show the IdP name and user data from shibboleth.
* [#724] Fix error when sending webconference invitations to multiple emails.
* [#530] Add options to configure an external help page
* [#728] Fix huge horizontal scroll bar when uploading profile picture
* [#731] When a user tried to accept and invitation to join a space he was asked to create a new account, now he can only login or create an account in the default registration page.
* [#726] Mark the required fields in the registration.
* [#725] Split "Register / Login" links at the top menu in two separate links.
* [#718] Rooms that belongs to disabled users or spaces cannot be accessed
* [#737] Minimum length for user's login and room's param is now 1 char.
* [#671] Add a default timezone for the website.
* [#297 and others] Fix missing strings.
* [#670] Fix emails to use the correct language (receiver's language, if available, or site language).
* [#732] When a space is set as private/public the webconference room is set as well
* [#734] [#735] `meetingID`s are now static and globally unique (won't be randomized anymore).
* Fix `invites/invite_room` to return the user id not the profile id.
* Remove scripts to deploy with capistrano. They can still be used, see https://github.com/mconf/mconf-web/wiki/Deployment-with-Capistrano
* [#727] Replaced simple_captcha with reCaptcha in the registration form.
  * **Important:** Requires a reCaptcha key to be generated for you domain on http://www.google.com/recaptcha/whyrecaptcha (Click in "Sign up Now!") and configured in the management page of Mconf-Web, otherwise the registration form will have no captcha validation.
* [#822] When a private space is created the webconference room is also created as private.
* [#813] Fix errors when editing the name of a space.
* [#829] Added a button to force meetings to be closed.
* [#817] When a user tries to access the page to send a join request to a space he's already a member of he is redirected to the space's home page.
* [#837] Change the name of the room when a user changes his login (affects the welcome message shown in the webconference).
* [#821] Translated user roles in spaces ("Admin", "Member", "Invited").
* [#814] Redirect the user to the pages he was in when logging in (works when clicking in the "login" link in the top bar).
* [#789] New pages to join the conference when invited, to make clear the separation between user login and user access to a room (that doesn't necessarily require a login but might require an access code).
* [#807] Added information about Mconf-Mobile in the "join from mobile" page.
* [#756] Use the correct locale to display success message when changing languages.
* [#630] Mark private messages as read when user clicks to read them.
* [#859] Fix missing translation when the list of attachments is empty.
* [#854] Fix wrong tags in the list of attachments when seeing the page as an anonymous user.
* [#816] All links in the list of spaces now point to the space's home (not to the page to ask to join the space).
* [#815] Redirect to the page to ask permission to join a space when trying to access a private space you're not a member of.
* [#809] Block invited users from creating a conference when accessing it using the moderator password.
* [#763] Fix wrong error messages when a private message fails to be sent.
* [#820] The role "invited" in spaces is now functional and explained in the interface.

### Upgrade notes

* To use captcha in the registration page you need to generate reCaptcha keys for you domain on http://www.google.com/recaptcha/whyrecaptcha (Click in "Sign up Now!") and configure it in the management page of Mconf-Web, otherwise the registration form will have no captcha validation.


## [0.7] - 2012-12-20

* Added SMTP configurations in the management area so that any SMTP account can be used (not only a Gmail account as before).
* Improved some pages to join web conferences from mobile clients.
* Users can now specify their ID during registration.
* When logging in via shibboleth, users can now associate their shibboleth account with an account that already exists in Mconf-Web.
* Users cannot modify their email address after registering.
* Added a configuration file to use logrotate (see [this commit](https://github.com/mconf/mconf-web/commit/89af50503c22a8f353d856b2e03d60241ced710b)).
* Added support for guest users in web conferences. Guest users is a feature currently only available in Mconf-Live.
* Several small layout and bug fixes.

### Upgrade notes

* The instructions to install Mconf-Web were updated to:
  * Use Ubuntu 12.04.
  * Use a user different than `root` to access MySQL. We recommend a user named `mconf`, and the instructions to create this user are [[in the installation guide|Deployment-Manual]].
  * Set up logrotate, see [[this page|Deployment-Install-Logrotate]].

## [0.6] - 2012-02-07

* New directory structure for the language files. There's now a folder with the language name and several files for each language. Example: `config/locales/en/mconf.yml`.
* Mconf-Web is now using myGengo for translations. You can see the project page [here](http://gengo.com/string/p/mconf-web-1).
* New rake tasks `mconf:analytics:init` and `mconf:analytics:update` that fetch information from Google Analytics to show the number of pageviews for the spaces in Mconf-Web.
* The gem `whenever` is being used to setup the crontab. See more in the update notes.
* Updated `bigbluebutton_rails` to a version with support to BigBlueButton 0.8.
* #321: Emails are now sent in the receiver's language.
* #322: Added digest emails (with recent activity in the spaces) to be sent daily or weekly if requested by the user.

### Upgrade notes

* Mconf-Web now uses `whenever` to generate/update the crontab.
  * The guides were updated to include the command to generate your crontab. See more in [[this page|Deployment-Guide-Whenever]].
  * Using `whenever` with RVM requires your to add the following line to your `~/.rvmrc` (if the file doesn't exist, create it):
    * `rvm_trust_rvmrcs_flag=1`
  * For more information check `whenever`'s [readme file](https://github.com/javan/whenever/blob/master/README.md).
* The `delayed_job` configuration file for `God` was updated. New file [here](https://github.com/mconf/mconf-web/blob/v0.6/config/god/delayed_job.god). In a deployment server this file is at `/etc/god/conf.d/delayed_job.god`
* `God` updated to version 0.12.1 and `Passenger` to version 3.0.11. To update see [[this page|Deployment-Install-Passenger]] and [[this page|Deployment-Install-God]].

## [0.5] - 2011-11-01

* `setup_conf.yml` is now optional and only used to create the seed data in the database.
* #291: First version of the federated login using Shibboleth.
* Several parameters that were only configurable via `setup_conf.yml` or command line are now available in the website interface (in the "manage" area).
* Users can request a resend of the confirmation email if needed (to confirm their registration).
* #314: Mconf-Web can be used with SSL.
* Better email and success notices when a webconference invitation is sent.

## [0.4.1] - 2011-10-18

* Small adjustments in the installation scripts.

## [0.4] - 2011-10-07

* #306: User rooms can be set as private.
* Layout changes in the homepage: focusing the spaces, now in the center.
* Layout fixes for Internet Explorer.
* #273: Admin users can set other users as admins.
* `mconf-web-conf` version 0.3 with several changes: RVM is installed as multi-user and capistrano is not required anymore. (1)
* Using [god](http://god.rubyforge.org/) to monitor processes (only delayed_job currently). (2)
* Several other bug fixes.

### Upgrade notes

* Due to the changes in (1) and (2), you'll need to do some additional configuration in your server to migrate to this version. You can see all the necessary steps in [[this wiki page|Deployment-Manual]] (search for RVM and god). If you have additional questions contact us in our mailing list.

## [0.3] - 2011-09-05

* Fixes in the upload of documents, specially in the documents tab inside spaces.
* New FAQ and Help pages.
* Users now have only one permanent webconference room.
* Integration with Mconf-Mobile.
* #237: Improved permission check for BigBlueButton rooms and servers.
* #286: Added a feedback page that is shown when the user logs out of a webconference.
* #288: Improvements in the script mconf-web-conf, specially to use Mconf-Web with Apache.
* Several other bug fixes and cleanup in the website.

## [0.2] - 2011-07-25

* Cleanup events (inside spaces). They will be a simple way to schedule conferences.
* Provide a VM with the development and production environments.
* Provide scripts to easily install Mconf-Web (development and production)
* Join conference URLs using the style: http://server/webconf/my-room
* Activity monitor to see what's happening in a BigBlueButton server.
* Other bug fixes, cleanup of broken features and usability issues.

## [0.1] - 2011-06-01

* #201: Migration of VCC to Rails 3.
* #203: Branding of VCC to become Mconf-Web.
* First integration of BBB in Mconf-Web using `bigbluebutton_rails`.
  * #206: Every space has a webconference room.
  * #207: Users can create webconferences from their home page.
* First version in production and documentation on [[how to setup a production server|Deployment]]
* Several other bugs and features implemented.

[2.3.0]: https://github.com/mconf/mconf-web/issues?q=milestone%3Av2.3.0
[2.2.0]: https://github.com/mconf/mconf-web/issues?q=milestone%3Av2.2.0
[2.1.0]: https://github.com/mconf/mconf-web/issues?q=milestone%3Av2.1.0
[2.0.1]: https://github.com/mconf/mconf-web/issues?q=milestone%3Av2.0.1
[2.0.0]: https://github.com/mconf/mconf-web/issues?q=milestone%3Av2.0.0
[0.8.1]: https://github.com/mconf/mconf-web/issues?q=milestone%3Av0.8.1
[0.8]: https://github.com/mconf/mconf-web/issues?q=milestone%3Av0.8.0
[0.7]: https://github.com/mconf/mconf-web/issues?q=milestone%3Av0.7.0
[0.6]: https://github.com/mconf/mconf-web/issues?q=milestone%3Av0.6.0
[0.5]: https://github.com/mconf/mconf-web/issues?q=milestone%3Av0.5.0
[0.4.1]: https://github.com/mconf/mconf-web/issues?q=milestone%3Av0.4.1
[0.4]: https://github.com/mconf/mconf-web/issues?q=milestone%3Av0.4.0
[0.3]: https://github.com/mconf/mconf-web/issues?q=milestone%3Av0.3.0
[0.2]: https://github.com/mconf/mconf-web/issues?q=milestone%3Av0.2.0
[0.1]: https://github.com/mconf/mconf-web/issues?q=milestone%3Av0.1.0
