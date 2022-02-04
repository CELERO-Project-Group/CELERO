<div class="container">
	<div class="row">
		<div class="col-md-4">
			<?php if(file_exists("assets/user_pictures/".$userInfo['photo'])): ?>
					<img class="img-responsive thumbnail" style="width: 100%" src="<?= asset_url("user_pictures/".$userInfo['photo']); ?>">
				<?php else: ?>
					<img class="img-responsive thumbnail" style="width: 100%" src="<?= asset_url("user_pictures/default.jpg"); ?>">
			<?php endif ?>
			<div style="margin-top: 10px;">
				<?php  if($userInfo['id']==$this->session->userdata('user_in')['id']): ?>
		  	<a class="btn btn-inverse btn-block" style="margin-bottom: 10px;" href="<?= base_url("profile_update"); ?>"><?= lang("updateprofile"); ?></a>
		  	<a class="btn btn-inverse btn-block" style="margin-bottom: 10px;" href="<?= base_url('send_email_for_change_pass'); ?>" style="text-transform: capitalize;"><?= lang("changepassword"); ?></a>
		  	<?php endif ?>
		  	<?php if(($userInfo['role_id']=='2') && $this->session->userdata('user_in')['id'] == $userInfo['id']): ?>
		  		<a class="btn btn-success btn-block consultant" title="If you apply for consultant, the administrator has to approve it." data-placement='bottom' href="<?= base_url("become_consultant"); ?>"><?= lang("becomeconsultant"); ?></a>
		  	<?php endif ?>
		  	<?php if($userInfo['role_id']=="1"): ?>
		  		<div class="btn btn-success btn-block consultant" title="Consultants have full access to all functionalities of the Platform." data-placement='bottom' style="cursor: default;"><?= lang("thisisconsultant"); ?></div>
		  	<?php endif ?>
		  </div>
		</div>
		<div class="col-md-8">
			<div class="swissheader"><?= $userInfo["name"].' '.$userInfo["surname"]; ?></div>
			<table class="table table-striped table-bordered">
				<tr>
					<td style="width:120px;">
					<?= lang("description"); ?>
					</td>
					<td>
						<div><?= $userInfo['title']; ?></div>
						<div><?= $userInfo['description']; ?></div>
					</td>
				</tr>
				<tr>
					<td>
					<?= lang("email"); ?>
					</td>
					<td>
					<?= $userInfo['email']; ?>
					</td>
				</tr>
				<tr>
					<td>
					<?= lang("cellphone"); ?>
					</td>
					<td>
					<?= $userInfo['phone_num_1']; ?>
					</td>
				</tr>
				<tr>
					<td>
					<?= lang("workphone"); ?>
					</td>
					<td>
					<?= $userInfo['phone_num_2']; ?>
					</td>
				</tr>
				<tr>
					<td>
					<?= lang("faxnumber"); ?>
					</td>
					<td>
					<?= $userInfo['fax_num']; ?>
					</td>
				</tr>
			</table>
			<div class="row">
				<div class="col-md-6">
					<?php if($userInfo['role_id']==1): ?>
					<div class="swissheader" style="font-size:15px;"><?= lang("projectsasconsultant"); ?></div>
					<ul class="nav nav-list">
					<?php foreach ($projectsAsConsultant as $prj): ?>
							<li><a style="text-transform:capitalize;" href="<?= base_url('project/'.$prj["proje_id"]) ?>"><?= $prj["name"] ?></a></li>
					<?php endforeach ?>
					</ul>
					<?php endif ?>
				</div>
				<div class="col-md-6">
					<div class="swissheader" style="font-size:15px;"><?= lang("projectsasuser"); ?></div>
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