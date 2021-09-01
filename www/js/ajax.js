(function() {
    var httpRequest;
    var ajaxButton = document.getElementById("ajaxButton");

    var info = document.getElementById('info');
    var textNode = document.createTextNode('こんにちは');

    ajaxButton.addEventListener('click', makeRequest);
    function makeRequest(){
    httpRequest = new XMLHttpRequest();
    if (!httpRequest) {
    alert('中断：（XMLHTTP インスタンスを生成できませんでした）');
    return false;
    }
    httpRequest.onreadystatechange = alertContents;
    httpRequest.open('GET', 'js/test.txt');
    httpRequest.send();
    }
    function alertContents(){
    if (httpRequest.readyState === XMLHttpRequest.DONE) {
    if (httpRequest.status === 200) {
        info.appendChild(textNode);
    //alert(httpRequest.responseText);
    } else {
    alert('リクエストに問題が発生しました');
    }
    }
    }
    })();