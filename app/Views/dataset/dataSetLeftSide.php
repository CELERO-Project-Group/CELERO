<?php $project_id = $this->session->userdata('project_id');
	if(empty($project_id)){
		$project_id = 0;
	}
 ?>
<div class="col-md-12">
	<?php if(validation_errors() != NULL ): ?>
	<div class="alert alert-danger">
		<button type="button" class="close" data-dismiss="alert">&times;</button>
		<p>
			<?= validation_errors(); ?>
		</p>
	</div>
	<?php endif ?>
	<div style="margin-bottom:20px; overflow:hidden;">
		<div class="pull-left"><b><a href="<?= base_url('company/'.$company_info['id']); ?>"><?= $company_info['name']; ?></a> <?= lang("Validation.datasetservices"); ?></b></div>
		<div class="pull-right">
		<span class="label label-default"><b><?= lang("Validation.email"); ?>:</b> <?= $company_info['email']; ?></span>
		<span class="label label-default"><b><?= lang("Validation.cellphone"); ?>:</b> <?= $company_info['phone_num_1']; ?></span>
		<span><a href="<?= base_url('company/'.$company_info['id']); ?>" class="label label-primary"><?= lang("Validation.gotocompany"); ?></a></span>
		<span><a href="<?= base_url('datasetexcel'); ?>" class="label label-primary">Add Data From Excel File</a></span>
		</div>
	</div>
	<div>
		<ul class="list-inline ultab">
			<li <?php if ($this->uri->segment(1) == "new_flow"){ echo "class='btn-inverse'"; } ?>><a href="<?= base_url('new_flow/'.$companyID); ?>"><?= lang("Validation.flow"); ?></a></li>
			<li <?php if ($this->uri->segment(1) == "new_component"){ echo "class='btn-inverse'"; } ?>><a class="" href="<?= base_url('new_component/'.$companyID); ?>"><span +><?= lang("Validation.component"); ?></span></a></li>
			<li <?php if ($this->uri->segment(1) == "new_process"){ echo "class='btn-inverse'"; } ?>><a class="" href="<?= base_url('new_process/'.$companyID); ?>"><?= lang("Validation.process"); ?></a></li>
			<li <?php if ($this->uri->segment(1) == "new_product"){ echo "class='btn-inverse'"; } ?>><a class="" href="<?= base_url('new_product/'.$companyID); ?>"><?= lang("Validation.product"); ?></a></li>
			<li <?php if ($this->uri->segment(1) == "allocationlist"){ echo "class='btn-inverse'"; } ?>><a class="" href="<?= base_url('allocationlist/'.$project_id.'/'.$companyID); ?>"><?= lang("Validation.allocation"); ?></a></li>
			<!--link to the equipment page moved to the last position and is ".not-active" atm 
			<li <?php if ($this->uri->segment(1) == "new_equipment"){ echo "class='btn-inverse'"; } ?>><a class="not-active" title="Not available yet"><?= lang("Validation.equipment"); ?></a></li> -->
			</ul>
	</div>
</div>