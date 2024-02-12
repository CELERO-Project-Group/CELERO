</div>
<div class="clearfix"></div>
<div class="footer">© 2013-2023 CELERO - This site is optimized for <a href="https://www.google.com/chrome/"> Chrome
  </a>
  <div class="footer-right">
    Language
  </div>
</div>
<?php $uri = current_url(true);
if (
  $uri->getSegment(1) != "isscoping" and $uri->getSegment(1) != "isscopingauto"
  and $uri->getSegment(1) != "isScopingAutoPrjBaseMDF"
  and $uri->getSegment(1) != "isScopingAutoPrjBase"
  and $uri->getSegment(1) != "isScopingPrjBase"
  and $uri->getSegment(1) != "isScopingPrjBaseMDF"
  and $uri->getSegment(1) != "isscenarios"
  and $uri->getSegment(1) != "isscenariosCns"
  and $uri->getSegment(1) != "isScopingAutoPrjBaseMDFTest"
  and $uri->getSegment(1) != "isScopingAutoPrjBaseMDF"):
  ?>

  <script src="<?= base_url('assets/js/flatui-fileinput.js'); ?>"></script>
  <!-- The cost benefit page doesnt use the bootstrap select box features -->
  <?php if ($uri->getSegment(1) != "cost_benefit"): ?>
    <script src="<?= base_url('assets/js/bootstrap-select.js'); ?>"></script>
    <script src="<?= base_url('assets/js/application.js'); ?>"></script>
  <? endif; ?>
  <script src="<?= base_url('assets/js/bootstrap-switch.js'); ?>"></script>
  <script src="<?= base_url('assets/js/flatui-checkbox.js'); ?>"></script>
  <script src="<?= base_url('assets/js/flatui-radio.js'); ?>"></script>
  <script src="<?= base_url('assets/js/jquery.tagsinput.js'); ?>"></script>
  <script src="<?= base_url('assets/js/jquery.placeholder.js'); ?>"></script>
  <script src="<?= base_url('assets/js/holder.js'); ?>"></script>

  <link rel="stylesheet" type="text/css" href="<?= base_url('assets/css/easyui-tuna.css'); ?>">

  <script type="text/javascript">
    var marker;
    var lat, lon;

    // $('#myModal').on('shown.bs.modal', function (e) {
    //     google.maps.event.trigger(map, 'resize'); // modal acildiktan sonra haritanın resize edilmesi gerekiyor.

    //     map.setZoom(4);
    //     if(!marker)
    //         map.setCenter(new google.maps.LatLng(47.566667, 7.600000));
    //     else
    //         map.setCenter(marker.getPosition());

    //     google.maps.event.addListener(map, 'click', function(event) {
    //         $("#latId").val("Lat:" + event.latLng.lat()); $("#longId").val("Long:" + event.latLng.lng());
    //         $("#lat").val(event.latLng.lat()); $("#long").val(event.latLng.lng());
    //         placeMarker(event.latLng);
    //     });

    // });

    function placeMarker(location) {
      if (marker) {
        marker.setPosition(location);
      } else {
        marker = new google.maps.Marker({
          position: location,
          map: map
        });
      }
    }

  </script>

  <script type="text/javascript">
    $(document).ready(function () {
      $('#equipment').bind('change', function () {
        var equipmentID = $(this).val();
        $.ajax({
          url: "<?= base_url('assets/get_equipment_type'); ?>",
          async: false,
          type: "POST",
          data: "equipment_id=" + equipmentID,
          dataType: "json",
          success: function (data) {
            $('#equipmentTypeName option').remove();
            $('#equipmentAttributeName option').remove();
            for (var i = 0; i < data.length; i++) {
              $("#equipmentTypeName").append(new Option(data[i]['name'], data[i]['id']));
            }
          }
        })
      });
      $('#equipment').trigger('change');
    });
  </script>

  <script type="text/javascript">
    $(document).ready(function () {
      $('#equipmentTypeName').bind('change', function () {
        var equipmentTypeID = $(this).val();
        $.ajax({
          url: "<?= base_url('assets/get_equipment_attribute'); ?>",
          async: false,
          type: "POST",
          data: "equipment_type_id=" + equipmentTypeID,
          dataType: "json",
          success: function (data) {
            $('#equipmentAttributeName option').remove();
            for (var i = 0; i < data.length; i++) {
              $("#equipmentAttributeName").append(new Option(data[i]['attribute_name'], data[i]['id']));
            }
          }
        })
      });
      $('#equipmentTypeName').trigger('change');
    });
  </script>

<?php endif; ?>

<?php /*
<script type="text/javascript">
 $(document).ready(function () {
   $('#process').bind('change',function () {
     $("button[id*=subprocess]").parent().remove();
     $("[id*=subprocess]").remove();
     $('#lastprocess').val($(this).val());
     var stage=1;
     get_sub_process($(this).val(),stage);
   });
 });


 function get_sub_process(id,stage){
   var processID = id;

   $.ajax({
     url: "<?= base_url('assets/get_sub_process');?>",
     async: false,
     type: "POST",
     data: "processID="+processID,
     dataType: "json",
     success: function(data) {
     if(data.length > 0){
       var pro_id=stage+'subprocess'+id;
       var select=document.createElement("select");
       select.id= pro_id;
       $('#processList').append(select);

       $("#"+pro_id).addClass('select-block')
       $("select").selectpicker({style: 'btn btn-default', menuStyle: 'dropdown-inverse'});
       $("select").selectpicker('refresh');
       $("#"+pro_id).append(new Option('Please select subprocess'));
       for(var i = 0 ; i < data.length ; i++){
         $("#"+pro_id).append(new Option(data[i]['name'],data[i]['id']));
       }
       $("#"+pro_id).bind('change',function () {

         var my_id = $(this).attr('id').slice(0,1);
         for (var i = parseInt(my_id)+1 ; i < 300 ; i++) {
           if($("[id*="+i+"subprocess]").length != 0){
             $("[id*="+i+"subprocess]").remove();
             $("#processList div:last-child").remove();
           }

         }
         stage += 1;
         get_sub_process($(this).val(),stage);
         $('#lastprocess').val($(this).val());
       });

     }

     }
   })

 }
</script>
*/?>
</div>
</body>
</html>