<script type="text/javascript">
var pathname = window.location.pathname;
var prj_id = pathname.split("/")[2];
var cmpny_id = pathname.split("/")[3];
$(document).ready(function() {
    $("#prcss_name").change(function() {
    	var prcss_id = $( "#prcss_name").val();
        $('#flow_name').children().remove();
        $('#flow_type_name').children().remove();
        //empties all allocation fields when a process is selected, values stay in place if submit fails

		$('#allocation_fields').children().find('input[type=text]:not([id^="error"]), textarea').val("");

        $.ajax({
            type: "POST",
            dataType:'json',
            url: '<?= base_url('cp_allocation_array'); ?>/'+cmpny_id,
            success: function(data)
            {
            	$('#flow_name').append('<option value="" disabled selected><?= lang("pleaseselect"); ?></option>');
           		for(var k = 0 ; k < data.length ; k++){
           			if(data[k].company_process_id == prcss_id){
                    	$('#flow_name').append('<option value="'+data[k].flow_id+'">'+data[k].flowname+" ("+data[k].flow_type_name+')</option>');
                    }
                }
                $('#flow_type_name').append('<option value="0" disabled selected><?= lang("pleaseselect"); ?></option>');
           		for(var k = 0 ; k < data.length ; k++){
           			if(data[k].company_process_id == prcss_id){
       					if(!optionExists(data[k].flow_type_id)){
                			$('#flow_type_name').append('<option value="'+data[k].flow_type_id+'">'+data[k].flow_type_name+'</option>');
       					}
                    }
                }
            }
        });
    });
    //if the page submit fails (not all mandatory fields), this is triggered and re-sets the flow and flow type dropdown
    if(<?= set_value("flow_name") ?: "0" ?> != "0"){
    	$("#prcss_name").val("<?= set_value('prcss_name') ?>");

    	var prcss_id = $( "#prcss_name").val();
    	var isselected = "";
    	$.ajax({
            type: "POST",
            dataType:'json',
            url: '<?= base_url('cp_allocation_array'); ?>/'+cmpny_id,
            success: function(data)
            {
            	//fills the flow dropdown and sets "selected" where the php set_value matches, if no php set_value is set the output is 0
           		for(var k = 0 ; k < data.length ; k++){
           			if(data[k].company_process_id == prcss_id){
           				if (data[k].flow_id  == <?= set_value("flow_name") ?: "0" ?>) {
           					$('#flow_name').append('<option value="'+data[k].flow_id+'" selected>'+data[k].flowname+" ("+data[k].flow_type_name+')</option>');
           				} else {
           					$('#flow_name').append('<option value="'+data[k].flow_id+'">'+data[k].flowname+" ("+data[k].flow_type_name+')</option>');
           				}
                    }
                }
                $('#flow_type_name').append('<option value="0" disabled selected><?= lang("pleaseselect"); ?></option>');
           		for(var k = 0 ; k < data.length ; k++){
           			if(data[k].company_process_id == prcss_id){
       					if(!optionExists(data[k].flow_type_id)){
                			$('#flow_type_name').append('<option value="'+data[k].flow_type_id+'">'+data[k].flow_type_name+'</option>');
       					}
                    }
                }
                $('#flow_type_name').val("<?= set_value('flow_type_name') ?>");
            }
        });

    };

    //when a flow is selected
    $("#flow_name").change(function() {
    	//empties all allocation fields if not yet submited, values stay in place if submit fails
    	if(<?= set_value("flow_name") ?: "0" ?> == "0"){
	    	$('#allocation_fields').children().find('input[type=text]:not([id^="error"]), textarea').val("");
			$('#allocation_fields').children().find("#unit_env_impact").val("EP");
		}
		//sets flow_type_name accordingly to selected flow_name
		if ($(this).children("option:selected").text().split("(").pop() == "Input)"){
        	$('#flow_type_name').val("1").change();
     	}
     	else {
     		$('#flow_type_name').val("2").change();
     	}
	});
});
$(document).on("submit", "form", function (e) {
	 //removes the disabled from the flow_tap_name select form for submission
	 $('#flow_type_name').removeAttr('disabled');
});

function optionExists(val) {
  return $("#flow_type_name option[value='" + val + "']").length !== 0;
}

