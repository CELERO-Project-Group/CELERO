<div class="container">
	<div class="row">
		<div class="col-md-12 ">
			<?php if(!empty($companies)): ?>
				<p class="lead">Companies</p>
			<?php foreach ($companies as $c): ?>
				<div><a href="<?= base_url('company/'.$c['id']); ?>"><?= $c['name']; ?></a></div>
				<div><?= $c['description']; ?></div>
				<hr>
			<?php endforeach ?>
			<?php endif ?>
			<?php if(!empty($projects)): ?>
			<p class="lead">Projects</p>
			<?php foreach ($projects as $p): ?>
				<div><a href="<?= base_url('project/'.$p['id']); ?>"><?= $p['name']; ?></a></div>
				<div><?= $p['description']; ?></div>
				<hr>
			<?php endforeach ?>
			<?php endif ?>
		</div>
	</div>
</div>