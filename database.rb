require "sqlite3"
class BBS_post
    attr_accessor :bbs,:myname,:color,:content,:image,:name_id
    def initialize()
        @bbs = ""
        @myname = ""
        @color = ""
        @content  =""
        @image = ""
        @nama_id =""
    end
end

def sql(post_class)
    db = SQLite3::Database.new("bbs.db")
    bbs_name =post_class.bbs
    count = 0
    sql = 'SELECT COUNT(*) FROM html WHERE BBSname= ?;'
    db.execute(sql, bbs_name).each do |line|
        count = line[0]
    end
    myname =  post_class.myname!=nil ? post_class.myname : ""
    time = "#{Time.new}"
    color = post_class.color!=nil ? post_class.color : ""
    content = post_class.content
    image = post_class.image!=nil ? post_class.image : ""
    name_id = post_class.name_id!=nil ? post_class.name_id : ""
    db.execute("INSERT INTO html VALUES(?, ?, ?, ?, ?, ? ,?, ?);",count+1,bbs_name,myname,time,color,content,image,name_id)
    db.close
end

def print_sql(bbs,i_ ,page,cut=7)
    db = SQLite3::Database.new("bbs.db")
    test = ""
    body = ""
    bbsname=bbs
    #i 0 or 1
    i = i_
    order = ["ASC","DESC"]
    body += ERB.new(File.read("bbs_paging.erb")).result(binding)
    if i==1
        sql ='SELECT id, name,time,color,content, imageURL, ip_id FROM html WHERE BBSname= ? ORDER BY rowid DESC LIMIT ? OFFSET ?;'
    elsif i==0
        sql ='SELECT id, name,time,color,content, imageURL, ip_id FROM html WHERE BBSname= ? ORDER BY rowid ASC LIMIT ? OFFSET ?;'
    end
    puts cut.class
    
    db.execute(sql, bbsname, cut, (cut*(page-1))).each do |line|
        test += "<div class=\"post#{line[0]}\"> #{line[0]} <b>#{line[1]}</b>(#{line[2]}) ID:#{line[6]}  <br><font color='#{line[3]}'>#{line[4]}</font>"
        test += "<p class=\"photo\"><img class=\"upload-photo\" src=\"#{line[5]}\"/></p>" if line[5] != ""
        test += "</div>\n"
    end
    test ="<h2>まだ投稿がありません.</h2>" if test == ""
    db.close
    body += test
    body += ERB.new(File.read("bbs_paging.erb")).result(binding)
    body += "<a class = \"menu\" href=\"/\" style=\"text-align:center; bottom-margin:10px\" >スレッド一覧</a> "

    return body
end
def print_bbs_list_range(page=1,cut=3)
    db = SQLite3::Database.new("bbs.db")
    bbslist = []    
    sql = 'SELECT DISTINCT bbs_id FROM thread_list ORDER BY rowid DESC LIMIT ? OFFSET ?;' 
    db.execute(sql, cut, (cut*(page-1)) ).each do |line|
        bbslist.push(line[0])
    end
    db.close
    return bbslist
end


def print_list_sql(i)
    db = SQLite3::Database.new("bbs.db")
    bbs_list = print_bbs_list()
    bbs_list = bbs_list.reverse if i==1
    body = ""
    bbs_list.each do |name|
        body +="<div id=\"content_main\">\n<article class=\"article\">\n<div class=\"article-info\">\n"
        body +="<h3><a id=\"#{name}\" href=\"/#{name}\">#{id_to_name(name)}</a></h3>\n"
        array = count_data_bbs(name)
        body +="<span class=\"count\">#{array[0]}投稿</span>\n"
        body +="<time class=\"time\">#{array[2]}</time>\n"
        body +="<p><button class = \"delete\" id = \"#{name}\"><img src=\"/images/gomi.png\"></button></p>\n"
        body +="</div>\n</article>\n</div>\n"
    end
    return body
end

def add_thread(name,pass)
    db = SQLite3::Database.new("bbs.db")
    count =""
    title=""
    max=0
    db.execute("SELECT MAX(ROUND(SUBSTR(bbs_id,4))) FROM thread_list;").each do |line|
        max = line[0].to_i
    end   
    date="#{Time.new}"
    db.execute("INSERT INTO thread_list VALUES(?, ?, ?, ?, ?);",name,title,date,"bbs#{max+1}",pass)
    db.close
end
def print_bbs_list()
    db = SQLite3::Database.new("bbs.db")
    bbslist = []
    db.execute("SELECT DISTINCT bbs_id FROM thread_list;").each do |line|
        bbslist.push(line[0])
    end
    db.close
    return bbslist
end
def print_bbs_name()
    db = SQLite3::Database.new("bbs.db")
    bbslist = []

    db.execute("SELECT DISTINCT bbs_name FROM thread_list;").each do |line|
        bbslist.push(line[0])
    end
    db.close
    return bbslist
end

def count_data_bbs(bbs)
    db = SQLite3::Database.new("bbs.db")
    test = ""
    bbsname=bbs
    count = []
    sql='SELECT COUNT(*) FROM html WHERE BBSname=?;'
    db.execute(sql,bbsname).each do |line|
        count[0] = line[0]
    end
    sql = 'SELECT time FROM html WHERE BBSname= ? and (SELECT MAX(id) FROM html WHERE BBSname=?);'
    db.execute(sql, bbsname, bbsname).each do |line|
        count[1] = line[0]
    end
    sql = 'SELECT date FROM thread_list WHERE bbs_id=?;'
    db.execute(sql,bbsname).each do |line|
        count[2] = line[0]
    end
    db.close
    return count
end

def id_to_name(bbsid)
    db = SQLite3::Database.new("bbs.db")

    bbsname=""
    sql='SELECT bbs_name FROM thread_list WHERE bbs_id= ? ;'
    db.execute(sql, bbsid).each do |line|
        bbsname= line[0]
    end
    db.close
    return bbsname
end

def delete_thread(bbsid,pass)
    db = SQLite3::Database.new("bbs.db")
    sql ='DELETE FROM thread_list WHERE bbs_id=? and password =?;'
    db.execute(sql,bbsid,pass)
    sql = 'DELETE FROM html WHERE BBSname=?;'
    db.execute(sql, bbsid)
    db.close
end

def convert_path_sql(path)
    return CGI.unescape(path.split("/")[3]) if path.split("/")[3]!=nil 
end
