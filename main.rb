require "socket"
require "cgi/util"
require "pathname"

require "date"
require "sanitize"
require "zlib"
require "fileutils"
require "erb"
require 'digest/sha1'
require 'base64'
require 'uri'

require "./http_class"
require "./multidata"
require "./database"

ss = TCPServer.open(8080)

puts "starting Server"
LOG = Pathname(__dir__) / "bbs.html"
ADDR = Pathname(__dir__) / "ip_addr.log"
BODY_log = Pathname(__dir__) / "file.log"
PN = Pathname(__dir__) / "a.png"

dire = "/www"
$root = Dir.pwd + dire

loop do
  th1 = Thread.start(ss.accept) do |s|
    http_request = Request_reci_.new(s)
    http_request.get_request
    http_request.get_header
    http_request.s = s
    http_request.thread = th1

    path = http_request.root
    query = http_request.query

    puts "query:#{http_request.query_hassyu}"

    sock_domain, remote_port, remote_hostname, remote_ip = s.peeraddr
    bound = ""

    path = Sanitize.clean(path)

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
    status_res = { :ok => "200 OK", :nf => "404 Not Found", :moved => "302 Moved", :redirect => "303 Redirect", :Error => "500 Internal Server Error" }


    if http_request.query != nil and http_request.query.include?("p=")
      page = http_request.query.split("=")[1].to_i
    else
      page=1
    end
    # puts "#{Time.new} #{http_request.method} path:#{path} quey:#{http_request.query_hassyu}"


    
    #puts "refere:#{http_request.referer}" if http_request.referer != nil
    req_path = $root + path
    #スレッド中身を表示するためのhtml送信
    if print_bbs_list.include?(CGI.unescape(path.delete_prefix("/")))
      body = read_html("index_head.html", http_request, CGI.unescape(path.delete_prefix("/")))
      send_respond(status_res[:ok], content_map[".html"], path, body, s, http_request.gzipok, th1)
    #ajaxによるものの処理
    elsif path == "/SQL/new" or path.include?("/SQL/new")
      if print_bbs_list.include?(convert_path_sql(path))
        body = print_sql(convert_path_sql(path), i_ = 1, page)
        body = "<h2>  まだ投稿は有りません</h2>" if body == "" and page==1
      #未使用
      elsif "list"== convert_path_sql(path)
        body = print_list_sql(i_ =1)
      else
        send_respond(status_res[:nf], header = content_map[".html"] + " \nLocation: /", path, read_html("not_found.html", http_request), s, http_request.gzipok, th1)
      end
      send_respond(status_res[:ok], content_map[".html"], path, body, s, http_request.gzipok, th1)
    elsif path == "/SQL/old" or path.include?("/SQL/old")
      if print_bbs_list.include?(convert_path_sql(path))
        body = print_sql(convert_path_sql(path), i_ = 0 ,page)
        body = "<h2>  まだ投稿は有りません</h2>" if body == "" and page==1
      #未使用
      elsif "list"== convert_path_sql(path)
        body = print_list_sql(i_ = 0)
      else
        send_respond(status_res[:nf], header = content_map[".html"] + " \nLocation: /", path, read_html("not_found.html", http_request), s, http_request.gzipok, th1)
      end
      send_respond(status_res[:ok], content_map[".html"], path, body, s, http_request.gzipok, th1)
    elsif path == "/SQL/delete" or path.include?("/SQL/delete")
      if print_bbs_list.include?(convert_path_sql(path))
        pass =Hash[http_request.query_hassyu]
        pass = pass["pass"]
        delete_thread(convert_path_sql(path),pass)
        send_respond(status_res[:ok], "", path, "", s, http_request.gzipok, th1)
      else
        send_respond(status_res[:Error], "", path, "", s, http_request.gzipok, th1)
      end

      #GETメソッドの場合の処理
    elsif http_request.method == "GET"
      if File.directory?(req_path) 
        header = " \nLocation: /guide.html" 
        send_respond(status_res[:redirect], header, path, "", s, http_request.gzipok, th1)
      elsif File.exist?(req_path) or File.exist?(CGI.unescape(req_path))
        if File.extname(req_path) == ".html" or File.extname(req_path) == ".js" or File.extname(req_path) == ".css"
          binary_data = read_html(CGI.unescape(path), http_request)
        else
          binary_data = File.binread(CGI.unescape(req_path))
        end
        send_respond(status = "200 OK", content_type(req_path), path, binary_data, s, http_request.gzipok, th1)
      else
        send_respond(status_res[:nf], header = content_map[".html"] + " \nLocation: /", path, read_html("not_found.html", http_request), s, http_request.gzipok, th1)
      end
      #POSTメソッドの場合の処理
    elsif http_request.method == "POST"
      if http_request.length != nil
        params = s.read(http_request.length)
        File.open(BODY_log, "w") do |f|
          f.puts(params)
        end
        photo = []
        #投稿はupload スレ作成はmake
        if path == "/upload" or path == "/make"
          bound = http_request.bound
          bound1 = http_request.bound
          bound2 = http_request.bound + "--"
          puts "bound:#{bound1}"
        end
        
        post_content = BBS_post.new()

        header = ""
        body = ""
        myname = "名無し"
        value = ""
        value2 = ""
        color = ""
        #https://qiita.com/wai-doi/items/e6101e912f45f11d5e5e

        multi_data = multipart(bound1, params)
        syasin = ""
        myname = CGI.unescape(multi_data["myname"]) if multi_data["myname"] != nil
        myname = Sanitize.clean(myname) if multi_data["myname"] != nil
        value = multi_data["value"].gsub(/\R/, "<br>") if multi_data["value"] != nil
        color = CGI.unescape(multi_data["color"]) if multi_data["color"] != nil
        bbs_name = multi_data["bbs"] if multi_data["bbs"] != nil
        thread_name = CGI.unescape(multi_data["bbsname"]) if multi_data["bbsname"] != nil
        thread_name = Sanitize.clean(thread_name) if thread_name!=nil
        puts multi_data
        if path == "/make"
          puts "名前かぶってる！！" if print_bbs_name().include?(thread_name)
          puts "make_thread:#{thread_name}" if print_bbs_name().include?(thread_name)==false
          add_thread(thread_name,multi_data["password"]) if thread_name != "" and print_bbs_name().include?(thread_name) == false
          bbs_name = "guide.html"
        end

        url = /(.*)?(http[s|]?:\/\/[\w\-\_\.\!\*\'\)\(\/\?\&\#\~\@\=\+\%\;\:\$\,]+)(.*)?/ #/(http[s|]?:\/\/[\w\-\_\.\!\*\'\)\(\/\?\&\#\~\@\=\+\%\;\:\$\,]+)/
        #/(http?s?\:\/\/[\-_\.\!\~\*\'\(\)a-zA-Z0-9\;\/\?\:\@\&\=\+\$\,\%\#]+)/
        #/(http?s?\:\/\/[\;\:\$\,]+)/

        #メッセージ部にURL
        if value =~ url
          mae = CGI.unescape($1)
          usiro = CGI.unescape($3)
          mae = Sanitize.clean(mae, elements: ["br"])
          usiro = Sanitize.clean(usiro, elements: ["br"])
          value = value.gsub(url, "#{mae}<a href=\"#{$2}\" onclick=\"return confirm('外部のページへ移動します。よろしいですか？#{$2}')\" target=\"_blank\">#{$2}</a>#{usiro}")
          value = CGI.unescape(value)
        else
          value = CGI.unescape(value)
          value = Sanitize.clean(value, elements: ["br", "a"]) #=> %w{a br})
        end

        if multi_data[multi_data["example1"]] != nil and value != ""
          photo_name = CGI.unescape(multi_data["example1"])
          photo_ = multi_data[multi_data["example1"]]

          basename = File.basename(photo_name, ".*")
          ext = File.extname(photo_name)
          image_name = "/images/#{basename}#{ext}"
          change = 0
          #同一名のファイルが存在
          while File.exist?($root + image_name)
            basename += "X"
            image_name = "/images/#{basename}#{ext}"
            change = 1
          end
          File.open($root + image_name, "w") do |f|
            f.puts(photo_)
          end
          #ファイルの中身が一緒なら変更した名前のものを消す
          if change == 1 and FileUtils.cmp($root + image_name, $root + "/images/" + photo_name)
            File.delete($root + image_name)
            puts image_name
            image_name = "/images/#{photo_name}"
          end
          syasin = image_name != nil ? "<p class=\"photo\"><img class=\"upload-photo\" src=\"#{image_name}\"/></p>" : ""
        end

        status = "303 Redirect"
        header = "Location: /#{bbs_name}?p=#{page}"
        header += "\nSet-Cookie: name=#{CGI.escape(myname)}"
        ip = []
        if value != ""
          test_id = Base64.encode64(Digest::SHA1.hexdigest(remote_ip))
          post_content.myname = myname
          post_content.color = color
          post_content.content = value
          post_content.image = image_name
          post_content.bbs = bbs_name
          post_content.name_id = test_id[0,8]
          sql(post_content)

          ip.unshift("name:#{myname}\tIP:#{remote_ip}\tTime:(#{Time.new})\tID*#{test_id[0,8]}\n")
          File.open(ADDR, "a") do |f|
            f.print ip.join("\n")
          end
        end

        send_respond(status_res[:redirect], header, path, body, s, http_request.gzipok, th1)
      #不使用
      elsif path == "/"
        status = "200 OK"
        header = "Content-Type: text/html; charset=utf-8 \nLocation: /"
        body = read_html("guide.html", http_request)
        send_respond(status_res[:ok], header, path, body, s, http_request.gzipok, th1)
      #不使用
      else
        header = "Location: /"
        send_respond(status_res[:moved], header, path, "", s, http_request.gzipok, th1)
      end
    end

    s.close
  end
end
