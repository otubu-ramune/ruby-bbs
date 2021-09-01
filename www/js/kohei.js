function previewImage(obj)
{
	var fileReader = new FileReader();
	fileReader.onload = (function() {
		document.getElementById('preview').src = fileReader.result;
	});
	fileReader.readAsDataURL(obj.files[0]);
}

// jQuery(document).ready(function($){
// 	  $('#toukou').paginathing({
// 		  perPage: 15,
// 		  firstLast: false,
// 		  prevText:'prev' ,
// 		  nextText:'next' ,
// 		  activeClass: 'active',
// 	  })
//   });
function getUrlQueries() {
	var queryStr = window.location.search.slice(1);  // 文頭?を除外
		queries = {};
  
	// クエリがない場合は空のオブジェクトを返す
	if (!queryStr) {
	  return queries;
	}
  
	// クエリ文字列を & で分割して処理
	queryStr.split('&').forEach(function(queryStr) {
	  // = で分割してkey,valueをオブジェクトに格納
	  var queryArr = queryStr.split('=');
	  queries[queryArr[0]] = queryArr[1];
	});
  
	return queries;
  }
function check(){
	var flag=0;
	if(document.forms['form1'].elements['value'].value==""){
		flag=1;
	}
	if(flag){
		window.alert('コメントは必須です');
		return false;
	}
	else{
		return true;
	}
}

$(function() {
	var bbs=$('#bbsname');
	var bbs_name =bbs.val();

	// function paging(){
	// 	$('#toukou').paginathing({
	// 		perPage: 5,
	// 		firstLast: true,
	// 		prevText:'prev' ,
	// 		nextText:'next' ,
	// 		activeClass: 'active',
	// 	})
	// }

	function getPage(page_num){
		alert(page_num);
		$.ajax({
			type: 'GET',
			url: `/SQL/old/${bbs_name}${page_num}`,
			dataType: 'html',
			success: function(data) {
				$('#toukou').html(data);
			},
			error:function() {
				alert('問題が発生しました。');
			}
	 });
	}


	$('#toukou > .nav-links').click(function(e) {
		e.preventDefault();
		//読み込みたい外部htmlのファイル名を取得
		var href = $(this).attr("href"); 
		alert(href);
	  
		$.ajax({
			type: 'GET',
			url: `/SQL/old/${bbs_name}${href}`,
			dataType: 'html',
			success: function(data) {
				$('#toukou').html(data);
			},
			error:function() {
				alert('問題が発生しました。');
			}
	 });
		$.ajax({
			type: 'GET',
			url: `/SQL/old/${bbs_name}${href}`,
			dataType: 'html',
			success: function(data) {
				$('#toukou').html(data);
			},
			error:function() {
				alert('問題が発生しました。');
			}
		});
	  });
	
	function getNew(){
		$.ajax({
			type: 'GET',
			url: `/SQL/new/${bbs_name}?${window.location.search.slice(1)}`,
			dataType: 'html',
			success: function(data) {
				$('#toukou').html(data);
			},
			error:function() {
				alert('問題が発生しました。');
			}
	 });
	}
	function getOld(){
		$.ajax({
			type: 'GET',
			url: `/SQL/old/${bbs_name}?${window.location.search.slice(1)}`,
			dataType: 'html',
			success: function(data) {
				$('#toukou').html(data);
			},
			error:function() {
				alert('問題が発生しました。');
			}
	 });
	}
	document.form1.action = document.form1.action + '?' + window.location.search.slice(1)
	getOld();


	$('#loader')
    .ajaxStart(function() {
        // $(this).show();
		$('#loader img').css('visibility', 'visible');
		$('#loadingtxt').text("Now Loading..")
    })
    .ajaxStop(function() {
        // $(this).hide();
		$('#loader img').css('visibility', 'hidden');
		$('#loadingtxt').text("")
    });




    $('#old-order').click(function() {
		//$('#toukou').css('flex-direction','column-reverse')
		getOld();
    });
	$('#new-order').click(function() {
		//$('#toukou').css('flex-direction','column')
		getNew();
    });

	var timer;
	// $('#button03').click(function(){
	// 	$('#auto_or_not').text("自動更新中");
	// 	timer = setInterval(function(){
			
	// 		$.ajax({
	// 			type: 'GET',
	// 			url: '/bbs_rev.html',
	// 			dataType: 'html',
	// 			success: function(data) {
	// 			 //    $('#sample01').append(data);
	// 				$('#toukou').html(data);
	// 			},
	// 			error:function() {
	// 				alert('問題が発生しました。');
	// 			}
	// 	 });
	// 	},5000);
	// });

	// $('#button04').click(function(){
	// 	$('#auto_or_not').text("自動更新OFF");
	// 	clearInterval(timer);
	// });

	
	$('#switch1').change(function(){
		var val = $('#switch1:checked').val();
		if (val) {
			// propでチェックと出力
			$('#auto_or_not').text("自動更新中");
			timer = setInterval(function(){
				$.ajax({
					type: 'GET',
					url: `/SQL/new/${bbs_name}?p=1}`,
					dataType: 'html',
					success: function(data) {
						$('#toukou').html(data);
					},
					error:function() {
						alert('問題が発生しました。');
					}
			 });
			},5000);
		  } else {
			$('#auto_or_not').text("自動更新OFF");
			clearInterval(timer);
		  }
	});




	var btn = $('.gotop-button');
  
	//スクロールしてページトップから100に達したらボタンを表示
	$(window).on('load scroll', function(){
	  if($(this).scrollTop() > 0) {
		btn.addClass('active');
	  }else{
		btn.removeClass('active');
	  }
	});
  
	//スクロールしてトップへ戻る
	btn.on('click',function () {
	  $('body,html').animate({
		scrollTop: 0
	  });
	});



});

//https://serinaishii.hatenablog.com/entry/2015/11/06/%E8%B6%85%E7%B0%A1%E5%8D%98&%E3%82%B3%E3%83%94%E3%83%9A%E3%81%A7OK%EF%BC%81%E3%83%9A%E3%83%BC%E3%82%B8%E3%83%88%E3%83%83%E3%83%97%E3%81%B8%E6%88%BB%E3%82%8B%E3%83%9C%E3%82%BF%E3%83%B3%E3%81%AE
//■page topボタン

$(function(){
	var topBtn=$('#pageTop');
	topBtn.hide();
	//◇ボタンの表示設定
	$(window).scroll(function(){
	  if($(this).scrollTop()>80){
	
		//---- 画面を80pxスクロールしたら、ボタンを表示する
		topBtn.fadeIn();
	
	  }else{
	
		//---- 画面が80pxより上なら、ボタンを表示しない
		topBtn.fadeOut();
	  }
	});
	// ◇ボタンをクリックしたら、スクロールして上に戻る
	topBtn.click(function(){
	  $('body,html').animate({
	  scrollTop: 0},500);
	  return false;
	
	});
		
});
