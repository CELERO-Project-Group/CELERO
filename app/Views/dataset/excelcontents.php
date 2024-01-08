<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
<link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">

<script>
	$( function() {
		$( document ).tooltip();
	} );
</script>

<div class="row">
		<div class="col-md-12" style="margin-bottom: 10px;">
		<!-- TODO: change the direction of the href (it is not dynamic currently) -->
			<a href="javascript:void(0);" onclick="window.location.href='<?= base_url('new_flow/3419');?>' " class="btn btn-inverse btn-sm" id="cpscopinga">
				<?= lang("Validation.goback"); ?>
			</a>
		</div>
	</div>

<div style="padding:20px;padding-top:0px;">
	<div class="row">
		<div class="col-md-12" style="margin-bottom:30px; background-color:#f0f0f0; padding:20px;">
			<div style="font-weight:800; font-size:20px; margin-right:20px;" class="pull-left">Upload/Update Excel
				<i class="fa fa-info-circle" title="You can upload your own UBP-Data:
				First download the Template, then fill in your data and click on upload excel."></i>
			</div>
			<div class="pull-left">
				<a class="btn btn-info" href="<?= site_url('uploadExcel') ?>" style="margin-right:10px;">Upload Excel</a>
				<a class="btn btn-warning" href="<?= base_url('assets/excels/default.xlsx'); ?>">Download Excel Template</a>
			</div>
		</div>
		<div class="col-md-12">
			<?php
				if($validation != NULL)
				echo $validation->listErrors();
			?>
		</div>
		<div class="col-md-6">
			<div>
				<div style="font-weight:800; font-size:20px;">Manual UBP value import</div>
				<table class="table table-sm">
					<th>Name</th>
					<th>EP Value (UBP/x) <i class="fa fa-info-circle" title="Megapoints UBP oder"></i></th>
					<th>Unit (x)</th>
					<th>save</th>
					<?= form_open_multipart('datasetexcel'); ?>
						<?= csrf_field() ?>
						<tr>
							<td>
							<div class="">
								<input class="form-control" id="flowname" name="flowname">
								</div>
							</td>
							<td>
								<div class="">
									<input class="form-control" id="epvalue" name="epvalue" style="text-align: right;">
								</div>
							</td>
							<td style="width:60px; vertical-align:middle; text-align: center;">
								<div class="">
									<select style="width:60px;" id="selectize-units" class="info select-block" name="epQuantityUnit">
										<option value="">Select</option>

										<?php foreach ($units as $unit): ?>
											<option value="<?= $unit['id']; ?>" <?= set_select('epQuantityUnit', $unit['id']); ?>><?= $unit['name']; ?></option>
										<?php endforeach?>
									</select>


								</div>
							</td>
							<td style="width:70px; vertical-align:center; text-align: center;">
								<button type="submit" class="btn btn-info">Add</button>
							</td>
						</tr>
					</form>
				</table>   
			</div>
			<div style="font-weight:800; font-size:20px;">Excel UBP import</div>
				<table class="table table-sm">
					<th>Name</th>
					<th>EP Value (UBP/x)</th>
					<th>Unit (x)</th>
					<th>Add <i class="fa fa-info-circle" title="Click here to save the UBP-Data you want (This will make them appear on the right side)"></i></th>
					<?php foreach ($excelcontents as $ec): ?>
						<?= form_open_multipart('datasetexcel'); ?>
							<tr>
							<td>
								<div class="">
									<input class="form-control" id="flowname" name="flowname" title="<?= $ec[0]; ?>"
									value="<?= $ec[0]; ?>" disabled>
									<input class="form-control" id="flowname" name="flowname" title="<?= $ec[0]; ?>"
									value="<?= $ec[0]; ?>" type="hidden">
									</div>
								</td>
								<td>
									<div class="">
										<input class="form-control" style="text-align: right;" id="epvalue" name="epvalue" value="<?= number_format($ec[1], 2, ".", "'"); ?>" disabled>
										<input class="form-control" style="text-align: right;" id="epvalue" name="epvalue" value="<?= number_format($ec[1], 2, ".", "'"); ?>" type="hidden">
									</div>
								</td>
								<td style="width:60px; vertical-align:middle; text-align:center;">
									<div class="">
										<select style="width:60px;" id="selectize-units" class="info select-block" name="epQuantityUnit" disabled>
											<option value="<?= $ec[3]; ?>" ><?= $ec[2]; ?></option>

											<?php foreach ($units as $unit): ?>
												<option value="<?= $unit['id']; ?>" <?= set_select('epQuantityUnit', $unit['id']); ?>><?= $unit['name']; ?></option>
											<?php endforeach?>
										</select>
										<select style="width:120px;display:none;" id="selectize-units" class="info select-block" name="epQuantityUnit">
											<option value="<?= $ec[3]; ?>" ><?= $ec[2]; ?></option>
										</select>
									</div>
								</td>
								<td style="width:70px; vertical-align:center; text-align: center;">
									<button type="submit" class="btn btn-info">Add</button>
								</td>
							</tr>
						</form>
					<?php endforeach?>
				</table>
			</div>
		<div class="col-md-6">
			<div style="font-weight:800; font-size:20px;">Your saved/imported UBP values</div>
			<table class="table">
				<th>Name</th>
				<th colspan="2">Value  (UBP/x)</th>
				<th>Remove</th>
				<?php foreach ($userepvalues as $uep): ?>
					<?php //print_r($ec); ?>
					<tr>
						<td>
							<?= $uep['flow_name']; ?>
						</td>
						<td class="table-numbers" style="width:120px;">
							<?= number_format($uep['ep_value'], 2, ".", "'"); ?>
						</td>
						<td class="table-units" style="width:60px;">
							UBP/<?= $uep['qntty_unit_name']; ?>
						</td>
						<td style="width:60px; vertical-align:center; text-align: center;">
							<a href="<?= base_url('deleteuserep/' . $uep['flow_name'] . '/' . $uep['ep_value']); ?>" class="label label-info">Delete</a>
						</td>
					</tr>
				<?php endforeach?>
			</table>
		</div>
	</div>
</div>