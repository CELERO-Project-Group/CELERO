<?php
	$project_id = session()->project_id;
	if(empty($project_id)){
		$project_id = 0;
	}
	$uri = service('uri');

 ?>
<div class="row">
		<div class="col-md-12" style="margin-bottom: 10px;">
		<?php if (isset(session()->project_id)): ?>
			<a href="<?= base_url('cpscoping'); ?>/" class="btn btn-inverse btn-sm" id="cpscopinga">
				<?= lang("Validation.gotocpscoping"); ?>
			</a>
		<?php endif; ?>
			<a href="<?= base_url('company/'.$company_info['id']); ?>/" class="btn btn-inverse btn-sm" id="cpscopinga">
				<?= lang("Validation.gotocompany"); ?>
			</a>
		</div>
	</div>
 <div class="row">
<div class="col-md-12">
	<?php
		if($validation != NULL)
		echo $validation->listErrors();
	?>
	<div style="margin-bottom:20px; overflow:hidden;">
		<div class="pull-left"><b><a href="<?= base_url('company/'.$company_info['id']); ?>"><?= $company_info['name']; ?></a> <?= lang("Validation.datasetservices"); ?></b></div>
		<div class="pull-right">
		<span class="label label-default"><b><?= lang("Validation.email"); ?>:</b> <?= $company_info['email']; ?></span>
		<span class="label label-default"><b><?= lang("Validation.cellphone"); ?>:</b> <?= $company_info['phone_num_1']; ?></span>
		</div>
	</div>
	<div>
		<ul class="list-inline ultab">
			<li <?php if ($uri->getSegment(1) == "new_flow"){ echo "class='btn-inverse'"; } ?>><a href="<?= base_url('new_flow/'.$companyID); ?>"><?= lang("Validation.flow"); ?></a></li>
			<!-- Component is not longer needed TODO: still need to clean up the code related to this)-->
			<!-- <li <?php if ($uri->getSegment(1) == "new_component"){ echo "class='btn-inverse'"; } ?>><a class="" href="<?= base_url('new_component/'.$companyID); ?>"><span +><?= lang("Validation.component"); ?></span></a></li> -->
			<li <?php if ($uri->getSegment(1) == "new_process"){ echo "class='btn-inverse'"; } ?>><a class="" href="<?= base_url('new_process/'.$companyID); ?>"><?= lang("Validation.process"); ?></a></li>
			<li <?php if ($uri->getSegment(1) == "new_product"){ echo "class='btn-inverse'"; } ?>><a class="" href="<?= base_url('new_product/'.$companyID); ?>"><?= lang("Validation.product"); ?></a></li>
			<li <?php if ($uri->getSegment(1) == "allocationlist"){ echo "class='btn-inverse'"; } ?>><a class="" href="<?= base_url('allocationlist/'.$project_id.'/'.$companyID); ?>"><?= lang("Validation.allocation"); ?></a></li>
			<!--link to the equipment page moved to the last position and is ".not-active" atm 
			<li <?php if ($uri->getSegment(1) == "new_equipment"){ echo "class='btn-inverse'"; } ?>><a class="not-active" title="Not available yet"><?= lang("Validation.equipment"); ?></a></li> -->
			</ul>
	</div>
</div>
</div>