#! /usr/bin/env ruby
# coding:UTF-8

# 重複ファイルをハードリンクに

require 'digest/md5'
require 'optparse'

DEFAULT_MINIMUM_FILE_SIZE = 10 * 1024 * 1024  # 10 MB


# keyはファイルサイズ
table = {}

min_file_size = DEFAULT_MINIMUM_FILE_SIZE

log_level = 1

OptionParser.new do |opt|
  opt.on('-n size','--min-size=size',"処理対象とする最小のファイルサイズ"){ |size|
    case size
    when /MB$/i
      min_file_size = size.sub(/MB$/i,'').to_i * 1024 * 1024
    when /KB$/i
      min_file_size = size.sub(/KB$/i,'').to_i * 1024
    when /GB$/i
      min_file_size = size.sub(/GB$/i,'').to_i * 1024 ** 3
    else
      min_file_size = size.to_i
    end
  }
  opt.on('-v','--verbose','途中経過を表示'){ log_level = 2 }
  opt.on('-q','--quiet',"経過表示を抑制"){log_level = 0 }
  opt.parse!(ARGV)
end

$stderr.puts "Minimum file size: #{min_file_size} byte."

# 読み込み
count = 0
ARGV.each do |top|
  path = File.absolute_path(top)
  $stderr.puts "searching in #{path}" if log_level > 0
  stt = path.size
  Dir.glob((path + '/**/*').encode('utf-8')) do |name|
    if File.file?(name)
      count += 1
      case name
      when %r(/.svn/), %r(/.hg/), %r(/.git/)
        # skip
      else
        size = File.size(name)
        if size >= min_file_size
          table[size] ||= []
          table[size] << name
        end
      end
    elsif File.directory?(name)
      $stderr.print "#{(name + " " * 80)[stt..(stt+75)]}\r" if log_level > 0
    end
  end
  $stderr.puts " "*77 + "\r"
end

$stderr.puts "searched: #{count} files." if log_level > 0
$stderr.puts "found file sizes: #{table.size}" if log_level > 0


table.select!{|k,a| a.size > 1}

$stderr.puts "target: #{table.size} file sizes." if log_level > 0

total_size = table.size

#out = open("Dup2HardLink.bat.txt", "w:Shift_JIS")   # 表現できない文字があり，うまくいかない．
out = open("Dup2HardLink-utf8.bat.txt", "w:UTF-8")
out.puts "@echo off"
out.puts "chcp 65001"   # UTF-8化
out.puts

log = open("Dup2HL-FileList.csv", "w:UTF-8")
log.puts "File Size, MD5, iNode, Path"

i = 0
table.keys.sort_by{|v| -v}.each do |sz|
  if log_level > 0
    i = i + 1
    $stderr.print  "#{i} of #{total_size}   \r"  if i % 10 == 0
  end
  ht = Hash.new
  table[sz].each do |name|
    key = Digest::MD5.file(name).to_s
    $stderr.puts "#{key} : #{name}" if log_level > 1
    ht[key] ||= []
    ht[key] << name
    log.puts [sz, key, File.stat(name).ino, name].join(",")
  end
  if ht.size < table[sz].size
    # 重複あり
    ht.select{|k,x| x.size > 1}.each do |k,v|
      #inoが同一の場合，すでにハードリンクがあるので，その対応をする．
      inos = {}
      v.each do |n|
        s = File.stat(n)
        inos[s.ino] ||= []
        inos[s.ino] << n
      end
      keys = inos.keys.sort_by{|k| inos[k].size}
      most = keys.pop
      # inodeが複数ある場合
      unless keys.empty?
        out.puts "rem #{'='*60}"
        out.puts "rem Size =  #{sz} byte"
        out.puts "rem MD5 = #{k}"
        base = inos[most].shift
        out.puts "rem (Base)   #{base}  (Base)"
        inos[most].each do |name|
          out.puts "rem (SkipHL) #{name}"
        end
        keys.each do |key|
          inos[key].each do |name|
            out.puts "rem name = #{name}"
          end
        end
        keys.each do |key|
          inos[key].each do |name|
            stat = File.stat(name)
            out.puts <<-"NNN"
del "#{name.gsub('/',"\\")}"
mklink /H "#{name}" "#{base}"
            NNN
            #  ハードリンクだと，タイムスタンプは同じになる様なので，省略．
            #  ruby -e 'File.utime(#{stat.atime.to_i}, #{stat.mtime.to_i}, "#{name}")'
          end
        end
        out.puts
      end
    end
  end
end

out.close

