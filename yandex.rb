require 'nokogiri'

class Entry
  attr_accessor :title, :url, :desc
  def to_csv
    @url||=''
    @title||=''
    @desc||=''
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

def export(entries)
  f=File.open('output.csv', 'w')
  entries.each do |e|
    f.write e.to_csv
  end
  f.close
end

def parse_file(path)
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
  entries
end

entries = []
files = get_files
files.each do |f|
  entries+=parse_file f
end
export entries