//already allocated table fill function
function aatf() {
/*		$( "#aprocess" ).text($('#prcss_name').val());
		$( "#aflow" ).text($('#flow_name').val());
		$( "#atype" ).text($('#flow_type_name').val());*/

		//define variables
 		var project_id = "<?= $this->session->userdata('project_id'); ?>";
 		var process_id = $('#prcss_name').val();
 		var flow_id = $('#flow_name').val();
 		var flow_type_id = $('#flow_type_name').val();
 		var cmpny_id = "<?= $this->uri->segment(3); ?>";

		//get other allocation data for a selected flow and flow type
		$.ajax({
			type: "POST",
			dataType:'json',
			url: '<?= base_url('cpscoping/allocated_table'); ?>/'+flow_id+'/'+flow_type_id+'/'+cmpny_id+'/'+process_id+'/'+project_id,
			success: function(data)
			{
				var vPool="";
				for (var i = 0; i < data.length; i++) {

					vPool += '<div class="col-md-4"><table style="width:100%;"><tr><td colspan="3" style="height:60px;"><?= lang("process"); ?>: ' + data[i].prcss_name + '</td></tr><tr><td><?= lang("amount"); ?></td><td>' + data[i].amount + ' ' + data[i].unit_amount + ' <span class="label label-default">Accuracy: ' + data[i].error_amount + '%</span></td><td style="width:70px;"><?= lang("allocated"); ?>: '+data[i].allocation_amount+'%</td></tr><tr><td><?= lang("cost"); ?></td><td>' + data[i].cost + ' ' + data[i].unit_cost + ' <span class="label label-default">Accuracy: ' + data[i].error_cost + '%</span></td><td style="width:70px;"><?= lang("allocated"); ?>: '+data[i].allocation_cost+'%</td></tr><tr><td><?= lang("ep"); ?></td><td>' + data[i].env_impact + ' ' + data[i].unit_env_impact + ' <span class="label label-default">Accuracy: ' + data[i].error_ep + '%</span></td><td style="width:70px;"><?= lang("allocated"); ?>: '+data[i].allocation_env_impact+'%</td></tr></table><br></div>';
					//alert(data);

				}
				$( "#aallocated" ).html(vPool);
				//console.log(data);
			}
		});
	}
</script>
<?php if (validation_errors() != NULL): ?>
    <div class="alert alert-danger">
			<button type="button" class="close" data-dismiss="alert">&times;</button>
			<div>Form couldn't be saved. Please fix the errors.</div>
      	<div class="popover-content">
      		<?= validation_errors(); ?>
      	</div>
    </div>
<?php endif?>
<?= form_open_multipart('cpscoping/' . $project_id . '/' . $company_id . '/allocation'); ?>
	<div>
		<div class="col-md-3">
			<div><span class="badge">1</span> <?= lang("alloheading1"); ?></div>
			<hr>
			<div class="form-group row">
				<label for="prcss_name" class="control-label col-md-12"><?= lang("selectprocess"); ?></label>
				<div class="col-md-12">
					<select name="prcss_name" id="prcss_name" onchange="aatf()" value="<?= set_value('prcss_name'); ?>" class="btn-group select select-block">
						<option value=""><?= lang("pleaseselect"); ?></option>
						<?php
$kontrol = array();
$index   = 0;
?>
						<?php for ($i = 0; $i < sizeof($prcss_info); $i++): ?>
							<?php
