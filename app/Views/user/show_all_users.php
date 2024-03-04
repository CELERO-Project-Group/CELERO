<?php //print_r($users); ?>
<div class="container">
	<div class="row">
		<div class="col-md-8">
				<div class="swissheader"><?= lang("Validation.consultants"); ?></div>
				<table class="table-hover" style="clear:both; width: 100%;">
				<?php foreach ($consultant as $com): ?>
					<tr>
					<td style="padding: 10px 15px;">
						<a href="<?= base_url('user/'.$com['user_name']) ?>" style="display:block;">
							<div><b><?= $com['name']; ?> <?= $com['surname']; ?></b>
							<small style="color:gray;">- @<?= $com['user_name']; ?></small></div>
						<div><span style="color:#999999; font-size:12px;"><?= $com['description']; ?></span></div>
						</a>
					</td>
					</tr>
				<?php endforeach ?>
				</table>

				<div class="swissheader"><?= lang("Validation.visitors"); ?></div>
				<table class="table-hover" style="clear:both; width: 100%;">
				<?php foreach ($visitors as $com): ?>
					<tr>
					<td style="padding: 10px 15px;">
						<a href="<?= base_url('user/'.$com['user_name']) ?>" style="display:block;">
							<div><b><?= $com['name']; ?> <?= $com['surname']; ?></b>
							<small style="color:gray;">- @<?= $com['user_name']; ?></small></div>
						<div><span style="color:#999999; font-size:12px;"><?= $com['description']; ?></span></div>
						</a>
					</td>
					</tr>
				<?php endforeach ?>
				</table>
				<div class="swissheader"><?= lang("Validation.departmentworker"); ?></div>
				<table class="table-hover" style="clear:both; width: 100%;">
				<?php foreach ($departmentworker as $com): ?>
					<tr>
					<td style="padding: 10px 15px;">
						<a href="<?= base_url('user/'.$com['user_name']) ?>" style="display:block;">
							<div><b><?= $com['name']; ?> <?= $com['surname']; ?></b>
							<small style="color:gray;">- @<?= $com['user_name']; ?></small></div>
						<div><span style="color:#999999; font-size:12px;"><?= $com['description']; ?></span></div>
						</a>
					</td>
					</tr>
				<?php endforeach ?>
				</table>
				<div class="swissheader"><?= lang("Validation.departmentmanager"); ?></div>
				<table class="table-hover" style="clear:both; width: 100%;">
				<?php foreach ($departmentmanager as $com): ?>
					<tr>
					<td style="padding: 10px 15px;">
						<a href="<?= base_url('user/'.$com['user_name']) ?>" style="display:block;">
							<div><b><?= $com['name']; ?> <?= $com['surname']; ?></b>
							<small style="color:gray;">- @<?= $com['user_name']; ?></small></div>
						<div><span style="color:#999999; font-size:12px;"><?= $com['description']; ?></span></div>
						</a>
					</td>
					</tr>
				<?php endforeach ?>
				</table>
				<div class="swissheader"><?= lang("Validation.admin"); ?></div>
				<table class="table-hover" style="clear:both; width: 100%;">
				<?php foreach ($admin as $com): ?>
					<tr>
					<td style="padding: 10px 15px;">
						<a href="<?= base_url('user/'.$com['user_name']) ?>" style="display:block;">
							<div><b><?= $com['name']; ?> <?= $com['surname']; ?></b>
							<small style="color:gray;">- @<?= $com['user_name']; ?></small></div>
						<div><span style="color:#999999; font-size:12px;"><?= $com['description']; ?></span></div>
						</a>
					</td>
					</tr>
				<?php endforeach ?>
				</table>

		</div>
		<!-- <div class="col-md-4">
			<div class="well">
				<?= lang("Validation.consultantsdesc"); ?>
			</div>
		</div> -->
	</div>
</div>
