# Mime Types
#Mime::Type.register "application/atomsvc+xml", :atomsvc
#Mime::Type.register "application/atomcat+xml", :atomcat
#Mime::Type.register "application/xrds+xml",    :xrds
Mime::Type.register "text/x-vcard", :vcf
Mime::Type.register "image/jpeg", :jpeg, [ "image/pjpeg" ]
Mime::Type.register "image/gif", :gif
Mime::Type.register "image/png", :png, [ "image/x-png" ]
Mime::Type.register "audio/x-wav", :wav, [ "audio/wav" ]
Mime::Type.register "audio/mpeg", :mpeg
Mime::Type.register "audio/x-vorbis+ogg", :ogg, [ "application/ogg" ]
Mime::Type.register "application/pdf", :pdf
Mime::Type.register "application/postscript", :ps, [ "application/ps" ]
Mime::Type.register "application/vnd.oasis.opendocument.text", :odt
Mime::Type.register "application/vnd.oasis.opendocument.presentation", :odp
Mime::Type.register "application/rtf", :rtf
Mime::Type.register "application/vnd.ms-word", :doc, [ "application/msword" ]
Mime::Type.register "application/vnd.ms-powerpoint", :ppt, [ "application/mspowerpoint" ]
Mime::Type.register "application/vnd.ms-excel", :xls, [ "application/msexcel" ]
Mime::Type.register "text/calendar", :ical
