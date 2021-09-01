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
function check(){
	// alert("chekc")
	const pass = document.getElementById("pass")
	if (pass.value.match(/^[A-Za-z0-9]*$/)){
		const crypted = CybozuLabs.MD5.calc(pass.value);
		pass.value = crypted;
		return true;
	}else{
		alert("半角英数字を入力してください.");
		pass.value="";
		return false;
	}
}


$(function() {
	$.ajax({
		type: 'GET',
		url: `/SQL/new/list`,
		dataType: 'html',
		success: function(data) {
			$('#toukou').html(data);
		},
		error:function() {
			alert('問題が発生しました。');
		}
 });
	
	$('.delete').on('click', function(){
		var id =  $(this).attr("id");
		str_input = prompt("パスワード(半角英数字):","");
		while( /\W+/g.test(str_input) ) {
			// ▼半角英数字以外の文字が存在したらエラー
			alert("半角英数字のみを入力して下さい。");
			str_input = prompt("パスワード(半角英数字):","");
		 }
		md5 = CybozuLabs.MD5.calc(str_input)
		if(window.confirm('削除しますか？')){
		$.ajax({
			type: 'GET',
			url: `/SQL/delete/${id}?pass=${md5}`,
			dataType: 'html',
			success: function(data) {
				location.reload();
			},
			error:function() {
				alert('問題が発生しました。');
			}
	 });
	}
});

	var bbs=$('#bbsname');
	var bbs_name =bbs.val();

	function paging(){
		$('#toukou').paginathing({
			perPage: 5,
			firstLast: true,
			prevText:'prev' ,
			nextText:'next' ,
			activeClass: 'active',
		})
	}
	function getNew(){
		$.ajax({
			type: 'GET',
			url: `/SQL/new/list`,
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
			url: `/SQL/old/list`,
			dataType: 'html',
			success: function(data) {
				$('#toukou').html(data);
			},
			error:function() {
				alert('問題が発生しました。');
			}
	 });
	}
	// getNew();


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
		// $('#toukou').css('flex-direction','column-reverse')
		getOld();
    });
	$('#new-order').click(function() {
		// $('#toukou').css('flex-direction','column')
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
				getNew()
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
