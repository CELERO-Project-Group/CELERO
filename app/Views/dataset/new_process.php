<!-- <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
<link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">

<script>
	$(function () {
		$(document).tooltip();
	});
</script>

<script type="text/javascript">
	function getProcessId() {
		var id = $('.selectize-input .item').html();
		var isnum = /^\d+$/.test(id);
		if (isnum) {
			alert("You can't enter only numerical characters as a flow name!");
			$("select[id=selectize] option").remove();
		}
		var newid = $('select[name=process]').val();
		var newisnum = /^\d+$/.test(newid);
		if (!newisnum && newid != "") {
			$('#process-family').show("slow");
		}
	}
</script> -->
<div class="row">
	<div class="col-md-3 borderli">
		<?= form_open_multipart('new_process/' . $companyID); ?>
		<?= csrf_field() ?>
		<p class="lead">
			<?= lang("Validation.addprocess"); ?>
		</p>
		<!-- <div class="form-group">
			<label for="status">
				<?= lang("Validation.processname"); ?> <span style="color:red;">*</span>
			</label>
			<i class="fa fa-info-circle" title="One process can contain multiple flows and one
			flow can go through multiple processes."></i>
			<select id="processname" onchange="getProcessId()" name="process">
				<option value="">
					<?= lang("Validation.pleaseselect"); ?>
				</option>
				<?php
				// Sort the $flowlist array alphabetically based on the 'name' key
				usort($process, function ($a, $b) {
					return strcmp($a['name'], $b['name']);
				});
				?>
				<?php foreach ($process as $pro): ?>
					<option value="<?= $pro['id']; ?>">
						<?= $pro['name']; ?>
					</option>
				<?php endforeach ?>
			</select>
		</div>
		<div class="form-group" id="process-family" style="display:none;">
			<label for="processfamily">
				<?= lang("Validation.processfamily"); ?> <span style="color:red;">*</span>
			</label>
			<select id="processfamily" class="info select-block" name="processfamily">
				<?php foreach ($processfamilys as $processfamily): ?>
					<option value="<?= $processfamily['id']; ?>">
						<?= $processfamily['name']; ?>
					</option>
				<?php endforeach ?>
			</select>
		</div>
		<div class="form-group">
			<label for="description">
				<?= lang("Validation.usedflows"); ?> <span style="color:red;">*</span>
			</label>
			<select class="select-block" id="usedFlows" name="usedFlows">
				<?php foreach ($company_flows as $flow): ?>
					<option value="<?= $flow['cmpny_flow_id']; ?>">
						<?= $flow['flowname'] . '(' . $flow['flowtype'] . ')'; ?>
					</option>
				<?php endforeach ?>
			</select>
		</div>
		<div class="form-group">
			<label for="comment">
				<?= lang("Validation.comments"); ?>
			</label>
			<textarea class="form-control" id="comment" name="comment"
				placeholder="<?= lang("Validation.comments"); ?>"></textarea>
		</div> -->
		<!-- <button type="submit" class="btn btn-info">
		<?= lang("Validation.addprocess"); ?>
		</button> -->
		<button type="button" data-toggle="modal" data-target="#myModalProcess" class="btn btn-block btn-primary"
			id="processcode-button">
			<?= lang("Validation.addprocess"); ?>
		</button>
		</form>
	</div>
	<div class="col-md-9">
		<p class="lead">
			<?= lang("Validation.companyprocess"); ?>
		</p>
		<table class="table table-bordered">
			<tr>
				<th>
					<?= lang("Validation.processname"); ?>
				</th>
				<th>
					<?= lang("Validation.usedflows"); ?>
				</th>
				<th>
					<?= lang("Validation.comments"); ?>
				</th>
				<th>
					<?= lang("Validation.manage"); ?>
				</th>
			</tr>
			<?php $son = ""; ?>
			<?php foreach ($cmpny_flow_prcss as $key => $attribute): ?>
				<tr>
					<?php if ($son !== $attribute['prcessname']): ?>
						<td rowspan="<?= $cmpny_flow_prcss_count[$attribute['prcessname']]; ?>">
							<?= $attribute['prcessname']; ?>
						</td>
					<?php endif ?>
					<td>
						<?= $attribute['flowname'] . '(' . $attribute['flow_type_name'] . ')'; ?>
						<a href="<?= base_url('delete_process/' . $companyID . '/' . $attribute['company_process_id'] . '/' . $attribute['company_flow_id']); ?>"
							style="float: right;" class="label label-danger" value="<?= $attribute['prcessid']; ?>"><span
								class="fa fa-times"></span>
							<?= lang("Validation.delete"); ?>
					</td>
					<?php if ($son !== $attribute['prcessname']): ?>
						<td rowspan="<?= $cmpny_flow_prcss_count[$attribute['prcessname']]; ?>">
							<?= $attribute['comment']; ?>
						</td>
						<td rowspan="<?= $cmpny_flow_prcss_count[$attribute['prcessname']]; ?>">
							<a href="<?= base_url('edit_process/' . $companyID . '/' . $attribute['company_process_id']); ?>"
								class="label label-warning" value="<?= $attribute['prcessid']; ?>"><span
									class="fa fa-edit"></span>
								<?= lang("Validation.edit"); ?>
						</td>
					<?php endif ?>
				</tr>
				<?php $son = $attribute['prcessname']; ?>
			<?php endforeach ?>
		</table>
	</div>
</div>

<div class="modal fade" id="myModalProcess" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
	aria-hidden="true">
	<div class="modal-dialog-process">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="myModalLabel">
					<?= lang("Validation.selectlevelprocess"); ?>
				</h4>
				<hr>
				<div class="row">
					<div class="col-md-12">
						<input type="text" class="form-control" id="processCode" name="process-code"
							style="color:#333333;" readonly />
					</div>
				</div>
			</div>
			<div class="modal-body">
				<!-- Miller column process selector -->
				<div id="miller_col"></div>
				<br>
				<button type="button" data-dismiss="modal" class="btn btn-info btn-block" aria-hidden="true">
					<?= lang("Validation.done"); ?>
				</button>
			</div>
			<div class="modal-footer"></div>
		</div>
	</div>
</div>


<script type="text/javascript">

	miller_column_process();

	//js function for miller-coloumn process-code selector
	$(document).ready(function () {
		$("[rel=tooltip]").tooltip({ placement: 'right' });
	});


</script>