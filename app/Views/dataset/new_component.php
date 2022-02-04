	<div class="col-md-4 borderli">
		<?= form_open_multipart('new_component/'.$companyID); ?>
			<p class="lead"><?= lang("addcomponent"); ?></p>
			<div class="form-group">
			    <label for="component_name"><?= lang("componentname"); ?> <span style="color:red;">*</span></label>
			   	<input class="form-control" id="component_name" name="component_name" placeholder="<?= lang("componentname"); ?>">
		 	</div>

			<div class="form-group">
				<label for="component_name"><?= lang("connectedflow"); ?> <span style="color:red;">*</span></label>
				<select id="flowtype" class="info select-block" name="flowtype">
					<?php foreach ($flow_and_flow_type as $flows): ?>
					<option value="<?= $flows['value_id']; ?>"><?= $flows['flow_name'].'('.$flows['flow_type_name'].')'; ?></option>
					<?php endforeach ?>
				</select>
			</div>

		 	<div class="form-group">
			  <label for="component_type"><?= lang("componenttype"); ?></label>
				<select id="component_type" class="info select-block" name="component_type">
					<option value="0"><?= lang("pleaseselect"); ?></option>
					<?php foreach ($ctypes as $ctype): ?>
						<option value="<?= $ctype['id']; ?>"><?= $ctype['name']; ?></option>
					<?php endforeach ?>
				</select>
		 	</div>

			<div class="form-group">
				<label for="description"><?= lang("description"); ?></label>
				<input class="form-control" id="description" name="description" placeholder="<?= lang("description"); ?>">
			</div>

			<div class="form-group">
				<div class="row">
					<div class="col-md-8">
						<label for="quantity"><?= lang("quantity"); ?> (<?= lang("annual"); ?>)</label>
						<input class="form-control" id="quantity" name="quantity" placeholder="<?= lang("quantity"); ?>">
					</div>
					<div class="col-md-4">
						<label for="quantity"><?= lang("quantityunit"); ?></label>
		                <select id="selectize-units" class="info select-block" name="quantityUnit"> 
		                    <option value="" disabled selected><?= lang("pleaseselect"); ?></option>
		                    <?php foreach ($units as $unit): ?>
		                        <option value="<?= $unit['id']; ?>" <?= set_select('quantityUnit', $unit['id']); ?>><?= $unit['name']; ?></option>
		                    <?php endforeach ?>
		                </select>
					</div>
				</div>
			</div>
			<div class="form-group">
				<div class="row">
					<div class="col-md-8">
						<label for="cost"><?= lang("supplycost"); ?> (<?= lang("annual"); ?>)</label>
						<input class="form-control" id="cost" name="cost" placeholder="<?= lang("supplycost"); ?>">
					</div>
					<div class="col-md-4">
						<label for="cost"><?= lang("supplycostunit"); ?></label>
						<select id="costUnit" class="info select-block" name="costUnit">
							<option value="CHF">CHF</option>
							<option value="Euro">Euro</option>
							<option value="Dollar">Dollar</option>
							<option value="TL">TL</option>
						</select>
					</div>
				</div>
			</div>

			<div class="form-group">
				<div class="row">
					<div class="col-md-8">
						<label for="ocost"><?= lang("outputcost"); ?> (<?= lang("annual"); ?>)</label>
						<input class="form-control" id="ocost" name="ocost" placeholder="<?= lang("outputcost"); ?>">
					</div>
					<div class="col-md-4">
						<label for="ocostunit"><?= lang("outputcostunit"); ?></label>
						<select id="ocostunit" class="info select-block" name="ocostunit">
							<option value="CHF">CHF</option>
							<option value="Euro">Euro</option>
							<option value="Dollar">Dollar</option>
							<option value="TL">TL</option>
						</select>
					</div>
				</div>
			</div>

			<div class="form-group">
				<label for="quality"><?= lang("quality"); ?></label>
				<input class="form-control" id="quality" name="quality" placeholder="<?= lang("quality"); ?>">
			</div>

			<div class="form-group">
				<label for="spot"><?= lang("substitute_potential"); ?></label>
				<input class="form-control" id="spot" name="spot" placeholder="<?= lang("substitute_potential"); ?>">
			</div>
		  
		  <div class="form-group">
				<label for="comment"><?= lang("comments"); ?></label>
				<input class="form-control" id="comment" name="comment" placeholder="<?= lang("comments"); ?>">
			</div>
		  
		  <button type="submit" class="btn btn-info"><?= lang("addcomponent"); ?></button>
		</form>
		<span class="label label-default"><span style="color:red;">*</span> <?= lang("labelarereq"); ?>.</span>

		</div>
		<div class="col-md-8">
		<p class="lead"><?= lang("companycomponents"); ?></p>
		<table class="table table-striped table-bordered">
			<tr>
				<th><?= lang("flowname"); ?></th>
				<th><?= lang("componentname"); ?></th>
				<th><?= lang("componenttype"); ?></th>
				<th><?= lang("description"); ?></th>
				<th colspan="2"><?= lang("quantity"); ?></th>
				<th colspan="2"><?= lang("supplycost"); ?></th>
				<th colspan="2"><?= lang("outputcost"); ?></th>
				<th><?= lang("quality"); ?></th>
				<th><?= lang("substitute_potential"); ?></th>
				<th><?= lang("comments"); ?></th>
				<th style="width:100px;"><?= lang("manage"); ?></th>
			</tr>
			<?php foreach ($component_name as $component): ?>
				<tr>
					<td><?= $component['flow_name']; ?> (<?= $component['flow_type_name']; ?>)</td>
					<td><?= $component['component_name']; ?></td>
					<td><?= $component['type_name']; ?></td>
					<td><?= $component['description']; ?></td>
					<td class="table-numbers"><?= $component['qntty']; ?> </td>
					<td class="table-units"><?= $component['qntty_name']; ?></td>
					<td class="table-numbers"><?= $component['supply_cost']; ?> </td>
					<td class="table-units"><?= $component['supply_cost_unit']; ?></td>
					<td class="table-numbers"><?= $component['output_cost']; ?> </td>
					<td><?= $component['output_cost_unit']; ?></td>
					<td><?= $component['data_quality']; ?></td>
					<td><?= $component['substitute_potential']; ?></td>
					<td><?= $component['comment']; ?></td>
					<td>
						<a href="<?= base_url('edit_component/'.$companyID.'/'.$component['id']);?>" class="label label-warning" value="<?= $component['id']; ?>"><span class="fa fa-edit"></span> <?= lang("edit"); ?></a>
						<a href="<?= base_url('delete_component/'.$companyID.'/'.$component['id']);?>" class="label label-danger" value="<?= $component['id']; ?>"><span class="fa fa-times"></span> <?= lang("delete"); ?></a>
					</td>
			
				</tr>
			<?php endforeach ?>
		</table>
		</div>

<script type="text/javascript">
    $('#selectize-units').selectize({
        create: false
    });
</script>