<div class="col-md-4 borderli">
	<p class="lead"><?= lang("Validation.addproduct"); ?></p>
	<?= form_open_multipart('new_product/'.$companyID); ?>
	<?= csrf_field() ?>
		<div class="form-group">
				<label for="product"><?= lang("Validation.productname"); ?> <span style="color:red;">*</span></label>
				<input class="form-control" id="product" name="product" placeholder="<?= lang("Validation.productname"); ?>">
		</div>				
		<div class="form-group">
			<div class="row">
					<div class="col-md-8">
						<label for="quantities"><?= lang("Validation.quantities"); ?></label>
						<input class="form-control" id="quantities" name="quantities" placeholder="<?= lang("Validation.quantities"); ?>">
					</div>
					<div class="col-md-4">
						<label for="qunit"><?= lang("Validation.quantitiesunit"); ?></label>
						<select id="qunit" class="info select-block" name="qunit">
							<option value=""><?= lang("Validation.pleaseselect"); ?></option>
							<?php foreach ($units as $unit): ?>
								<option value="<?= $unit['name']; ?>"><?= $unit['name']; ?></option>
							<?php endforeach ?>
						</select>
					</div>
				</div>
			</div>				
		<div class="form-group">
			<div class="row">
				<div class="col-md-8">
					<label for="ucost"><?= lang("Validation.unitcost"); ?></label>
					<input class="form-control" id="ucost" name="ucost" placeholder="<?= lang("Validation.unitcost"); ?>">
				</div>
				<div class="col-md-4">
					<label for="ucostu"><?= lang("Validation.unitcostunit"); ?></label>
					<select id="ucostu" class="info select-block" name="ucostu">
						<option value=""><?= lang("Validation.pleaseselect"); ?></option>
						<option value="TL">TL</option>
						<option value="Euro">Euro</option>
						<option value="Dollar">Dollar</option>
						<option value="CHF">CHF</option>
					</select>
				</div>
			</div>
		</div>
		<div class="form-group">
			<label for="tper"><?= lang("Validation.timeperiod"); ?></label>
			<select id="tper" class="info select-block" name="tper">
				<option value=""><?= lang("Validation.pleaseselect"); ?></option>
				<option value="Daily"><?= lang("Validation.daily"); ?></option>
				<option value="Weekly"><?= lang("Validation.weekly"); ?></option>
				<option value="Monthly"><?= lang("Validation.monthly"); ?></option>
				<option value="Annually"><?= lang("Validation.annually"); ?></option>
			</select>
		</div>
		<button type="submit" class="btn btn-info"><?= lang("Validation.addproduct"); ?></button>
	</form>
	<span class="label label-default"><span style="color:red;">*</span> <?= lang("Validation.labelarereq"); ?>.</span>
</div>
<div class="col-md-8">
	<p class="lead"><?= lang("Validation.companyproducts"); ?></p>
	<table class="table table-striped table-bordered">
		<tr>
			<th><?= lang("Validation.product"); ?></th>
			<th colspan="2" style="text-align: center;"><?= lang("Validation.quantities"); ?></th>
			<th colspan="2" style="text-align: center;"><?= lang("Validation.unitcost"); ?></th>
			<th style="text-align: center;"><?= lang("Validation.timeperiod"); ?></th>
			<th style="width:100px;"><?= lang("Validation.manage"); ?></th>
		</tr>
		<?php foreach ($product as $pro): ?>
		<tr>	
			<td><?= $pro['name']; ?></td>
			<td class="table-numbers"><?php if(empty($pro['quantities']) or $pro['quantities'] == 0){echo "";} else {echo $pro['quantities'].' </td>
				<td class="table-units" style="width: 4%"> '.$pro['qunit']; } ?></td>
			<td class="table-numbers"><?php if(empty($pro['ucost']) or $pro['ucost'] == 0){echo "";} else {echo $pro['ucost'].' </td>
				<td class="table-units" style="width: 4%"> '.$pro['ucostu']; } ?></td>
			<td style="text-align: center;"><?= $pro['tper']; ?></td>
			<td>
			<a href="<?= base_url('edit_product/'.$companyID.'/'.$pro['id']);?>" class="label label-warning"><span class="fa fa-edit"></span> <?= lang("Validation.edit"); ?></button>
			<a href="<?= base_url('delete_product/'.$companyID.'/'.$pro['id']);?>" class="label label-danger"><span class="fa fa-times"></span> <?= lang("Validation.delete"); ?></button></td>
		</tr>
		<?php endforeach ?>
	</table>
</div>
