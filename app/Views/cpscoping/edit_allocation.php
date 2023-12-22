<script type="text/javascript">
	//already allocated table fill function
	function aatf() {
		//$( "#aprocess" ).text($('#prcss_name').val());
		//$( "#aflow" ).text($('#flow_name').val());
		//$( "#atype" ).text($('#flow_type_name').val());

		//define variables
		var project_id = "<?= session()->project_id; ?>";
		var process_id = "<?= $allocation['prcss_id']; ?>";
		var flow_id = "<?= $allocation['flow_id']; ?>";
		var flow_type_id = "<?= $allocation['flow_type_id']; ?>";
		var cmpny_id = "<?= $allocation['cmpny_id']; ?>";

		//get other allocation data for a selected flow and flow type
		$.ajax({
			type: "POST",
			dataType: 'json',
			url: '<?= base_url('cpscoping/allocated_table'); ?>/' + flow_id + '/' + flow_type_id + '/' + cmpny_id + '/' + process_id + '/' + project_id,
			success: function (data) {
				var vPool = "";
				for (var i = 0; i < data.length; i++) {

					vPool += '<div class="col-md-4"><table style="width:100%;"><tr><td colspan="3" style="height:60px;"><?= lang("Validation.process"); ?>: ' + data[i].prcss_name + '</td></tr><tr><td><?= lang("Validation.amount"); ?></td><td>' + data[i].amount + ' ' + data[i].unit_amount + ' <span class="label label-info">' + data[i].error_amount + '%</span></td><td style="width:70px;"><?= lang("Validation.accuracyrate"); ?>: ' + data[i].allocation_amount + '%</td></tr><tr><td><?= lang("Validation.cost"); ?></td><td>' + data[i].cost + ' ' + data[i].unit_cost + ' <span class="label label-info">' + data[i].error_cost + '%</span></td><td style="width:70px;"><?= lang("Validation.accuracyrate"); ?>: ' + data[i].allocation_cost + '%</td></tr><tr><td><?= lang("Validation.ep"); ?></td><td>' + data[i].env_impact + ' ' + data[i].unit_env_impact + ' <span class="label label-info">' + data[i].error_ep + '%</span></td><td style="width:70px;"><?= lang("Validation.accuracyrate"); ?>: ' + data[i].allocation_env_impact + '%</td></tr></table></div>';
					//alert(data);

				}
				$("#aallocated").html(vPool);
				//console.log(data);
			}
		});
	}
</script>
<?php
if ($validation != NULL)
	echo $validation->listErrors();
?>
<?= form_open_multipart('cpscoping/edit_allocation/' . $allocation['allocation_id']); ?>
<?= csrf_field() ?>

