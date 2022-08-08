<?php 		
	echo view('template/header');
?>
<div class="container">
	<div class="well">
		<p><b>User Manual</b></p>
		<br>
		<a href="<?= base_url('assets/28_8_20_Celero_User_Manual_prnt.pdf'); ?>"><div  style="background-color:#2D8B42; color:white; text-align: center;"><?= lang("Validation.dl-usermanual"); ?>
		<span class="glyphicon glyphicon-book"></span></div></a>
		<br>
		<br>
		<br>
		<br>
	</div>
</div>
<?php
	echo view('template/footer'); 
?>