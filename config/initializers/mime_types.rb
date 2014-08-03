# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone

# TODO: review if they are all needed

Mime::Type.register "audio/x-wav", :wav, [ "audio/wav" ]
Mime::Type.register "audio/x-vorbis+ogg", :ogg, [ "application/ogg" ]
Mime::Type.register "application/postscript", :ps, [ "application/ps" ]
Mime::Type.register "application/vnd.oasis.opendocument.text", :odt
Mime::Type.register "application/vnd.oasis.opendocument.presentation", :odp
Mime::Type.register "application/rtf", :rtf
Mime::Type.register "application/vnd.ms-word", :doc, [ "application/msword", "application/x-msword" ]
Mime::Type.register "application/vnd.ms-powerpoint", :ppt, [ "application/mspowerpoint" ]
Mime::Type.register "application/vnd.ms-excel", :xls, [ "application/msexcel" ]
Mime::Type.register "application/rar", :rar, [ "application/x-rar" ]
Mime::Type.register_alias "text/html", :m

# for private message views, which are essentially text possibly with html
Mime::Type.register "text/pm", :pm
