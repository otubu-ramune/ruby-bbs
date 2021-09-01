# encoding: UTF-8



def send_respond(status, header, path, body, s, gzip, th1) #status, header, message, path
  if gzip
    randam = rand(1..10000).to_s
    tmp_name = DateTime.now.strftime('%Y%m%d%H%M%S') + randam +".gz"
    puts "#{tmp_name}保存"
    Zlib::GzipWriter.open(tmp_name) {|gz|
      gz.write body
    }
    body = File.binread(tmp_name)
    header = "\nContent-Encoding: gzip"  if header==nil
    header += "\nContent-Encoding: gzip" if header!=nil
    puts "圧縮送信"
    s.write(<<~EOHTTP)
    HTTP/1.0 #{status}
    #{header}

    #{body}
  EOHTTP
  File.delete(tmp_name)
  else
    s.write(<<~EOHTTP)
    HTTP/1.0 #{status}
    #{header}
    
    #{body}
  EOHTTP
  puts "非圧縮送信"
  end
  puts "#{Time.new} #{status} #{path}"
  s.close()
  th1.kill
end

def read_html(html_name, s, bbs_name = "First")
  if s.name_in_cookie == nil
    name = "名無し"
  else
    name = s.name_in_cookie != "" ? s.name_in_cookie : "名無し"
  end
  bbs = bbs_name
  
  if s.query != nil and s.query.include?("p=")
    page = s.query.split("=")[1].to_i
  else
    page=1
  end
  return ERB.new(File.read($root + "/" + html_name)).result(binding)
end

class Request_reci_
  attr_accessor :method, :root, :version, :req, :query, :length, :bound, :gzipok, :name_in_cookie, :s, :thread, :referer, :query_hassyu

  def initialize(s)
    @s = s
    @name_in_cookie = nil
  end

  def get_request
    @req = @s.gets
    if @req != nil
      @method = @req.split[0] if @req.split[0] != nil
      @root = @req.split[1].split("?")[0] if @req.split[1] != nil
      @query = @req.split[1].split("?")[1] if @req.split[1] != nil and @req.split[1].split("?")[1] != nil
      uri = URI::parse("http://localhost.com?"+@query) if @req.split[1] != nil and @req.split[1].split("?")[1] != nil
      @query_hassyu = URI::decode_www_form(uri.query) if @req.split[1] != nil and @req.split[1].split("?")[1] != nil
      @version = @req.split[2] if @req.split[2] != nil
    end
  end

  def get_header
    while req_header = @s.gets
      break if req_header == nil
      req_header = req_header.chomp
      #puts "#{req_header}"
      File.open("header.log", "a") do |f|
        f.puts(req_header)
      end
      break if req_header == "" # ヘッダー終了
      # Content-Length ヘッダーがあれば値を変数にセット
      h = req_header.split(":", 2)
      enko = /Accept-Encoding: ([a-zA-Z]+)(, ([a-zA-Z]+))*/
      if req_header =~ enko
        #puts req_header.scan(enko).size
        #puts $1
        @gzipok = req_header.include?("gzip")
      end

      rule_cookie = /name\s*\=\s*([^;]*).*$/ 
      oness = /name=([^¥S;]*)/
      if req_header =~ rule_cookie
        puts "Cookie:#{$1}"
        @name_in_cookie = CGI.unescape($1)

      end

      @length = h[1].strip.to_i if h[0].strip == "Content-Length"
      @referer = h[1].strip if h[0].strip == "Referer"
      @connection = h[1].strip if h[0].strip == "Connection"
      if h[0] == "Content-Type" and @root == "/upload"
        @bound = "--"
        @bound += h[1].split("=")[1] if h[1].split("=")[1] != nil
      end
      if h[0] == "Content-Type" and @root == "/make"
        @bound = "--"
        @bound += h[1].split("=")[1] if h[1].split("=")[1] != nil
      end
    end
  end

  def print
    puts "request:#{@req}"
    puts "method:#{@method}"
    puts "path:#{self.root}"
    puts "version:#{self.version}"
    puts "query:#{@query}"
  end
end

def content_type(path)
  content_map = {
    ".png" => "Content-Type: image/png",
    ".html" => "Content-Type: text/html; charset=utf-8",
    ".txt" => "Content-Type: text/plain",
    ".htm" => "Content-Type: text/html",
    ".mp4" => "Content-Type: video/mp4",
    ".css" => "Content-Type: text/css",
    ".js" => "Content-Type: text/javascript",
    ".json" => "Content-Type: application/json",
    ".ico" => "Content-Type: image/vnd.microsoft.icon",
    ".gif" => "Content-Type: image/gif",
    ".jpeg" => "Content-Type: image/jpeg",
    ".jpg" => "Content-Type: image/jpeg",
    ".JPG" => "Content-Type: image/jpeg",
  }
  return content_map[File.extname(path)]
end
