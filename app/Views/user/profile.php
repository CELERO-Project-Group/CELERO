<div class="container">
	<div class="row">
		<div class="col-md-4">
			
			<div style="margin-top: 10px;">
				<?php  if($userInfo['id']==session()->id): ?>
		  		<a class="btn btn-inverse btn-block" style="margin-bottom: 10px;" href="<?= base_url("profile_update"); ?>"><?= lang("Validation.updateprofile"); ?></a>
		  		<a class="btn btn-inverse btn-block" style="margin-bottom: 10px;" href="<?= base_url('send_email_for_change_pass'); ?>" style="text-transform: capitalize;"><?= lang("Validation.changepassword"); ?></a>
		  	<?php endif ?>
		  	<?php if(($userInfo['role_id']=='2') && session()->id == $userInfo['id']): ?>
		  		<a class="btn btn-success btn-block consultant" title="If you apply for consultant, the administrator has to approve it." data-placement='bottom' href="<?= base_url("become_consultant"); ?>"><?= lang("Validation.becomeconsultant"); ?></a>
		  	<?php endif ?>
		  	<?php if($userInfo['role_id']=="1"): ?>
		  		<div class="btn btn-success btn-block consultant" title="Consultants have full access to all functionalities of the Platform." data-placement='bottom' style="cursor: default;"><?= lang("Validation.thisisconsultant"); ?></div>
		  	<?php endif ?>
		  </div>
		</div>
		<div class="col-md-8">
			<div class="swissheader"><?= $userInfo["name"].' '.$userInfo["surname"]; ?></div>
			<table class="table table-striped table-bordered">
				<tr>
					<td style="width:120px;">
					<?= lang("Validation.description"); ?>
					</td>
					<td>
						<div><?= $userInfo['title']; ?></div>
						<div><?= $userInfo['description']; ?></div>
					</td>
				</tr>
				<tr>
					<td>
					<?= lang("Validation.email"); ?>
					</td>
					<td>
					<?= $userInfo['email']; ?>
					</td>
				</tr>
				<tr>
					<td>
					<?= lang("Validation.cellphone"); ?>
					</td>
					<td>
					<?= $userInfo['phone_num_1']; ?>
					</td>
				</tr>
				<tr>
					<td>
					<?= lang("Validation.workphone"); ?>
					</td>
					<td>
					<?= $userInfo['phone_num_2']; ?>
					</td>
				</tr>
				<tr>
					<td>
					<?= lang("Validation.faxnumber"); ?>
					</td>
					<td>
					<?= $userInfo['fax_num']; ?>
					</td>
				</tr>
			</table>
			<div class="row">
				<div class="col-md-6">
					<?php if($userInfo['role_id']==1): ?>
					<div class="swissheader" style="font-size:15px;"><?= lang("Validation.projectsasconsultant"); ?></div>
					<ul class="nav nav-list">
					<?php foreach ($projectsAsConsultant as $prj): ?>
							<li><a style="text-transform:capitalize;" href="<?= base_url('project/'.$prj["proje_id"]) ?>"><?= $prj["name"] ?></a></li>
					<?php endforeach ?>
					</ul>
					<?php endif ?>
				</div>
				<div class="col-md-6">
					<div class="swissheader" style="font-size:15px;"><?= lang("Validation.projectsasuser"); ?></div>
					<ul class="nav nav-list">
						<?php foreach ($projectsAsWorker as $prj): ?>
						<li><a style="text-transform:capitalize;" href="<?= base_url('project/'.$prj["proje_id"]) ?>"><?= $prj["name"] ?></a></li>
						<?php endforeach ?>
					</ul>
				</div>
			</div>
		</div>

	</div>
</div>

<script>
	$(function() {
		$('.consultant').tooltip();
	});
</script>