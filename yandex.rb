require 'nokogiri'

class Entry
  attr_accessor :title, :url, :desc
  def to_csv
    @url+';'+@title+';'+@desc+"\n"
  end
end

def get_files
  dir = ARGV[0]
  dir+='/' unless dir[-1]=='/'
  files = Dir.entries dir
  files.keep_if {|f| f=~/html$/i}
  files.map! {|f| dir+f}
  files
end

path = '/media/storage/Dropbox/Temp/QYa/Гостевой пост идеи бизнеса — Яндекс  нашёлся 1 млн ответов.html'
file = File.open(path, 'r')
doc = Nokogiri::HTML(file)
entries = []
doc.css('div.serp-item__wrap').each do |item|
  title_item = item.css('a.serp-item__title-link').first
  if title_item
    entry=Entry.new
    entry.title=title_item.text
    entry.url=title_item.attr 'href'
    break if entry.url=~/yabs\.yandex\.ru/i #yandex ads
    desc_item = item.css('.serp-item__text').first
    desc = desc_item && desc_item.text
    if desc
      desc.gsub!('<b>','')
      desc.gsub!('</b>','')
    end
    entry.desc=desc
    entries << entry
  end
end
file.close
entries.each {|e| puts e.to_csv}
# puts get_files