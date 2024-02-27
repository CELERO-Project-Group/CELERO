<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
<link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">

<script>
	$(function () {
		$(document).tooltip();
	});
</script>

<div class="row">
	<div class="col-md-12" style="margin-bottom: 10px;">
		<!-- TODO: change the direction of the href (it is not dynamic currently) -->
		<a href="javascript:void(0);" onclick="window.location.href='<?= base_url('new_flow/3419'); ?>' "
			class="btn btn-inverse btn-sm" id="cpscopinga">
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

				<button class="btn btn-info" type="button" data-toggle="modal" data-target="#myModalUpload"
					id="upload-button" style="margin-right:10px;">
					<?= lang("Validation.uploadexcel"); ?>
				</button>

				<a class="btn btn-warning" href="<?= base_url('assets/excels/default.xlsx'); ?>">Download Excel
					Template</a>
			</div>
		</div>
		<div class="col-md-12">
			<?php
			if ($validation != NULL)
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
					<input type="hidden" name="form_id" value="form1">

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
								<select style="width:60px;" id="selectize-units" class="info select-block"
									name="epQuantityUnit">
									<option value="">Select</option>

									<?php foreach ($units as $unit): ?>
										<option value="<?= $unit['id']; ?>" <?= set_select('epQuantityUnit', $unit['id']); ?>>
											<?= $unit['name']; ?>
										</option>
									<?php endforeach ?>
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
			<div id="excel-ubp" style="display: flex; justify-content: space-between;">
			<div style="font-weight:800; font-size:20px;">Excel UBP import</div>
			<a class="btn btn-primary" style="margin-right:10px;" href="<?= base_url('clearlist'); ?>">Clear List</a>
			</div>
			<table class="table table-sm">
				<th>Name</th>
				<th>UBP Value (UBP/x)</th>
				<th>Unit (x)</th>
				<th>Add <i class="fa fa-info-circle"
						title="Click here to save the UBP-Data you want (This will make them appear on the right side)"></i>
				</th>
				<?php foreach ($excelcontents as $ec): ?>
					<?= form_open_multipart('datasetexcel'); ?>
					<?= csrf_field() ?>
					<input type="hidden" name="form_id" value="form2">

					<tr>
						<td>
							<div class="">
								<input class="form-control" id="flowname" name="flowname" title="<?= $ec['flow_name']; ?>"
									value="<?= $ec['flow_name']; ?>" disabled>
								<input class="form-control" id="flowname" name="flowname" title="<?= $ec['flow_name']; ?>"
									value="<?= $ec['flow_name']; ?>" type="hidden">
							</div>
						</td>
						<td>
							<div class="">
								<input class="form-control" style="text-align: right;" id="epvalue" name="epvalue"
									value="<?= number_format($ec['ep_value'], 2, ".", "'"); ?>" disabled>
								<input class="form-control" style="text-align: right;" id="epvalue" name="epvalue"
									value="<?= number_format($ec['ep_value'], 2, ".", "'"); ?>" type="hidden">
							</div>
						</td>
						<td style="width:60px; vertical-align:middle; text-align:center;">
							<div class="">
								<select style="width:60px;" id="selectize-units" class="info select-block"
									name="epQuantityUnit">
									<<option value="<?= $ec['ep_q_unit_id']; ?> <?= set_select('epQuantityUnit', $ec['ep_q_unit_id']); ?>">
										<?= $ec['ep_q_unit']; ?>
									</option>
								</select>
							</div>
						</td>
						<td style="width:70px; vertical-align:center; text-align: center;">
							<button type="submit" class="btn btn-info">Add</button>
						</td>
					</tr>
					</form>
				<?php endforeach ?>
			</table>
		</div>
		<div class="col-md-6">
			<div style="font-weight:800; font-size:20px;">Your saved/imported UBP values</div>
			<table class="table">
				<th>Name</th>
				<th colspan="2">Value (UBP/x)</th>
				<th>Remove</th>
				<?php foreach ($userepvalues as $uep): ?>
					<?php //print_r($ec);     ?>
					<tr>
						<td>
							<?= $uep['flow_name']; ?>
						</td>
						<td class="table-numbers" style="width:120px;">
							<?= number_format($uep['ep_value'], 2, ".", "'"); ?>
						</td>
						<td class="table-units" style="width:60px;">
							UBP/
							<?= $uep['qntty_unit_name']; ?>
						</td>
						<td style="width:60px; vertical-align:center; text-align: center;">
							<a href="<?= base_url('deleteuserep/' . $uep['flow_name'] . '/' . $uep['ep_value']); ?>"
								class="label label-info">Delete</a>
						</td>
					</tr>
				<?php endforeach ?>
			</table>
		</div>
	</div>
</div>

<div class="modal fade" id="myModalUpload" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
	aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="myModalLabel">Import Excel</h4>
				<hr>
				<div style="border: 1px solid #d0d0d0; padding: 15px; margin-bottom: 20px; overflow:hidden;">
					<i>This will replace your whole excel data. Inserted data won't be affected. Only xls and xlsx
						filetype is allowed.</i>
					<div>For CELERO to correctly understand the input, the Excel has to be in the same Form as the
						Template.</div>

					<div style="padding: 20px 0; padding-bottom: 0px;">
						<!-- <?php
						// if(isset($error)) {
						//     echo "<div style=' color:#E74C3C;margin: 10px 0;padding: 15px;padding-bottom: 0;border: 1px solid;'>ERROR:</br>".$error."</div>";
						// }
						// else if (!isset($_FILES['excel_file']) || !$_FILES['excel_file']['error'] === UPLOAD_ERR_OK) {
						//     echo "<div style='margin: 10px 0;padding: 15px;padding-bottom: 20;border: 1px solid;'>No File uploaded yet.</div>";
						//   }
						// else {
						//     echo "<div style=' color:#2eb3e7;margin: 10px 0;padding: 15px;padding-bottom: 20;border: 1px solid;'>DONE:</br>You have successfully uploaded new file.</div>";
						// }
						?> -->
						<?php if (session()->has('message')) { ?>
							<div class="alert <?= session()->getFlashdata('alert-class') ?>">
								<?= session()->getFlashdata('message') ?>
							</div>
						<?php } ?>

					</div>
					<div class="modal-body">
						<?= form_open_multipart('datasetexcel', "style='margin-top: 10px;float: left;'"); ?>
						<?= csrf_field() ?>
						<input type="hidden" name="form_id" value="form3">
						<input type="file" name="excelFile" id="excelFile">
					</div>
					<input type="submit" value="Upload Data" style="float:right;" class="btn btn-info" />
					</form>
				</div>
			</div>
		</div>
	</div>