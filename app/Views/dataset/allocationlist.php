<div class="col-md-12">
<?php 
if(empty($allocationlar)):
 echo "You need to open a project that includes this company to list allocations.";
else:
?>
<p class="lead pull-left"><?= lang("cpheading2"); ?></p>
<div class="pull-right"><a href="<?= base_url('cpscoping/'.$this->session->userdata('project_id').'/'.$companyID.'/allocation'); ?>/" class="btn btn-info" id="cpscopinga"><?= lang("createallocation"); ?></a>
</div>
<table class="table table-striped" style="font-size:13px;">
    <tr>
        <th><?= lang("processname"); ?></th>
        <th><?= lang("flowname"); ?></th>
        <th><?= lang("flowtype"); ?></th>
        <th><?= lang("manage"); ?></th>
    </tr>
<?php foreach ($allocationlar as $a): ?>
    <?php //print_r($flow_prcss[$i][$k]); ?>
    <tr>
        <td><?= $a['prcss_name']; ?></td>
        <td><?= $a['flow_name']; ?></td>
        <td><?= $a['flow_type_name']; ?></td>
        <td>
            <a class="label label-info" href="<?= base_url('cpscoping/edit_allocation/'.$a['allocation_id']); ?>"><?= lang("editallocation"); ?></a>
            <a class="label label-danger" href="<?= base_url('cpscoping/delete/'.$a['allocation_id'].'/'.$a['project_id'].'/'.$a['company_id']); ?>"><?= lang("deleteallocation"); ?></a></td>
    </tr>   
<?php endforeach ?>
</table>
<?php endif ?>
</div>