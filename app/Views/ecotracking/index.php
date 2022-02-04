<div class="col-md-4 col-md-offset-4">
	<p><?= lang("ecoheading"); ?></p>
	<?php //print_r($informations); ?>
	<?php 
	$flag=1;
	foreach ($informations as $i) {
		$k=1;
		foreach ($i as $c) {
			echo "<a href='ecotracking/".$c['companyfatherid']."/".$c['cmpny_eqpmnt_id']."' class='btn btn-inverse'>".$c['fathername']."- machine ".$k."</a><hr>";
			$k++;
			if($c)
				$flag=0;
		} 

	}
	if($flag==1){
		echo "There are no available equipment under this project";
	}
	?>
</div>

