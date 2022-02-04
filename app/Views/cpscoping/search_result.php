<div class="container">
	<div class="row">
		<div class="col-md-4">
		</div>
		<div class="col-md-4">
			<a style="margin-bottom:10px;" href="<?= base_url('kpi_calculation/'.$prjct_id.'/'.$cmpny_id); ?>" class="btn btn-sm btn-info pull-right">View and Edit KPI Calcultion</a>
			<table class="table table-bordered">
				<tr>
					<th>Index</th>
					<th>Result</th>
				</tr>
				<?php $sayac = 1; foreach ($result as $r): ?>
					<tr>
						<th><?= $sayac;$sayac++; ?></th>
						<th><a href="<?= asset_url('cp_scoping_files').'/'.$r["file_name"]; ?>"><?= $r['file_name']; ?></a></th>
					</tr>
				<?php endforeach ?>
			</table>
		</div>
		<div class="col-md-4">
		</div>
	</div>
</div>