$isselected = "";
if ($prcss_info[$i]['company_process_id'] == set_value('prcss_name')) {
    $isselected = "selected";
}
?>
							<option value="<?= $prcss_info[$i]['company_process_id']; ?>" <?= $isselected; ?>><?= $prcss_info[$i]['prcessname']; ?></option>
						<?php endfor?>
					</select>
				</div>
			</div>

			<div class="form-group row">
				<label for="flow_name" class="control-label col-md-12"><?= lang("selectflow"); ?></label>
				<div class="col-md-12">
					<select name="flow_name" id="flow_name" onchange="aatf()" class="btn-group select select-block">
						<option value=""><?= lang("pleaseselect"); ?></option>
					</select>
				</div>
			</div>

			<div class="form-group clearfix row">
				<label for="flow_type_name" class="control-label col-md-12"><?= lang("selectflowtype"); ?></label>
				<div class="col-md-12">
					<select name="flow_type_name" id="flow_type_name" onchange="aatf()" class="btn-group select select-block" disabled="true">
						<option><?= lang("pleaseselect"); ?></option>
					</select>
				</div>
			</div>
			<?php //print_r($company_flows); ?>
			<div><?= lang("companyflows"); ?></div>
			<hr>
			<?php if (!empty($company_flows)): ?>
				<table class="table" style="font-size:12px;">
					<tr>
						<th><?= lang("name"); ?></th>
						<th colspan="2" style="text-align: center;"><?= lang("amount"); ?></th>
						<th colspan="2" style="text-align: center;"><?= lang("cost"); ?></th>
					</tr>
				<?php foreach ($company_flows as $f): ?>
					<tr>
						<td><?= $f['flowname']; ?></td>
						<td class="table-numbers"><?= $f['qntty']; ?> </td>
						<td class="table-units"><?= $f['qntty_unit_name']; ?></td>
						<td class="table-numbers"><?= $f['cost']; ?> </td>
						<td class="table-units"><?= $f['cost_unit']; ?></td>
					</tr>
				<?php endforeach?>
				</table>
			<?php else: ?>
				<?= lang("alloheading2"); ?>
			<?php endif?>
			<div><?= lang("companyproducts"); ?></div>
			<hr>
			<?php if (!empty($product)): ?>
				<table class="table" style="font-size:12px;">
					<tr>
						<th><?= lang("name"); ?></th>
						<th colspan="2" style="text-align: center"><?= lang("quantity"); ?></th>
						<th colspan="2" style="text-align: center"><?= lang("cost"); ?></th>
						<th><?= lang("period"); ?></th>
					</tr>
				<?php foreach ($product as $p): ?>
					<tr>
						<td><?= $p['name']; ?></td>
						<td class="table-numbers"><?= $p['quantities']; ?> </td>
						<td class="table-units"><?= $p['qunit']; ?></td>
						<td class="table-numbers"><?= $p['ucost']; ?></td>
						<td class="table-units"><?= $p['ucostu']; ?></td>
						<td style="text-align: center"><?= $p['tper']; ?></td>
					</tr>
				<?php endforeach?>
				</table>
			<?php else: ?>
				<?= lang("alloheading3"); ?>
			<?php endif?>
		</div>
		<div class="col-md-9" id="allocation_fields">
			<div><span class="badge">2</span> <?= lang("alloheading4"); ?></div>
			<hr>
			<div class="form-group clearfix row">
				<label class="control-label col-md-3 tooltip-amo" data-toggle="tooltip">
					<?= lang("amount"); ?>  <i style="color:red;" class="fa fa-question-circle"></i></label>
				<label class="control-label col-md-3"><?= lang("amountunit"); ?></label>
				<label class="control-label col-md-3 tooltip-allo" data-toggle="tooltip"><?= lang("allocation"); ?> (%) <i style="color:red;" class="fa fa-question-circle"></i></label>
				<label class="control-label col-md-3 tooltip-acc" data-toggle="tooltip"><?= lang("accuracyrate"); ?> (%) <i style="color:red;" class="fa fa-question-circle"></i></label>
				<div class="col-md-3">
					<input type="text" class="form-control" value="<?= set_value('amount'); ?>" id="amount" placeholder="<?= lang("number"); ?>" name="amount">
				</div>
				<div class="col-md-3">
					<select name="unit_amount" id="unit_amount" class="btn-group select select-block">
						<option value=""><?= lang("pleaseselect"); ?></option>
						<?php foreach ($unit_list as $u): ?>
							<option value="<?= $u['name']; ?>" <?= set_select('unit_amount', $u['name']); ?>><?= $u['name']; ?></option>
						<?php endforeach?>
					</select>
				</div>
				<div class="col-md-3">
					<input type="text" class="form-control" value="<?= set_value('allocation_amount'); ?>" id="allocation_amount" placeholder="<?= lang("percentage"); ?>" name="allocation_amount">
				</div>

				<div class="col-md-3">
					<input type="text" class="form-control" value="<?= set_value('error_amount', 80); ?>" id="error_amount" placeholder="<?= lang("percentage"); ?>" name="error_amount">
				</div>
			</div>
			<hr>
			<div class="form-group clearfix row">
				<label class="control-label col-md-3"><?= lang("cost"); ?></label>
				<label class="control-label col-md-3"><?= lang("costunit"); ?></label>
				<label class="control-label col-md-3 tooltip-allo" data-toggle="tooltip"><?= lang("allocation"); ?> (%) <i style="color:red;" class="fa fa-question-circle"></i></label>
				<label class="control-label col-md-3 tooltip-acc" data-toggle="tooltip"><?= lang("accuracyrate"); ?> (%) <i style="color:red;" class="fa fa-question-circle"></i></label>
				<div class="col-md-3">
					<input type="text" class="form-control" value="<?= set_value('cost'); ?>" id="cost" placeholder="<?= lang("number"); ?>" name="cost">
				</div>
				<div class="col-md-3">
					<select name="unit_cost" id="unit_cost" class="btn-group select select-block">
						<option value=""><?= lang("pleaseselect"); ?></option>
						<option value="Euro" <?= set_select('unit_cost', 'Euro'); ?>>Euro</option>
						<option value="Dollar" <?= set_select('unit_cost', 'Dolar'); ?>>Dollar</option>
						<option value="TL" <?= set_select('unit_cost', 'TL'); ?>>TL</option>
						<option value="CHF" <?= set_select('unit_cost', 'CHF'); ?>>CHF</option>
					</select>
				</div>
				<div class="col-md-3">
					<input type="text" class="form-control" value="<?= set_value('allocation_cost'); ?>" id="allocation_cost" placeholder="<?= lang("percentage"); ?>" name="allocation_cost">
				</div>
				<div class="col-md-3">
					<input type="text" class="form-control" value="<?= set_value('error_cost', 80); ?>" id="error_cost" placeholder="<?= lang("percentage"); ?>" name="error_cost">
				</div>
			</div>
			<hr>
			<div class="form-group clearfix row">
				<label class="control-label col-md-3"><?= lang("environmentalimpact"); ?></label>
				<label class="control-label col-md-3"><?= lang("ep"); ?></label>
				<label class="control-label col-md-3 tooltip-allo" data-toggle="tooltip"><?= lang("allocation"); ?> (%) <i style="color:red;" class="fa fa-question-circle"></i></label>
				<label class="control-label col-md-3 tooltip-acc" data-toggle="tooltip"><?= lang("accuracyrate"); ?> (%) <i style="color:red;" class="fa fa-question-circle"></i></label>
				<div class="col-md-3">
					<input type="text" class="form-control" value="<?= set_value('env_impact'); ?>" id="env_impact" placeholder="<?= lang("number"); ?>" name="env_impact">
				</div>
				<div class="col-md-3">
					<input class="form-control" id="unit_env_impact" placeholder="EP" value="EP" name="unit_env_impact" readonly>
				</div>
				<div class="col-md-3">
					<input type="text" class="form-control" value="<?= set_value('allocation_env_impact'); ?>" id="allocation_env_impact" placeholder="<?= lang("percentage"); ?>" name="allocation_env_impact">
				</div>
				<div class="col-md-3">
					<input type="text" class="form-control" value="<?= set_value('error_ep', 80); ?>" id="error_ep" placeholder="<?= lang("percentage"); ?>" name="error_ep">
				</div>
			</div>
			<hr>
			<div class="form-group clearfix row">
				<label class="control-label col-md-3 tooltip-ref" data-toggle="tooltip">
					<?= lang("reference"); ?> <i style="color:red;" class="fa fa-question-circle"></i></label>
				<label class="control-label col-md-3"><?= lang("unit"); ?></label>
				<label class="control-label col-md-6"><?= lang("nameofref"); ?></label>
				<div class="col-md-3">
					<input type="text" class="form-control" value="<?= set_value('reference'); ?>" id="reference" placeholder="<?= lang("number"); ?>" name="reference">
				</div>
				<div class="col-md-3">
					<select name="unit_reference" id="unit_reference" class="btn-group select select-block">
						<option value=""><?= lang("pleaseselect"); ?></option>
						<?php foreach ($unit_list as $u): ?>
							<option value="<?= $u['name']; ?>" <?= set_select('unit_reference', $u['name']); ?>><?= $u['name']; ?></option>
						<?php endforeach?>
					</select>
				</div>
				<div class="col-md-6">
					<input type="text" class="form-control" value="<?= set_value('nameofref'); ?>" id="nameofref" placeholder="<?= lang("nameofref"); ?>" name="nameofref">
				</div>
			</div>
			<hr>
			<div class="form-group clearfix row">
				<label class="control-label col-md-3">
                    <?= lang("kpi"); ?>
                </label>
				<label class="control-label col-md-3"><?= lang("kpiunit"); ?></label>
				<label class="control-label col-md-6"><?= lang("kpidef"); ?></label>
				<div class="col-md-3">
					<input class="form-control" id="kpi" placeholder="" name="kpi" readonly>
				</div>
				<div class="col-md-3">
					<input class="form-control" id="unit_kpi" placeholder="" name="unit_kpi" readonly>
				</div>
				<div class="col-md-6">
					<input type="text" class="form-control" id="kpidef" value="<?= set_value('kpidef'); ?>" placeholder="<?= lang("kpidef"); ?>" name="kpidef">
				</div>

			</div>
			<div>
				<button type="submit" class="btn btn-success"><i class="fa fa-floppy-o"></i> <?= lang("savedata"); ?></button>
				<a href="<?= base_url('cpscoping'); ?>" class="btn btn-default" style="float: right;"><i class="fa fa-ban" ></i> <?= lang("cancel"); ?></a>
			</div>
			<div style="margin-top:30px;"><span class="badge">3</span> <?= lang("alloheading5"); ?></div>
			<hr>
			<div id="aallocated" class="row">
