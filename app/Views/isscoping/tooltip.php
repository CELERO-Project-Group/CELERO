<!DOCTYPE html>
<!-- saved from url=(0062)http://www.jeasyui.com/demo/main/_content.html?_=1416390423740 -->
<html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta charset="UTF-8">
	<title>AJAX Content</title>
        <script type="text/javascript" src="jquery.min.js"></script>
</head>



<body>
    
    <script>
        //alert('test');
//$(function() {
    $.ajax({
        url: '../slim_ecoman/index.php/companyEquipmentTooltip_json_test',
        type: 'GET',
        dataType : 'html',
        //data: 'selectedFlows='+JSON.stringify(columnArray),
        data: 'id=<?= $_GET["id"]; ?>',
        success: function(data, textStatus, jqXHR) {
            //alert('test');
            console.warn('ajax success');
            $('#myResults_<?= $_GET["id"]; ?>_<?= $_GET["col"]; ?>').html("<p>"+data+"</p>");
            //alert(data);
            if(!data['notFound']) {
                //console.warn('success text status-->'+textStatus);
                
                //$('#tt_grid_dynamic2').datagrid('getPanel').panel("setTitle",companyName);
            } else {
                console.warn('data notfound-->'+textStatus);
                //$.messager.alert('Pick sub flow and company','Please select  a sub flow from flow tree!','warning');
            }
        },
        error: function(jqXHR , textStatus, errorThrown) {
          console.warn('error text status-->'+textStatus);
          //console.warn(jqXHR);
        }
    });
//}); 
</script>
        <div id="myResults_<?= $_GET["id"]; ?>_<?= $_GET["col"]; ?>" name="myResults_<?= $_GET["id"]; ?>_<?= $_GET["col"]; ?>">
	<!--<p  style="font-size:14px">Here is the content loaded via AJAX.</p>
	<ul>
		<li>company id ==<?php   echo $_GET["id"];?>   easyui is a collection of user-interface plugin based on jQuery.</li>
		<li>easyui provides essential functionality for building modem, interactive, javascript applications.</li>
		<li>using easyui you don't need to write many javascript code, you usually defines user-interface by writing some HTML markup.</li>
		<li>complete framework for HTML5 web page.</li>
		<li>easyui save your time and scales while developing your products.</li>
		<li>easyui is very easy but powerful.</li>
	</ul>-->
        
        </div>
</body></html>

