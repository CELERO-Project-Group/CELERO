<!DOCTYPE html>
<!-- saved from url=(0062)http://www.jeasyui.com/demo/main/_content.html?_=1416390423740 -->
<html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta charset="UTF-8">
    <title>AJAX Content</title>
        <script type="text/javascript" src="jquery.min.js"></script>
</head>

<body>
    <script type="text/javascript">
        //alert('test');
        //$(function() {
        $.ajax({
            url: '../../../Proxy/SlimProxy.php/',
            type: 'GET',
            dataType : 'html',
            //data: 'selectedFlows='+JSON.stringify(columnArray),
            data: 'url=getScenarioDetailsCns_scn&id=<?= $_GET["id"]; ?>',
            success: function(data, textStatus, jqXHR) {
                //alert('test');
                number = 1;
                $.each(JSON.parse(data), function(index, item) {
                    $.each(item, function(index, detail){
                        $('#myResults_<?= $_GET["id"]; ?>').append("<b>IS Potential "+ number +"</b>");
                        $('#myResults_<?= $_GET["id"]; ?>').append("<li> From Company: "+detail.company+"</li>");
                        $('#myResults_<?= $_GET["id"]; ?>').append("<li> To Company: "+detail.tocompany+"</li>");
                        $('#myResults_<?= $_GET["id"]; ?>').append("<li> Flow: "+detail.flow+"</li>");
                        $('#myResults_<?= $_GET["id"]; ?>').append("<br>");
                        number++;
                    })
                });

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
    </script>
        <div id="myResults_<?= $_GET["id"]; ?>" style="text-align:left; padding: 5px; padding-left: 25px;" name="myResults_<?= $_GET["id"]; ?>">
        </div>
</body>
</html>


