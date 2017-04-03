# Monkey patches to accept formats like '20 M' as '20 Mb'
# Without this change, these formats are invalid

# Regexp slightly modified from https://github.com/dominikh/filesize/blob/master/lib/filesize.rb#L14
# e.g. We consider 15MB and 15M the same here, 15000000 bytes
class Filesize
  SI[:regexp] = /^([\d,.]+)?\s?([kmgtpezy]?)b?$/i
  BINARY[:regexp] = /^([\d,.]+)?\s?(?:([kmgtpezy])i)?b?$/i
end
