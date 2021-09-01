require "cgi/util"
# どこでも使える変数を作る
$_GET = {}
$_POST = {}
$_COOKIE = {}
$_FILES = []
# マルチパートデータを処理
private
def multipart(bound,params)

  # 変数の初期化
  key,val,file,type = '','','',''
  h = {}
  f = []
  rec = 0

  # 正規表現をコンパイル
  # 区切り文字判定
  r1 = /#{bound}/
  # ファイル判定
  r2 = /Content-Disposition: form-data; name="([^"]+)"; filename="([^"]+)"/
  # 通常のフォーム項目
  r3 = /Content-Disposition: form-data; name="([^"]+)"/
  # アップロードされたファイルタイプ
  r4 = /Content-Type: (.+)/
  # 標準入力から一行ずつ処理
  params.each_line do |li|   
    li_utf8 = li
    # 区切り文字があった場合
    if li_utf8 =~ r1


      # キーがあった場合
      if key!=''
        
        # 末尾の改行を除去
        val.chomp!
        # フォームデータがファイルの場合
        if file!=''
          setHash(key,file,h)
          setHash(file,val,h)
        # 通常のフォームデータ
        else
          # puts "key:#{key}"
          # puts "val:#{val}"
          # puts "h:#{h}"
          setHash(key,val,h)  
        end
        key = ''
        val = ''
      end
      rec = 0

    # データの結合
    elsif rec==1
      val << li

    # フォームのname属性とアップロードファイル名を取得
    elsif li_utf8 =~ r2

      key = $1
      file = $2

    # 通常のフォームデータの場合
    elsif li_utf8 =~ r3

      key = $1

    # アップロードされたファイルタイプ
    elsif li_utf8 =~ r4

      type = $1.chomp

    # データ内容の開始判定
    elsif rec==0 && li_utf8 =~ /\R/#r5
      rec = 1
    end
  end
  # ファイル情報を代入
  $_FILES = f

  return h
end

# ハッシュに保存する処理
private
def setHash(key,val,h)
  url = /(http[s|]:\/\/[\w\-\_\.\!\*\'\)\(\/\?\&\#\~\@\=\+\%\;\:\$\,]+)/
  if val =~ url
    a= val.gsub(url, "<a href=\"#{$1}\" target=\"_blank\">#{$1}</a>" )
    puts "a:#{a}"
  end
  # キーがすでにある場合、値を配列に
  if h.key?(key)
    
    # 値が配列の場合、最後に追加
    if h[key].class==Array
      
      
      h[key] << val#!=nil ? CGI.escape(val) : val

    # 値が文字列の場合、配列に
    else

      h[key] = [h[key],val]
    end
  else

    h[key] = val#=nil ? CGI.escape(val) : val
  end

end