<!-- 				<span id="aprocess"></span>
				<span id="aflow"></span>
				<span id="atype"></span> -->
				<div class="col-md-12"><?= lang("alloheading6"); ?></div>
			</div>
		</div>
	</div>
</form>
<script type="text/javascript">
	$("#amount").change(hesapla);
	$("#reference").change(hesapla);
	function hesapla() {
		$("#kpi").val(Number(($("#amount").val()/$("#reference").val()).toFixed(5)));
	}
	$("#unit_amount").change(unit_hesapla);
	$("#unit_reference").change(unit_hesapla);
	function unit_hesapla(){
		$("#unit_kpi").val($("#unit_amount option:selected").text()+"/"+$("#unit_reference option:selected").text());
	}
</script>
<script type="text/javascript">	$( document ).ready(unit_hesapla); $( document ).ready(hesapla);</script>
<script type="text/javascript">
//tooltip accuracy field
$('.tooltip-acc').tooltip({
    position: 'top',
    content: '<span style="color:#fff"><?= lang("accuratei"); ?></span>',
    onShow: function(){
        $(this).tooltip('tip').css({
            backgroundColor: '#999',
            borderColor: '#999'
        });
    }
});
//tooltip reference field
$('.tooltip-ref').tooltip({
    position: 'top',
    content: '<span style="color:#fff"><?= lang("reference-ttip"); ?></span>',
    onShow: function(){
        $(this).tooltip('tip').css({
            backgroundColor: '#999',
            borderColor: '#999'
        });
    }
});
//tooltip amount field
$('.tooltip-amo').tooltip({
    position: 'top',
    content: '<span style="color:#fff"><?= lang("amount-ttip"); ?></span>',
    onShow: function(){
        $(this).tooltip('tip').css({
            backgroundColor: '#999',
            borderColor: '#999'
        });
    }
});
//tooltip allocation field
$('.tooltip-allo').tooltip({
    position: 'top',
    content: '<span style="color:#fff"><?= lang("allocation-ttip"); ?></span>',
    onShow: function(){
        $(this).tooltip('tip').css({
            backgroundColor: '#999',
            borderColor: '#999'
        });
    }
});
</script>
<script type="text/javascript">
$('#flow_type_name').change(function(b){
	var cmpny_id = "<?= $this->uri->segment(3); ?>";

	var e = document.getElementById("prcss_name");
	var prcss_name = e.options[e.selectedIndex].value;
	var b = document.getElementById("flow_type_name");
	var flow_type_name = b.options[b.selectedIndex].value;
	var a = document.getElementById("flow_name");
	var flow_name = a.options[a.selectedIndex].value;
	console.log(prcss_name+" "+flow_name+" "+flow_type_name);
	//get other allocation data for a selected flow and flow type
	$.ajax({
		type: "POST",
		dataType:'json',
		url: '<?= base_url('cpscoping/full_get'); ?>/'+flow_name+'/'+flow_type_name+'/'+cmpny_id+'/'+prcss_name,
		success: function(data)
		{
			document.getElementById('amount').value=data.qntty;
			document.getElementById('cost').value=data.cost;
			document.getElementById('env_impact').value=data.ep;

			document.getElementById('allocation_amount').value="100";
			document.getElementById('allocation_cost').value="100";
			document.getElementById('allocation_env_impact').value="100";

			$('#unit_amount').val(data.qntty_unit_name).change();
			$('#unit_cost').val(data.cost_unit).change();

			var old_aa = $('#allocation_amount').val();
			var old_aa2 = $('#amount').val();

			var old_cc = $('#allocation_cost').val();
			var old_cc2 = $('#cost').val();

			var old_ee = $('#allocation_env_impact').val();
			var old_ee2 = $('#env_impact').val();

			$( "#allocation_amount" ).change(function() {
				var oran1=$('#allocation_amount').val()/old_aa;
			  	if ($('#allocation_amount').val() > 100) {
			  		alert("A allocation value > 100% is not possible");
			  		$('#allocation_amount').val(100);
			  	}
			  	else {
			  		$('#amount').val((old_aa2*oran1).toFixed(2));
			  	}
			});

			$( "#amount" ).change(function() {
			  	var oran2=$('#amount').val()/old_aa2;
			  	$('#allocation_amount').val((old_aa*oran2).toFixed(2));
			});

			$( "#allocation_cost" ).change(function() {
			 	if ($('#allocation_cost').val() > 100) {
			  		alert("A allocation value > 100% is not possible");
			  		$('#allocation_cost').val(100);
			  	}
			  	else {
			  		var oran3=$('#allocation_cost').val()/old_cc;
			    	$('#cost').val((old_cc2*oran3).toFixed(2));
			  	}
			});

			$( "#cost" ).change(function() {
			  	var oran4=$('#cost').val()/old_cc2;
			  	$('#allocation_cost').val((old_cc*oran4).toFixed(2));
			});

			$( "#allocation_env_impact" ).change(function() {
				if ($('#allocation_env_impact').val() > 100) {
					alert("A allocation value > 100% is not possible");
					$('#allocation_env_impact').val(100);
				}
			  	else {
			  		var oran5=$('#allocation_env_impact').val()/old_ee;
			  		$('#env_impact').val((old_ee2*oran5).toFixed(2));
			  	}
			});

			$( "#env_impact" ).change(function() {
			  var oran6=$('#env_impact').val()/old_ee2;
			  $('#allocation_env_impact').val((old_ee*oran6).toFixed(2));
			});
		}
	});
});