<div>
	<div class="col-md-3">
		<div>
			<?= lang("Validation.allocation"); ?>
		</div>
		<hr>
		<div>
			<?= lang("Validation.process"); ?>:
			<?= $allocation['prcss_name']; ?>
		</div>
		<div>
			<?= lang("Validation.flowname"); ?>:
			<?= $allocation['flow_name']; ?>
		</div>
		<div>
			<?= lang("Validation.flowtype"); ?>:
			<?= $allocation['flow_type_name']; ?>
		</div>
	</div>

	<!-- TODO Adding  Company Flows Table here (same like in creating new allocations -->

	<div class="col-md-9">
		<div>
			<?= lang("Validation.editallocation"); ?>
		</div>
		<hr>
		<div class="form-group clearfix row">
			<div class="col-md-4">
			<label class="control-label tooltip-amo" data-toggle="tooltip">
				<?= lang("Validation.amount"); ?> <i style="color:red;" class="fa fa-question-circle"></i>
			</label>
				<input type="text" class="form-control" value="<?= set_value('amount', $allocation['amount']); ?>"
					id="amount" placeholder="<?= lang("Validation.number"); ?>" name="amount">
			</div>

			<div class="col-md-4">
			<label class="control-label">
				<?= lang("Validation.amountunit"); ?>
			</label>
				<select name="unit_amount" id="unit_amount" class="btn-group select select-block">
					<option value="">
						<?= lang("Validation.pleaseselect"); ?>
					</option>
					<?php foreach ($unit_list as $u): ?>
						<?php $deger = FALSE; ?>
						<?php if ($allocation['unit_amount'] == $u['name']) {
							$deger = TRUE;
						} ?>
						<option value="<?= $u['name']; ?>" <?= set_select('unit_amount', $u['name'], $deger); ?>>
							<?= $u['name']; ?>
						</option>
					<?php endforeach ?>
				</select>
			</div>

			<div class="col-md-4">
			<label class="control-label tooltip-allo" data-toggle="tooltip">
				<?= lang("Validation.allocation"); ?> (%) <i style="color:red;" class="fa fa-question-circle"></i>
			</label>
				<input type="text" class="form-control"
					value="<?= set_value('allocation_amount', $allocation['allocation_amount']); ?>"
					id="allocation_amount" placeholder="<?= lang("Validation.percentage"); ?>" name="allocation_amount">
			</div>
		</div>
		<hr>
		<div class="form-group clearfix row">
			<div class="col-md-4">
			<label class="control-label">
				<?= lang("Validation.cost"); ?>
			</label>
				<input type="text" class="form-control" value="<?= set_value('cost', $allocation['cost']); ?>" id="cost"
					placeholder="<?= lang("Validation.number"); ?>" name="cost">
			</div>
			<div class="col-md-4">
			<label class="control-label">
				<?= lang("Validation.costunit"); ?>
			</label>
				<select name="unit_cost" id="unit_cost" class="btn-group select select-block">
					<option value="">
						<?= lang("Validation.pleaseselect"); ?>
					</option>
					<?php $edeger = FALSE; ?>
					<?php $ddeger = FALSE; ?>
					<?php $tdeger = FALSE; ?>
					<?php $cdeger = FALSE; ?>
					<?php if ($allocation['unit_cost'] == "Euro") {
						$edeger = TRUE;
					} ?>
					<?php if ($allocation['unit_cost'] == "Dollar") {
						$ddeger = TRUE;
					} ?>
					<?php if ($allocation['unit_cost'] == "TL") {
						$tdeger = TRUE;
					} ?>
					<?php if ($allocation['unit_cost'] == "CHF") {
						$cdeger = TRUE;
					} ?>
					<option value="Euro" <?= set_select('unit_cost', 'Euro', $edeger); ?>>Euro</option>
					<option value="Dollar" <?= set_select('unit_cost', 'Dollar', $ddeger); ?>>Dollar</option>
					<option value="TL" <?= set_select('unit_cost', 'TL', $tdeger); ?>>TL</option>
					<option value="CHF" <?= set_select('unit_cost', 'CHF', $cdeger); ?>>CHF</option>
				</select>
			</div>
			<div class="col-md-4">
			<label class="control-label tooltip-allo" data-toggle="tooltip">
				<?= lang("Validation.allocation"); ?> (%) <i style="color:red;" class="fa fa-question-circle"></i>
			</label>
				<input type="text" class="form-control"
					value="<?= set_value('allocation_cost', $allocation['allocation_cost']); ?>" id="allocation_cost"
					placeholder="<?= lang("Validation.percentage"); ?>" name="allocation_cost">
			</div>
		</div>
		<hr>
		<div class="form-group clearfix row">
			<div class="col-md-4">
			<label class="control-label">
				<?= lang("Validation.environmentalimpact"); ?>
			</label>
				<input type="text" class="form-control"
					value="<?= set_value('env_impact', $allocation['env_impact']); ?>" id="env_impact"
					placeholder="<?= lang("Validation.number"); ?>" name="env_impact">
				</div>
				<div class="col-md-4">
			<label class="control-label">EP</label>
				<input class="form-control" id="unit_env_impact" value="EP" name="unit_env_impact" readonly>
			</div>
			<div class="col-md-4">
			<label class="control-label tooltip-allo" data-toggle="tooltip">
				<?= lang("Validation.allocation"); ?> (%) <i style="color:red;" class="fa fa-question-circle"></i>
			</label>
				<input type="text" class="form-control"
					value="<?= set_value('allocation_env_impact', $allocation['allocation_env_impact']); ?>"
					id="allocation_env_impact" placeholder="<?= lang("Validation.percentage"); ?>"
					name="allocation_env_impact">
			</div>
		</div>
		<hr>
		<div class="form-group clearfix row">
			<label class="control-label col-md-3 tooltip-ref" data-toggle="tooltip">
				<?= lang("Validation.reference"); ?> <i style="color:red;" class="fa fa-question-circle"></i>
			</label>
			<label class="control-label col-md-3">
				<?= lang("Validation.unit"); ?>
			</label>
			<label class="control-label col-md-6">
				<?= lang("Validation.nameofref"); ?>
			</label>
			<div class="col-md-3">
				<input type="text" class="form-control" value="<?= set_value('reference', $allocation['reference']); ?>"
					id="reference" placeholder="<?= lang("Validation.number"); ?>" name="reference">
			</div>
			<div class="col-md-3">
				<select name="unit_reference" id="unit_reference" class="btn-group select select-block">
					<option value="">
						<?= lang("Validation.pleaseselect"); ?>
					</option>
					<?php foreach ($unit_list as $u2): ?>
						<?php $deger2 = FALSE; ?>
						<?php if ($allocation['unit_reference'] == $u2['name']) {
							$deger2 = TRUE;
						} ?>
						<option value="<?= $u2['name']; ?>" <?= set_select('unit_reference', $u2['name'], $deger2); ?>>
							<?= $u2['name']; ?>
						</option>
					<?php endforeach ?>
				</select>
			</div>
			<div class="col-md-6">
				<input type="text" class="form-control" value="<?= set_value('nameofref', $allocation['nameofref']); ?>"
					id="nameofref" placeholder="<?= lang("Validation.nameofref"); ?>" name="nameofref">
			</div>
		</div>
		<hr>
		<div class="form-group clearfix row">
			<label class="control-label col-md-3">KPI</label>
			<label class="control-label col-md-3">KPI
				<?= lang("Validation.unit"); ?>
			</label>
			<label class="control-label col-md-6">
				<?= lang("Validation.kpidef"); ?>
			</label>
			<div class="col-md-3">
				<input class="form-control" id="kpi" placeholder="" name="kpi" readonly>
			</div>
			<div class="col-md-3">
				<input class="form-control" id="unit_kpi" placeholder="" name="unit_kpi" readonly>
			</div>
			<div class="col-md-6">
				<input type="text" value="<?= set_value('kpidef', $allocation['kpidef']); ?>" class="form-control"
					id="kpidef" placeholder="<?= lang("Validation.kpidef"); ?>" name="kpidef">
			</div>

		</div>
		<div>
			<button type="submit" class="btn btn-success"><i class="fa fa-floppy-o"></i>
				<?= lang("Validation.savedata"); ?>
			</button>
			<a href="<?= base_url('allocationlist' . '/' . session()->project_id . '/' . $allocation['cmpny_id']); ?>"
				class="btn btn-default" style="float: right;"><i class="fa fa-ban"></i>
				<?= lang("Validation.cancel"); ?>
			</a>
		</div>
		<div style="margin-top:30px;">
			<?= lang("Validation.alloheading5"); ?>
		</div>
		<hr>
		<div id="aallocated" class="row">
			<!-- 				<span id="aprocess"></span>
				<span id="aflow"></span>
				<span id="atype"></span> -->
			<div class="col-md-12">There is no previously recorded allocation of selected flow with flow type.</div>
		</div>
	</div>
</div>
</form>
<script type="text/javascript">
	$("#amount").change(hesapla);
	$("#reference").change(hesapla);
	function hesapla() {
		$("#kpi").val(Number(($("#amount").val() / $("#reference").val()).toFixed(5)));
	}
	$("#unit_amount").change(unit_hesapla);
	$("#unit_reference").change(unit_hesapla);
	function unit_hesapla() {
		$("#unit_kpi").val($("#unit_amount option:selected").text() + "/" + $("#unit_reference option:selected").text());
	}
</script>
<script
	type="text/javascript">	$(document).ready(aatf); $(document).ready(unit_hesapla); $(document).ready(hesapla);</script>
<script type="text/javascript">
	//tooltip accuracy field
	$('.tooltip-acc').tooltip({
		position: 'top',
		content: '<span style="color:#fff"><?= lang("Validation.accuratei"); ?></span>',
		onShow: function () {
			$(this).tooltip('tip').css({
				backgroundColor: '#999',
				borderColor: '#999'
			});
		}
	});
	//tooltip reference field
	$('.tooltip-ref').tooltip({
		position: 'top',
		content: '<span style="color:#fff"><?= lang("Validation.reference-ttip"); ?></span>',
		onShow: function () {
			$(this).tooltip('tip').css({
				backgroundColor: '#999',
				borderColor: '#999'
			});
		}
	});
	//tooltip amount field
	$('.tooltip-amo').tooltip({
		position: 'top',
		content: '<span style="color:#fff"><?= lang("Validation.amount-ttip"); ?></span>',
		onShow: function () {
			$(this).tooltip('tip').css({
				backgroundColor: '#999',
				borderColor: '#999'
			});
		}
	});
	//tooltip allocation field
	$('.tooltip-allo').tooltip({
		position: 'top',
		content: '<span style="color:#fff"><?= lang("Validation.allocation-ttip"); ?></span>',
		onShow: function () {
			$(this).tooltip('tip').css({
				backgroundColor: '#999',
				borderColor: '#999'
			});
		}
	});
</script>


<script type="text/javascript">
	$(document).ready(function (b) {
		var cmpny_id = "<?= $allocation['cmpny_id']; ?>";

		var prcss_name = "<?= $allocation['prcss_id']; ?>";
		var flow_type_name = "<?= $allocation['flow_type_id']; ?>";
		var flow_name = "<?= $allocation['flow_id']; ?>";

		//get other allocation data for a selected flow and flow type
		$.ajax({
			type: "POST",
			dataType: 'json',
			url: '<?= base_url('cpscoping/full_get'); ?>/' + flow_name + '/' + flow_type_name + '/' + cmpny_id + '/' + prcss_name,
			success: function (data) {
				var old_aa = $('#allocation_amount').val();
				var old_aa2 = $('#amount').val();

				var old_cc = $('#allocation_cost').val();
				var old_cc2 = $('#cost').val();

				var old_ee = $('#allocation_env_impact').val();
				var old_ee2 = $('#env_impact').val();

				$("#allocation_amount").change(function () {
					var oran1 = $('#allocation_amount').val() / old_aa;
					if ($('#allocation_amount').val() > 100) {
						alert("A allocation value > 100% is not possible");
						$('#allocation_amount').val(100);
					}
					else {
						$('#amount').val((old_aa2 * oran1).toFixed(2));
					}
				});

				$("#amount").change(function () {
					var oran2 = $('#amount').val() / old_aa2;
					$('#allocation_amount').val((old_aa * oran2).toFixed(2));
				});

				$("#allocation_cost").change(function () {
					if ($('#allocation_cost').val() > 100) {
						alert("A allocation value > 100% is not possible");
						$('#allocation_cost').val(100);
					}
					else {
						var oran3 = $('#allocation_cost').val() / old_cc;
						$('#cost').val((old_cc2 * oran3).toFixed(2));
					}
				});

				$("#cost").change(function () {
					var oran4 = $('#cost').val() / old_cc2;
					$('#allocation_cost').val((old_cc * oran4).toFixed(2));
				});

				$("#allocation_env_impact").change(function () {
					if ($('#allocation_env_impact').val() > 100) {
						alert("A allocation value > 100% is not possible");
						$('#allocation_env_impact').val(100);
					}
					else {
						var oran5 = $('#allocation_env_impact').val() / old_ee;
						$('#env_impact').val((old_ee2 * oran5).toFixed(2));
					}
				});

				$("#env_impact").change(function () {
					var oran6 = $('#env_impact').val() / old_ee2;
					$('#allocation_env_impact').val((old_ee * oran6).toFixed(2));
				});
			}
		});
	});

	//prevents the dropdown field from opening when enter is pressed on a input field and focuses the next text input field
	$(".col-md-9>.form-group").keydown(function (e) {
		if (e.keyCode == 13) {
			e.preventDefault();
			current_focus = $(this).parent().find("input[type=text]").index($(':focus'));
			$(':focus').parents().eq(2).find("input[type=text]").eq(current_focus + 1).focus();
		}
	});
</script>