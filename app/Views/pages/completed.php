<?php 		
	echo view('template/header');
?>
<div class="container">
	Your request has been completed.
	<br>
	<?php if(!isset($_SESSION['user_in'])): ?>
	     <a href="<?= base_url('login'); ?>"><i class="fa fa-sign-in"></i> <?= lang("Validation.login"); ?></a>
	<?php endif ?>
</div>
<?php
	echo view('template/footer'); 
?>