//prevents the dropdown fields from opening when enter is pressed on a input field and focuses the next text input field
$(".col-md-9>.form-group").keydown(function(e){
    if(e.keyCode == 13) {
        e.preventDefault();
        current_focus = $(this).parent().find("input[type=text]").index($(':focus'));
		$(':focus').parents().eq(2).find("input[type=text]").eq(current_focus+1).focus();
    }
});

var old_aa = $('#allocation_amount').val();
var old_aa2 = $('#amount').val();

var old_cc = $('#allocation_cost').val();
var old_cc2 = $('#cost').val();

var old_ee = $('#allocation_env_impact').val();
var old_ee2 = $('#env_impact').val();

$( "#allocation_amount" ).change(function() {
  	var oran1=$('#allocation_amount').val()/old_aa;
 	//alert("alert"+oran1);
  	if ($('#allocation_amount').val() > 100) {
  		alert("A allocation value > 100% is not possible");
  		$('#allocation_amount').val("100");
  	}
  	else {
  		$('#amount').val((old_aa2*oran1).toFixed(2));
  	}
});

$( "#amount" ).change(function() {
  	var oran2=$('#amount').val()/old_aa2;
  	$('#allocation_amount').val((old_aa*oran2).toFixed(2));
});

$( "#allocation_cost" ).change(function() {
	if ($('#allocation_cost').val() > 100) {
		alert("A allocation value > 100% is not possible");
		$('#allocation_cost').val(100);
	}
	else {
		var oran3=$('#allocation_cost').val()/old_cc;
		$('#cost').val((old_cc2*oran3).toFixed(2));
	}
});

$( "#cost" ).change(function() {
  	var oran4=$('#cost').val()/old_cc2;
  	$('#allocation_cost').val((old_cc*oran4).toFixed(2));
});


$( "#allocation_env_impact" ).change(function() {
	if ($('#allocation_env_impact').val() > 100) {
		alert("A allocation value > 100% is not possible");
		$('#allocation_env_impact').val(100);
	}
  	else {
  		var oran5=$('#allocation_env_impact').val()/old_ee;
  		$('#env_impact').val((old_ee2*oran5).toFixed(2));
	}
});

$( "#env_impact" ).change(function() {
  	var oran6=$('#env_impact').val()/old_ee2;
  	$('#allocation_env_impact').val((old_ee*oran6).toFixed(2));
});
</script>

