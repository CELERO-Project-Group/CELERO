<div class="col-md-12">
<?php 
if(empty($allocationlar)):
 echo "You need to open a project that includes this company to list allocations.";
else:
?>
<p class="lead pull-left"><?= lang("Validation.cpheading2"); ?></p>
<div class="pull-right"><a href="<?= base_url('cpscoping/'.session()->project_id.'/'.$companyID.'/allocation'); ?>/" class="btn btn-info" id="cpscopinga"><?= lang("Validation.createallocation"); ?></a>
</div>
<table class="table table-striped" style="font-size:13px;">
	<tr>
		<th><?= lang("Validation.processname"); ?></th>
		<th><?= lang("Validation.flowname"); ?></th>
		<th><?= lang("Validation.flowtype"); ?></th>
		<th><?= lang("Validation.manage"); ?></th>
	</tr>
<?php foreach ($allocationlar as $a): ?>
	<?php //print_r($flow_prcss[$i][$k]); ?>
	<tr>
		<td><?= $a['prcss_name']; ?></td>
		<td><?= $a['flow_name']; ?></td>
		<td><?= $a['flow_type_name']; ?></td>
		<td>
		<a class="label label-info" href="<?= base_url('cpscoping/edit_allocation/'.$a['allocation_id']); ?>"><?= lang("Validation.editallocation"); ?></a>
		<a class="label label-danger" href="<?= base_url('cpscoping/delete/'.$a['allocation_id'].'/'.$a['project_id'].'/'.$a['company_id']); ?>"><?= lang("Validation.deleteallocation"); ?></a></td>
	</tr>   
<?php endforeach ?>
</table>
<?php endif ?>
</div>